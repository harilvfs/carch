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

install_gum() {
    if ! command_exists gum; then
        if package_available gum; then
            log_info "Gum found in official repositories, installing..."
            if ! install_package gum; then
                log_warning "Failed to install gum from repositories, trying from GitHub..."
                install_gum_from_github
            fi
        else
            log_info "Gum not found in official repositories, installing from GitHub..."
            install_gum_from_github
        fi
    else
        log_info "Gum is already installed"
    fi
    return 0
}

install_gum_from_github() {
    log_info "Installing gum from GitHub..."
    local tmp_dir=$(mktemp -d)
    cd "$tmp_dir" || { log_error "Failed to create temp directory"; return 1; }
    
    if ! curl -sL https://github.com/charmbracelet/gum/releases/download/v0.11.0/gum_0.11.0_linux_amd64.tar.gz -o gum.tar.gz >> "${LOG_FILE}" 2>&1; then
        log_error "Failed to download gum"
        cd - > /dev/null
        rm -rf "$tmp_dir"
        return 1
    fi
    
    if ! tar xzf gum.tar.gz >> "${LOG_FILE}" 2>&1; then
        log_error "Failed to extract gum"
        cd - > /dev/null
        rm -rf "$tmp_dir"
        return 1
    fi
    
    if ! sudo mv gum /usr/local/bin/ >> "${LOG_FILE}" 2>&1; then
        log_error "Failed to install gum"
        cd - > /dev/null
        rm -rf "$tmp_dir"
        return 1
    fi
    
    cd - > /dev/null
    rm -rf "$tmp_dir"
    log_success "Gum installed successfully from GitHub"
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
    
    if command_exists gum; then
        gum spin --spinner dot --title "Building RPM package..." -- rpmbuild -ba "$spec_file" >> "${LOG_FILE}" 2>&1
        local build_status=$?
    else
        rpmbuild -ba "$spec_file" >> "${LOG_FILE}" 2>&1 &
        local build_pid=$!
        spinner $build_pid
        wait $build_pid
        local build_status=$?
    fi
    
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
    
    if command_exists gum; then
        if ! gum confirm "Do you want to install the RPM package?"; then
            log_info "Installation cancelled by user"
            return 0
        fi
    else
        read -p "Do you want to install the RPM package? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled by user"
            return 0
        fi
    fi
    
    if ! sudo dnf install -y "$rpm_file" >> "${LOG_FILE}" 2>&1; then
        log_error "Failed to install RPM package"
        return 1
    fi
    
    log_success "RPM package installed successfully"
    return 0
}

handle_error() {
    local fallback_url="https://github.com/harilvfs/carch/blob/main/fedora/carch.spec"
    log_warning "Build process failed. Attempting to use fallback spec file from $fallback_url"
    
    if command_exists gum; then
        if ! gum confirm "Do you want to try using the fallback spec file?"; then
            log_error "Process aborted by user"
            exit 1
        fi
    else
        read -p "Do you want to try using the fallback spec file? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "Process aborted by user"
            exit 1
        fi
    fi
    
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
}

main() {
  clear
    if command_exists gum; then
        gum style \
            --border normal \
            --margin "1" \
            --padding "1" \
            --border-foreground 212 \
            "Welcome to Carch Installer for Fedora"
    else
        echo -e "${BLUE}Welcome to Carch Installer for Fedora${NC}"
        echo "----------------------------------------"
    fi
    
    log_info "Starting Carch RPM build process"
    
    local dependencies=(
        "git" "curl" "wget" "figlet" "man-db" "bash" "rust" "cargo" "gcc" 
        "glibc" "unzip" "tar" "google-noto-color-emoji-fonts" "google-noto-emoji-fonts" 
        "jetbrains-mono-fonts-all" "bat" "bash-completion-devel" "zsh" "fish" 
        "rpmdevtools" "rpmlint"
    )
    
    if ! sudo -n true 2>/dev/null; then
        log_warning "This script requires sudo privileges to install packages"
        if command_exists gum; then
            if ! gum confirm "Continue with sudo access?"; then
                log_error "Script aborted due to sudo requirement"
                exit 1
            fi
        else
            read -p "Continue with sudo access? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log_error "Script aborted due to sudo requirement"
                exit 1
            fi
        fi
    fi
    
    install_gum
    
    log_info "Checking dependencies..."
    
    if command_exists gum; then
        local spinner_text="Checking dependencies..."
        gum spin --spinner dot --title "$spinner_text" -- sleep 1
    fi
    
    for dep in "${dependencies[@]}"; do
        if ! install_package "$dep"; then
            log_warning "Failed to install $dep, continuing anyway..."
        fi
    done
    
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
    
    if command_exists gum; then
        gum style \
            --border normal \
            --margin "1" \
            --padding "1" \
            --border-foreground 212 \
            "Carch has been successfully installed! You can now run 'carch' to start using it."
    else
        echo -e "${GREEN}Carch has been successfully installed!${NC}"
        echo "You can now run 'carch' to start using it."
        echo "Check the log file at ${LOG_FILE} for details."
    fi
}

main "$@"
