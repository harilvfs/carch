#!/usr/bin/env bash
#
# carch installation script
# installs, updates, or uninstall.

set -e

CARCH_VERSION="latest"
REPO_OWNER="harilvfs"
REPO_NAME="carch"
GITHUB_RELEASES_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases"
BINARY_NAME="carch"
INSTALL_DIR="/usr/local/bin"
MAN_DIR="/usr/local/share/man/man1"
ICON_DIR="/usr/share/icons/hicolor"
DESKTOP_FILE_PATH="/usr/share/applications/carch.desktop"
BASH_COMPLETION_DIR="/usr/share/bash-completion/completions"
ZSH_COMPLETION_DIR="/usr/share/zsh/site-functions"
FISH_COMPLETION_DIR="/usr/share/fish/vendor_completions.d"
CONFIG_DIR="${HOME}/.config/carch"

BOLD="$(tput bold 2>/dev/null || echo '')"
RED="$(tput setaf 1 2>/dev/null || echo '')"
GREEN="$(tput setaf 2 2>/dev/null || echo '')"
YELLOW="$(tput setaf 3 2>/dev/null || echo '')"
BLUE="$(tput setaf 4 2>/dev/null || echo '')"
RESET="$(tput sgr0 2>/dev/null || echo '')"

error() {
    echo "${RED}${BOLD}ERROR:${RESET} $1" >&2
    exit 1
}

info() {
    echo "${BLUE}${BOLD}INFO:${RESET} $1"
}

success() {
    echo "${GREEN}${BOLD}SUCCESS:${RESET} $1"
}

warning() {
    echo "${YELLOW}${BOLD}WARNING:${RESET} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_dependencies() {
    info "Checking dependencies..."
    
    local deps=("curl" "grep" "tar" "fzf" "git" "wget" "man" "man-db")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command_exists "$dep"; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "Please wait, installing required dependencies..."
        
        if command_exists "pacman"; then
            sudo pacman -Sy --noconfirm "${missing_deps[@]}" > /dev/null 2>&1
        elif command_exists "dnf"; then
            sudo dnf install -y "${missing_deps[@]}" > /dev/null 2>&1
        else
            error "Unsupported package manager. Please install the following dependencies manually: ${missing_deps[*]}"
        fi
    fi
}

detect_platform() {
    info "Detecting platform..."
    
    PLATFORM="$(uname -s)"
    if [ "$PLATFORM" != "Linux" ]; then
        error "Carch only supports Linux platforms. Detected: $PLATFORM"
    fi
    
    ARCH="$(uname -m)"
    case "$ARCH" in
        x86_64|amd64)
            ARCH="x86_64"
            ;;
        aarch64|arm64)
            ARCH="aarch64"
            ;;
        *)
            error "Unsupported architecture: $ARCH"
            ;;
    esac
    
    info "Platform: Linux, Architecture: $ARCH"
}

install_binary() {
    info "Installing carch binary..."
    
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT INT TERM
    
    if [ "$CARCH_VERSION" = "latest" ]; then
        DOWNLOAD_URL="${GITHUB_RELEASES_URL}/latest/download"
    else
        DOWNLOAD_URL="${GITHUB_RELEASES_URL}/download/${CARCH_VERSION}"
    fi
    
    if [ "$ARCH" = "x86_64" ]; then
        BINARY_URL="${DOWNLOAD_URL}/carch"
    else
        BINARY_URL="${DOWNLOAD_URL}/carch-${ARCH}"
    fi
    
    info "Downloading from: $BINARY_URL"
    
    if ! curl -sSL "$BINARY_URL" -o "${TMP_DIR}/${BINARY_NAME}"; then
        error "Failed to download carch binary"
    fi
    
    chmod +x "${TMP_DIR}/${BINARY_NAME}"
    
    info "Moving binary to $INSTALL_DIR"
    sudo mkdir -p "$INSTALL_DIR"
    sudo mv "${TMP_DIR}/${BINARY_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"
    
    if [ -f "${INSTALL_DIR}/${BINARY_NAME}" ]; then
        success "Carch binary installed successfully to ${INSTALL_DIR}/${BINARY_NAME}"
    else
        error "Failed to install carch binary"
    fi
}

