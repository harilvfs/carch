#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

mkdir -p "$HOME/rpmbuild" 2>/dev/null
LOG_FILE="$HOME/rpmbuild/carch_rpm_build_$(date +%Y%m%d_%H%M%S).log"

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
    
    if ! curl -sL "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/fedora/carch.spec" -o "$spec_file" >> "${LOG_FILE}" 2>&1; then
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
    
    if fzf_confirm "Do you want to install the RPM package?"; then
        log_info "Installing package..."
        if ! sudo dnf install -y "$rpm_file" >> "${LOG_FILE}" 2>&1; then
            log_error "Failed to install RPM package"
            return 1
        fi
        log_success "RPM package installed successfully"
    else
        log_info "Installation cancelled by user"
    fi
    
    return 0
}

handle_error() {
    local fallback_url="https://github.com/harilvfs/carch/blob/main/fedora/carch.spec"
    log_warning "Build process failed. Attempting to use fallback spec file from $fallback_url"
    
    if fzf_confirm "Do you want to try using the fallback spec file?"; then
        local spec_dir="$HOME/rpmbuild/SPECS"
        local spec_file="$spec_dir/carch.spec"
        
        log_info "Downloading fallback spec file..."
        if ! curl -sL "https://raw.githubusercontent.com/harilvfs/carch/main/fedora/carch.spec" -o "$spec_file" >> "${LOG_FILE}" 2>&1; then
            log_error "Failed to download fallback spec file"
            exit 1
        fi
        
        log_success "Fallback spec file downloaded successfully"
        log_info "Attempting to rebuild with fallback spec file..."
        
        if ! download_sources; then
            log_error "Failed to download sources with fallback spec"
            exit 1
        fi
        
        if ! build_rpm; then
            log_error "Failed to build RPM with fallback spec"
            exit 1
        fi
        
        if ! install_rpm; then
            log_error "Failed to install RPM with fallback spec"
            exit 1
        fi
        
        log_success "Process completed successfully with fallback spec"
    else
        log_error "Process aborted by user"
        exit 1
    fi
}

display_welcome() {
    clear
    echo -e "${YELLOW}┌────────────────────────────────────────────────┐${RESET}"
    echo -e "${YELLOW}│      Welcome to Carch Installer for Fedora     │${RESET}"
    echo -e "${YELLOW}└────────────────────────────────────────────────┘${RESET}"
    echo
    echo -e "${YELLOW}NOTE: If you are re-running this script, please remove the${NC}"
    echo -e "${YELLOW}~/rpmbuild directory first to avoid conflicts:${NC}"
    echo -e "${BLUE}rm -rf ~/rpmbuild${NC}"
    echo
}

main() {
    display_welcome
    
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
    
    log_info "Checking dependencies..."
    echo "Please wait while checking dependencies..."
    
    for dep in "${dependencies[@]}"; do
        if ! install_package "$dep"; then
            log_warning "Failed to install $dep, continuing anyway..."
        fi
    done
    
    log_info "All dependencies checked. Preparing build environment..."
    sleep 3
    clear
    log_info "Starting build process..."
    
    if ! setup_rpm_build_env; then
        handle_error
        exit 1
    fi
    
    if ! download_spec_file; then
        handle_error
        exit 1
    fi
    
    if ! download_sources; then
        handle_error
        exit 1
    fi
    
    if ! build_rpm; then
        handle_error
        exit 1
    fi
    
    if ! install_rpm; then
        log_error "Failed to install RPM package"
        exit 1
    fi
    
    log_success "Carch RPM build and installation completed successfully!"
    
    echo
    echo -e "${GREEN}Carch has been successfully installed!${NC}"
    echo "You can now run 'carch' to start using it."
    echo "Check the log file at ${LOG_FILE} for details."
}

main "$@"
