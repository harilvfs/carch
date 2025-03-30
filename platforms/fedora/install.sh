#!/usr/bin/env bash

VERSION="4.2.5"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m' 

CACHE_DIR="$HOME/.cache/carch-install"
mkdir -p "$CACHE_DIR" 2>/dev/null
LOG_FILE="$CACHE_DIR/carch_rpm_build_$(date +%Y%m%d_%H%M%S).log"

USERNAME=$(whoami)

if command -v pacman &>/dev/null; then
    DISTRO="Arch Linux"
elif command -v dnf &>/dev/null; then
    DISTRO="Fedora"
elif command -v apt &>/dev/null; then
    DISTRO="Debian"
elif command -v zypper &>/dev/null; then
    DISTRO="openSUSE"
elif command -v emerge &>/dev/null; then
    DISTRO="Gentoo"
elif command -v xbps-install &>/dev/null; then
    DISTRO="Void Linux"
else
    DISTRO="Unknown Linux Distribution"
fi

ARCH=$(uname -m)

if ! command -v dnf &>/dev/null; then
    echo -e "${RED}Oops! You are using this script on a non-Fedora based distro.${NC}"
    echo -e "${RED}This script is for Fedora Linux or Fedora-based distributions.${NC}"
    exit 1
fi

log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo -e "${message}" | tee -a "${LOG_FILE}"
}

log_error() {
    log "${RED}ERROR: $1${NC}"
}

log_success() {
    log "${GREEN}SUCCESS: $1${NC}"
}

log_info() {
    log "${BLUE}INFO: $1${NC}"
}

log_warning() {
    log "${YELLOW}WARNING: $1${NC}"
}

typewriter() {
    text="$1"
    color="$2"
    for ((i=0; i<${#text}; i++)); do
        echo -en "${color}${text:$i:1}${NC}"
        sleep 0.03
    done
    echo ""
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

package_installed() {
    rpm -q "$1" >/dev/null 2>&1
}

package_available() {
    dnf list --available "$1" &>/dev/null
}

install_package() {
    local package=$1
    
    if ! package_installed "$package"; then
        log_info "Installing $package..."
        if ! sudo dnf install -y "$package" >> "${LOG_FILE}" 2>&1; then
            log_error "Failed to install $package"
            return 1
        else
            log_success "$package installed successfully"
        fi
    else
        log_info "$package is already installed"
    fi
    return 0
}

if ! command_exists "fzf"; then
    log_info "fzf is not installed. Installing..."
    install_package "fzf"
    sleep 0.5
fi

log_success "fzf is installed and ready to use."

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while ps -p "$pid" > /dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

fzf_confirm() {
    local prompt="$1"
    local options=("Yes" "No")
    local selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="$prompt " --height=10 --layout=reverse --border)
    
    if [[ "$selected" == "Yes" ]]; then
        return 0
    else
        return 1
    fi
}

setup_rpm_build_env() {
    log_info "Setting up RPM build environment..."
    if [ ! -d "$HOME/rpmbuild" ]; then
        rpmdev-setuptree >> "${LOG_FILE}" 2>&1 || { log_error "Failed to setup RPM build environment"; return 1; }
        log_success "RPM build environment set up successfully"
    else
        log_info "RPM build environment already exists"
    fi
    return 0
}

download_spec_file() {
    log_info "Downloading spec file from repository..."
    local spec_dir="$HOME/rpmbuild/SPECS"
    local spec_file="$spec_dir/carch.spec"
    
    if [ ! -d "$spec_dir" ]; then
        mkdir -p "$spec_dir" || { log_error "Failed to create SPECS directory"; return 1; }
    fi
    
    if [ -f "$spec_file" ]; then
        log_warning "Spec file already exists. Backing up..."
        mv "$spec_file" "${spec_file}.bak.$(date +%Y%m%d_%H%M%S)" || { log_error "Failed to backup spec file"; return 1; }
    fi
    
    if ! curl -sL "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/platforms/fedora/carch.spec" -o "$spec_file" >> "${LOG_FILE}" 2>&1; then
        log_error "Failed to download spec file from repository"
        return 1
    fi
    
    if [ -f "$spec_file" ]; then
        log_success "Spec file downloaded successfully from repository"
        return 0
    else
        log_error "Failed to download spec file"
        return 1
    fi
}

download_sources() {
    log_info "Downloading sources..."
    local spec_dir="$HOME/rpmbuild/SPECS"
    local spec_file="$spec_dir/carch.spec"
    
    cd "$spec_dir" || { log_error "Failed to change directory to SPECS"; return 1; }
    if ! spectool -g -R "$spec_file" >> "${LOG_FILE}" 2>&1; then
        log_error "Failed to download sources"
        return 1
    fi
    log_success "Sources downloaded successfully"
    return 0
}

build_rpm() {
    log_info "Building RPM package..."
    local spec_dir="$HOME/rpmbuild/SPECS"
    local spec_file="$spec_dir/carch.spec"
    
    cd "$spec_dir" || { log_error "Failed to change directory to SPECS"; return 1; }
    
    log_info "Building package, please wait..."
    rpmbuild -ba "$spec_file" >> "${LOG_FILE}" 2>&1 &
    local build_pid=$!
    spinner $build_pid
    wait $build_pid
    local build_status=$?
    
    if [ $build_status -ne 0 ]; then
        log_error "Failed to build RPM package"
        return 1
    fi
    
    log_success "RPM package built successfully"
    return 0
}

install_rpm() {
    log_info "Installing RPM package..."
    local rpm_file=$(find "$HOME/rpmbuild/RPMS" -name "carch-*.rpm" | grep -v "debug" | head -n 1)
    
    if [ -z "$rpm_file" ]; then
        log_error "RPM package not found"
        return 1
    fi
    
    log_info "Found RPM package: $rpm_file"
    
    log_info "Installing package..."
    if ! sudo dnf install -y "$rpm_file" >> "${LOG_FILE}" 2>&1; then
        log_error "Failed to install RPM package"
        return 1
    fi
    log_success "RPM package installed successfully"
    
    return 0
}

check_carch_installed() {
    if command_exists "carch"; then
        return 0
    else
        return 1
    fi
}

cleanup_options() {
    echo -e "${YELLOW}Cleanup options:${NC}"
    options=(
        "Remove everything (rpmbuild folder)" 
        "Keep only log files (move to $CACHE_DIR)" 
        "Leave everything (don't remove)"
    )
    
    CHOICE=$(printf "%s\n" "${options[@]}" | fzf --prompt="Select cleanup option: " --height=15 --layout=reverse --border)
    
    case "$CHOICE" in
        "Remove everything (rpmbuild folder)")
            log_info "Removing rpmbuild folder..."
            rm -rf "$HOME/rpmbuild"
            log_success "rpmbuild folder removed successfully"
            ;;
        "Keep only log files (move to $CACHE_DIR)")
            log_info "Moving log files to $CACHE_DIR..."
            mkdir -p "$CACHE_DIR/logs"
            find "$HOME/rpmbuild" -name "*.log" -exec cp {} "$CACHE_DIR/logs/" \;
            rm -rf "$HOME/rpmbuild"
            log_success "Log files preserved, rpmbuild folder removed"
            ;;
        "Leave everything (don't remove)")
            log_info "Skipping cleanup as requested"
            ;;
        *)
            log_info "No cleanup option selected, leaving everything as is"
            ;;
    esac
}