install_completions() {
    info "Installing shell completions..."
    
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT INT TERM
    
    info "Installing Bash completion..."
    sudo mkdir -p "$BASH_COMPLETION_DIR"
    curl -sSL "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/completions/bash/carch" -o "${TMP_DIR}/carch"
    sudo mv "${TMP_DIR}/carch" "${BASH_COMPLETION_DIR}/carch"
    
    info "Installing Zsh completion..."
    sudo mkdir -p "$ZSH_COMPLETION_DIR"
    curl -sSL "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/completions/zsh/_carch" -o "${TMP_DIR}/_carch"
    sudo mv "${TMP_DIR}/_carch" "${ZSH_COMPLETION_DIR}/_carch"
    
    info "Installing Fish completion..."
    sudo mkdir -p "$FISH_COMPLETION_DIR"
    curl -sSL "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/completions/fish/carch.fish" -o "${TMP_DIR}/carch.fish"
    sudo mv "${TMP_DIR}/carch.fish" "${FISH_COMPLETION_DIR}/carch.fish"
    
    success "Shell completions installed successfully"
}

install_icons() {
    info "Installing icons..."
    
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT INT TERM
    
    for size in 16 24 32 48 64 128 256; do
        info "Installing ${size}x${size} icon..."
        
        sudo mkdir -p "${ICON_DIR}/${size}x${size}/apps"
        
        curl -sSL "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/assets/icons/product_logo_${size}.png" \
            -o "${TMP_DIR}/carch_${size}.png"
            
        sudo mv "${TMP_DIR}/carch_${size}.png" "${ICON_DIR}/${size}x${size}/apps/carch.png"
    done
    
    if command_exists "gtk-update-icon-cache"; then
        info "Updating icon cache..."
        sudo gtk-update-icon-cache -f -t "$ICON_DIR" || warning "Failed to update icon cache"
    fi
    
    success "Icons installed successfully"
}

install_man_page() {
    info "Installing man page..."
    
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT INT TERM
    
    sudo mkdir -p "$MAN_DIR"
    
    curl -sSL "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/man/carch.1" -o "${TMP_DIR}/carch.1"
    sudo mv "${TMP_DIR}/carch.1" "${MAN_DIR}/carch.1"
    
    if command_exists "mandb"; then
        info "Updating man database..."
        sudo mandb -q || warning "Failed to update man database"
    fi
    
    success "Man page installed successfully"
}

install_desktop_file() {
    info "Installing desktop file..."
    
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT INT TERM
    
    curl -sSL "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/carch.desktop" -o "${TMP_DIR}/carch.desktop"
    
    sed -i "s|Exec=.*|Exec=${INSTALL_DIR}/${BINARY_NAME}|g" "${TMP_DIR}/carch.desktop"
    
    sudo mv "${TMP_DIR}/carch.desktop" "$DESKTOP_FILE_PATH"
    
    if command_exists "update-desktop-database"; then
        info "Updating desktop database..."
        sudo update-desktop-database || warning "Failed to update desktop database"
    fi
    
    success "Desktop file installed successfully"
}

uninstall_binary() {
    info "Uninstalling carch binary..."
    
    if [ -f "${INSTALL_DIR}/${BINARY_NAME}" ]; then
        sudo rm -f "${INSTALL_DIR}/${BINARY_NAME}"
        success "Carch binary uninstalled successfully"
    else
        warning "Carch binary not found at ${INSTALL_DIR}/${BINARY_NAME}"
    fi
}

uninstall_completions() {
    info "Uninstalling shell completions..."
    
    if [ -f "${BASH_COMPLETION_DIR}/carch" ]; then
        sudo rm -f "${BASH_COMPLETION_DIR}/carch"
        success "Bash completion removed"
    else
        warning "Bash completion not found"
    fi
    
    if [ -f "${ZSH_COMPLETION_DIR}/_carch" ]; then
        sudo rm -f "${ZSH_COMPLETION_DIR}/_carch"
        success "Zsh completion removed"
    else
        warning "Zsh completion not found"
    fi
    
    if [ -f "${FISH_COMPLETION_DIR}/carch.fish" ]; then
        sudo rm -f "${FISH_COMPLETION_DIR}/carch.fish"
        success "Fish completion removed"
    else
        warning "Fish completion not found"
    fi
}

