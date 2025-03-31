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
LOG_FILE="$CACHE_DIR/carch_install_$(date +%Y%m%d_%H%M%S).log"
TMP_DIR=$(mktemp -d)

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
    local message=$2
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local delay=0.1

    while ps -p "$pid" > /dev/null; do
        for frame in "${frames[@]}"; do
            printf "\r ${CYAN}%s${NC} %s" "$frame" "$message"
            sleep $delay
            printf "\033[0K"
        done
    done
    printf "\r${GREEN}✓${NC} %s\n" "$message"
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

get_latest_release() {
    log_info "Checking for latest Carch release..."
    
    local repo="harilvfs/carch"
    local api_url="https://api.github.com/repos/$repo/releases/latest"
    
    if ! command_exists "curl"; then
        log_error "curl is required but not installed"
        return 1
    fi

    local release_info
    release_info=$(curl -s "$api_url")
    
    if [ -z "$release_info" ] || [[ "$release_info" == *"Not Found"* ]]; then
        log_error "Failed to fetch release information from GitHub"
        return 1
    fi
    
    local rpm_url
    rpm_url=$(echo "$release_info" | grep -o "https://github.com/$repo/releases/download/[^\"]*\.rpm" | grep "$ARCH" | head -n 1)
    
    if [ -z "$rpm_url" ]; then
        log_error "Could not find RPM package for $ARCH architecture"
        return 1
    fi 
    
    echo "$rpm_url"
    return 0
}

download_rpm() {
    log_info "Downloading Carch RPM package..."
    
    local rpm_url
    rpm_url=$(get_latest_release)
    
    if [ $? -ne 0 ] || [ -z "$rpm_url" ]; then
        log_error "Failed to determine download URL"
        return 1
    fi 
    
    local rpm_file="$TMP_DIR/carch.rpm"
    
    log_info "Downloading from: $rpm_url"
    
    curl -L "$rpm_url" -o "$rpm_file" >> "${LOG_FILE}" 2>&1 &
    local download_pid=$!
    spinner $download_pid "Downloading Carch package..."
    wait $download_pid
    
    if [ ! -f "$rpm_file" ] || [ ! -s "$rpm_file" ]; then
        log_error "Download failed or file is empty"
        return 1
    fi 
    
    log_success "Downloaded Carch package to $rpm_file"
    echo "$rpm_file"
    return 0
}

install_rpm() {
    log_info "Installing Carch package..."
    
    local rpm_file=$1
    
    if [ ! -f "$rpm_file" ]; then
        log_error "RPM file not found: $rpm_file"
        return 1
    fi 
    
    log_info "Installing package..."
    sudo dnf install -y "$rpm_file" >> "${LOG_FILE}" 2>&1 &
    local install_pid=$!
    spinner $install_pid "Installing Carch..."
    wait $install_pid
    local install_status=$?
    
    if [ $install_status -ne 0 ]; then
        log_error "Failed to install Carch package"
        return 1
    fi 
    
    log_success "Carch installed successfully"
    return 0
}

check_carch_installed() {
    if command_exists "carch"; then
        return 0
    else
        return 1
    fi
}

cleanup() {
    log_info "Cleaning up temporary files..."
    rm -rf "$TMP_DIR"
    log_success "Cleanup completed"
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
    echo -e "${CYAN}${WHITE}Distribution: $DISTRO${NC}${CYAN}${NC}"
    echo -e "${CYAN}${WHITE}Architecture: $ARCH${NC}${CYAN}${NC}"

    echo ""
    typewriter "Hey ${USERNAME}! Thanks for choosing Carch" "${MAGENTA}${BOLD}"
    sleep 0.5

    echo ""
    echo -e "${BLUE}This is the Carch fast installer for Fedora Linux.${NC}"
    sleep 0.5
    echo -e "${BLUE}This will download and install the pre-built Carch package.${NC}"
    sleep 0.5
    echo ""
}

main() {
    display_welcome
    
    if ! fzf_confirm "Do you want to install Carch?"; then
        clear
        exit 0
    fi
    
    typewriter "Sit back and relax while we install Carch for you" "${GREEN}"
    sleep 0.5

    clear
    
    log_info "Starting Carch installation process"
    
    local dependencies=(
        "git" "curl" "wget" "figlet" "man-db" "bash" "rust" "cargo"
        "glibc" "unzip" "tar" "google-noto-color-emoji-fonts" "google-noto-emoji-fonts" 
        "jetbrains-mono-fonts-all" "bat" "bash-completion-devel" "zsh" "fish" "fzf"
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
    
    echo ""
    log_info "All dependencies checked. Starting Carch installation..."
    sleep 1
    
    local rpm_file
    rpm_file=$(download_rpm)
    
    if [ $? -ne 0 ] || [ -z "$rpm_file" ]; then
        log_error "Failed to download Carch package. Aborting installation."
        cleanup
        exit 1
    fi
    
    if ! install_rpm "$rpm_file"; then
        log_error "Failed to install Carch package"
        cleanup
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
        cleanup
        exit 1
    fi
    
    cleanup
    
    log_success "Carch installation completed successfully!"
    echo "Check the log file at ${LOG_FILE} for details."
}

main "$@"