display_welcome() {

clear

echo -e "${GREEN}"
cat <<"EOF"
   ____         __       ____
  /  _/__  ___ / /____ _/ / /__ ____
 _/ // _ \(_-</ __/ _ `/ / / -_) __/
/___/_//_/___/\__/\_,_/_/_/\__/_/

EOF
echo "Carch Installer for Fedora or Fedora based distros."
echo -e "${NC}"
echo ""

echo -e "${CYAN}${BOLD}CARCH${NC}${CYAN}${NC}"
echo -e "${CYAN}${WHITE}Version: $VERSION${NC}${CYAN}${NC}"
echo -e "${CYAN}${WHITE}Architecture: $ARCH${NC}${CYAN}${NC}"

echo ""
typewriter "Hey ${USERNAME}! Thanks for choosing Carch" "${MAGENTA}${BOLD}"
sleep 0.5

echo ""
echo -e "${BLUE}This is the Carch installer for Fedora Linux.${NC}"
sleep 0.5
echo -e "${BLUE}This will install Carch with RPM build package.${NC}"
sleep 0.5
echo ""

}

main() {
    display_welcome
    
    if ! fzf_confirm "Do you want to continue with this installation?"; then
        clear
        exit 0
    fi
    
    typewriter "Sit back and relax till the script will do everything for you" "${GREEN}"
    sleep 0.5

    clear
    
    log_info "Starting Carch RPM build process"
    
    local dependencies=(
        "git" "curl" "wget" "figlet" "man-db" "bash" "rust" "cargo" "gcc" 
        "glibc" "unzip" "tar" "google-noto-color-emoji-fonts" "google-noto-emoji-fonts" 
        "jetbrains-mono-fonts-all" "bat" "bash-completion-devel" "zsh" "fish" 
        "rpmdevtools" "rpmlint" "fzf"
    )
    
    if ! sudo -n true 2>/dev/null; then
        log_warning "This script requires sudo privileges to install packages"
        if ! fzf_confirm "Continue with sudo access?"; then
            log_error "Script aborted due to sudo requirement"
            exit 1
        fi
    fi
    
    echo ""
    echo -e "${YELLOW}Installing dependencies...${NC}"
    echo ""
    
    for dep in "${dependencies[@]}"; do
        if ! install_package "$dep"; then
            log_warning "Failed to install $dep, continuing anyway..."
        fi
        sleep 0.1
    done 
    
    log_info "All dependencies checked. Preparing build environment..."
    sleep 3
    clear
    log_info "Starting build process..."
    
    if ! setup_rpm_build_env; then
        exit 1
    fi
    
    if ! download_spec_file; then
        exit 1
    fi
    
    if ! download_sources; then
        exit 1
    fi
    
    if ! build_rpm; then
        exit 1
    fi
    
    if ! install_rpm; then
        log_error "Failed to install RPM package"
        exit 1
    fi
    
    if check_carch_installed; then
        echo ""
        echo -e "${GREEN}${BOLD}INSTALLATION COMPLETE${NC}"
        sleep 0.5
        echo -e "${GREEN}Carch has been successfully installed!${NC}"
        sleep 0.5
        echo -e "${GREEN}Run 'carch -h' to see available options${NC}"
    else
        log_error "Carch seems to not be installed correctly. Please check the logs."
        exit 1
    fi
    
    echo ""
    cleanup_options
    
    log_success "Carch RPM build and installation completed successfully!"
    echo "Check the log file at ${LOG_FILE} for details."
}

main "$@"