uninstall_icons() {
    info "Uninstalling icons..."
    
    for size in 16 24 32 48 64 128 256; do
        if [ -f "${ICON_DIR}/${size}x${size}/apps/carch.png" ]; then
            sudo rm -f "${ICON_DIR}/${size}x${size}/apps/carch.png"
            success "${size}x${size} icon removed"
        else
            warning "${size}x${size} icon not found"
        fi
    done
    
    if command_exists "gtk-update-icon-cache"; then
        info "Updating icon cache..."
        sudo gtk-update-icon-cache -f -t "$ICON_DIR" || warning "Failed to update icon cache"
    fi
}

uninstall_man_page() {
    info "Uninstalling man page..."
    
    if [ -f "${MAN_DIR}/carch.1" ]; then
        sudo rm -f "${MAN_DIR}/carch.1"
        success "Man page removed"
        
        if command_exists "mandb"; then
            info "Updating man database..."
            sudo mandb -q || warning "Failed to update man database"
        fi
    else
        warning "Man page not found"
    fi
}

uninstall_desktop_file() {
    info "Uninstalling desktop file..."
    
    if [ -f "$DESKTOP_FILE_PATH" ]; then
        sudo rm -f "$DESKTOP_FILE_PATH"
        success "Desktop file removed"
        
        if command_exists "update-desktop-database"; then
            info "Updating desktop database..."
            sudo update-desktop-database || warning "Failed to update desktop database"
        fi
    else
        warning "Desktop file not found"
    fi
}

uninstall_config() {
    info "Removing configuration directory..."
    
    if [ -d "$CONFIG_DIR" ]; then
        rm -rf "$CONFIG_DIR"
        success "Configuration directory removed"
    else
        warning "Configuration directory not found"
    fi
}

print_install_success_message() {
    echo ""
    echo "${GREEN}${BOLD}  Carch installed successfully!${RESET}"
    echo ""
    echo "You can now run carch from your terminal by typing: ${BOLD}carch${RESET}"
    echo ""
    echo "If you need help, run: ${BOLD}carch --help${RESET}"
    echo ""
    echo "For more information, visit: ${BOLD}https://carch.chalisehari.com.np${RESET}"
    echo ""
}

print_update_success_message() {
    echo ""
    echo "${GREEN}${BOLD}  Carch updated successfully!${RESET}"
    echo ""
    echo "You can now run the updated carch from your terminal by typing: ${BOLD}carch${RESET}"
    echo ""
    echo "If you need help, run: ${BOLD}carch --help${RESET}"
    echo ""
    echo "For more information, visit: ${BOLD}https://carch.chalisehari.com.np${RESET}"
    echo ""
}

print_uninstall_success_message() {
    echo ""
    echo "${GREEN}${BOLD} Carch uninstalled successfully!${RESET}"
    echo ""
    echo "All Carch components have been removed from your system."
    echo ""
}

install() {
    if [ "$(id -u)" -eq 0 ]; then
        warning "This script is running as root. Consider running without sudo and let the script call sudo when needed."
    fi
    
    detect_platform
    
    check_dependencies
    
    install_binary
    
    install_completions
    
    install_icons
    
    install_man_page
    
    install_desktop_file
    
    print_install_success_message
}

update() {
    info "Updating Carch..."
    
    if [ "$(id -u)" -eq 0 ]; then
        warning "This script is running as root. Consider running without sudo and let the script call sudo when needed."
    fi
    
    detect_platform
    
    check_dependencies
    
    install_binary
    
    install_completions
    
    install_icons
    
    install_man_page
    
    install_desktop_file
    
    print_update_success_message
}

uninstall() {
    info "Uninstalling Carch..."
    
    if [ "$(id -u)" -eq 0 ]; then
        warning "This script is running as root. Consider running without sudo and let the script call sudo when needed."
    fi
    
    uninstall_binary
    
    uninstall_completions
    
    uninstall_icons
    
    uninstall_man_page
    
    uninstall_desktop_file
    
    uninstall_config
    
    print_uninstall_success_message
}

print_usage() {
    echo "Usage: $0 [--install|--update|--uninstall]"
    echo ""
    echo "Options:"
    echo "  --install     Install Carch (default action)"
    echo "  --update      Update an existing Carch installation"
    echo "  --uninstall   Uninstall Carch completely"
    echo ""
}

main() {
    if [ $# -eq 0 ]; then
        install
    else
        case "$1" in
            --install)
                install
                ;;
            --update)
                update
                ;;
            --uninstall)
                uninstall
                ;;
            --help)
                print_usage
                ;;
            *)
                error "Unknown option: $1. Use --help to see available options."
                ;;
        esac
    fi
}

main "$@" 
