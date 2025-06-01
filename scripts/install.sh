#!/usr/bin/env bash

# carch installation script
# installs, updates, or uninstall.

set -e

CARCH_VERSION="latest"
REPO_OWNER="harilvfs"
REPO_NAME="carch"
GITHUB_RELEASES_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases"
GITHUB_API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases"
BINARY_NAME="carch"
INSTALL_DIR="/usr/local/bin"
MAN_DIR="/usr/local/share/man/man1"
ICON_DIR="/usr/share/icons/hicolor"
DESKTOP_FILE_PATH="/usr/share/applications/carch.desktop"
BASH_COMPLETION_DIR="/usr/share/bash-completion/completions"
ZSH_COMPLETION_DIR="/usr/share/zsh/site-functions"
FISH_COMPLETION_DIR="/usr/share/fish/vendor_completions.d"
CONFIG_DIR="${HOME}/.config/carch"
USE_PRERELEASE=false

BOLD="$(tput bold 2>/dev/null || echo '')"
RED="$(tput setaf 1 2>/dev/null || echo '')"
GREEN="$(tput setaf 2 2>/dev/null || echo '')"
YELLOW="$(tput setaf 3 2>/dev/null || echo '')"
BLUE="$(tput setaf 4 2>/dev/null || echo '')"

FLAMINGO="\e[38;2;238;190;190m"
ROSEWATER="\e[38;2;242;213;207m"
RESET="$(tput sgr0 2>/dev/null || echo '')"

arrow() {
    echo "=>" "$@"
}

arrow_red() {
    echo -e "${RED}=>${RESET} $@"
}

arrow_green() {
    echo -e "${GREEN}=>${RESET} $@"
}

arrow_yellow() {
    echo -e "${YELLOW}=>${RESET} $@"
}

arrow_blue() {
    echo -e "${BLUE}=>${RESET} $@"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_dependencies() {
    arrow_blue "Checking dependencies..."

    local deps=("curl" "grep" "tar" "fzf" "git" "wget" "man" "man-db")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if ! command_exists "$dep"; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        arrow_blue "Please wait, checking & installing required dependencies..."

        if command_exists "pacman"; then
            sudo pacman -Sy --noconfirm "${missing_deps[@]}" > /dev/null 2>&1
        elif command_exists "dnf"; then
            sudo dnf install -y "${missing_deps[@]}" > /dev/null 2>&1
        else
            arrow_red "Unsupported package manager. Please install the following dependencies manually: ${missing_deps[*]}"
        fi
    fi
}

detect_platform() {
    arrow_blue "Detecting platform..."

    PLATFORM="$(uname -s)"
    if [ "$PLATFORM" != "Linux" ]; then
        arrow_red "Carch only supports Linux platforms. Detected: $PLATFORM"
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
            arrow_red "Unsupported architecture: $ARCH"
            ;;
    esac

    arrow_blue "Platform: Linux, Architecture: $ARCH"
}

check_prerelease() {
    arrow_blue "Checking for pre-releases..."

    if command_exists "jq"; then
        PRERELEASE_INFO=$(curl -s "$GITHUB_API_URL" | jq -r '[.[] | select(.prerelease==true)] | first')
        PRERELEASE_AVAILABLE=$(echo "$PRERELEASE_INFO" | jq -r 'if . == null then "false" else "true" end')

        if [ "$PRERELEASE_AVAILABLE" = "true" ]; then
            PRERELEASE_TAG=$(echo "$PRERELEASE_INFO" | jq -r '.tag_name')
            PRERELEASE_NAME=$(echo "$PRERELEASE_INFO" | jq -r '.name')

            arrow_green "${YELLOW}${BOLD}Pre-release available:${RESET} ${PRERELEASE_NAME} (${PRERELEASE_TAG})"

            printf "%s" "${BOLD}Do you want to install this pre-release? [y/N]: ${RESET}"
            read response
            case "$response" in
                [yY][eE][sS]|[yY])
                    USE_PRERELEASE=true
                    CARCH_VERSION="$PRERELEASE_TAG"
                    arrow_blue "Will install pre-release version: $PRERELEASE_TAG"
                    ;;
                *)
                    arrow_blue "Using latest stable release instead"
                    ;;
            esac
        else
            arrow_blue "No pre-releases available, using latest stable release"
        fi
    else
        if curl -s "$GITHUB_API_URL" | grep -q '"prerelease":true'; then
            PRERELEASE_TAG=$(curl -s "$GITHUB_API_URL" | grep -A 1 '"prerelease":true' | grep '"tag_name"' | sed -E 's/.*"tag_name":"([^"]+)".*/\1/' | head -1)

            if [ -n "$PRERELEASE_TAG" ]; then
                arrow_green "${YELLOW}${BOLD}Pre-release available:${RESET} $PRERELEASE_TAG"
                printf "%s" "${BOLD}Do you want to install this pre-release? [y/N]: ${RESET}"
                read response
                case "$response" in
                    [yY][eE][sS]|[yY])
                        USE_PRERELEASE=true
                        CARCH_VERSION="$PRERELEASE_TAG"
                        arrow_blue "Will install pre-release version: $PRERELEASE_TAG"
                        ;;
                    *)
                        arrow_blue "Using latest stable release instead"
                        ;;
                esac
            else
                arrow_blue "No pre-releases available, using latest stable release"
            fi
        else
            arrow_blue "No pre-releases available, using latest stable release"
        fi
    fi
}

install_binary() {
    arrow_blue "Installing carch binary..."

    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

    if [ "$CARCH_VERSION" = "latest" ]; then
        if [ "$USE_PRERELEASE" = true ]; then
            DOWNLOAD_URL="${GITHUB_RELEASES_URL}/tag/${CARCH_VERSION}/download"
        else
            DOWNLOAD_URL="${GITHUB_RELEASES_URL}/latest/download"
        fi
    else
        DOWNLOAD_URL="${GITHUB_RELEASES_URL}/download/${CARCH_VERSION}"
    fi

    if [ "$ARCH" = "x86_64" ]; then
        BINARY_URL="${DOWNLOAD_URL}/carch"
    else
        BINARY_URL="${DOWNLOAD_URL}/carch-${ARCH}"
    fi

    arrow_blue "Downloading from: $BINARY_URL"

    if ! curl -sSL "$BINARY_URL" -o "${TMP_DIR}/${BINARY_NAME}"; then
        arrow_red "Failed to download carch binary"
    fi

    chmod +x "${TMP_DIR}/${BINARY_NAME}"

    arrow_blue "Moving binary to $INSTALL_DIR"
    sudo mkdir -p "$INSTALL_DIR"
    sudo mv "${TMP_DIR}/${BINARY_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"

    if [ -f "${INSTALL_DIR}/${BINARY_NAME}" ]; then
        arrow_green "Carch binary installed to ${INSTALL_DIR}/${BINARY_NAME}"
    else
        arrow_red "Failed to install carch binary"
    fi
}

install_completions() {
    arrow_blue "Installing shell completions..."

    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

    arrow_blue "Installing Bash completion..."
    sudo mkdir -p "$BASH_COMPLETION_DIR"
    curl -sSL "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/completions/bash/carch" -o "${TMP_DIR}/carch"
    sudo mv "${TMP_DIR}/carch" "${BASH_COMPLETION_DIR}/carch"

    arrow_blue "Installing Zsh completion..."
    sudo mkdir -p "$ZSH_COMPLETION_DIR"
    curl -sSL "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/completions/zsh/_carch" -o "${TMP_DIR}/_carch"
    sudo mv "${TMP_DIR}/_carch" "${ZSH_COMPLETION_DIR}/_carch"

    arrow_blue "Installing Fish completion..."
    sudo mkdir -p "$FISH_COMPLETION_DIR"
    curl -sSL "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/completions/fish/carch.fish" -o "${TMP_DIR}/carch.fish"
    sudo mv "${TMP_DIR}/carch.fish" "${FISH_COMPLETION_DIR}/carch.fish"

    arrow_green "Shell completions installed successfully"
}

install_icons() {
    arrow_blue "Installing icons..."

    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

    for size in 16 24 32 48 64 128 256; do
        arrow_blue "Installing ${size}x${size} icon..."

        sudo mkdir -p "${ICON_DIR}/${size}x${size}/apps"

        curl -sSL "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/assets/icons/carch_logo_${size}.png" \
            -o "${TMP_DIR}/carch_${size}.png"

        sudo mv "${TMP_DIR}/carch_${size}.png" "${ICON_DIR}/${size}x${size}/apps/carch.png"
    done

    if command_exists "gtk-update-icon-cache"; then
        arrow_blue "Updating icon cache..."
        sudo gtk-update-icon-cache -f -t "$ICON_DIR" || arrow_yellow "Failed to update icon cache"
    fi

    arrow_green "Icons installed successfully"
}

install_man_page() {
    arrow_blue "Installing man page..."

    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

    sudo mkdir -p "$MAN_DIR"

    curl -sSL "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/man/carch.1" -o "${TMP_DIR}/carch.1"
    sudo mv "${TMP_DIR}/carch.1" "${MAN_DIR}/carch.1"

    if command_exists "mandb"; then
        arrow_blue "Updating man database..."
        sudo mandb -q || arrow_yellow "Failed to update man database"
    fi

    arrow_green "Man page installed successfully"
}

install_desktop_file() {
    arrow_blue "Installing desktop file..."

    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

    curl -sSL "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/carch.desktop" -o "${TMP_DIR}/carch.desktop"

    sed -i "s|Exec=.*|Exec=${INSTALL_DIR}/${BINARY_NAME}|g" "${TMP_DIR}/carch.desktop"

    sudo mv "${TMP_DIR}/carch.desktop" "$DESKTOP_FILE_PATH"

    if command_exists "update-desktop-database"; then
        arrow_blue "Updating desktop database..."
        sudo update-desktop-database || arrow_yellow "Failed to update desktop database"
    fi

    arrow_green "Desktop file installed successfully"
}

uninstall_binary() {
    arrow_blue "Uninstalling carch binary..."

    if [ -f "${INSTALL_DIR}/${BINARY_NAME}" ]; then
        sudo rm -f "${INSTALL_DIR}/${BINARY_NAME}"
        arrow_green "Carch binary uninstalled successfully"
    else
        arrow_yellow "Carch binary not found at ${INSTALL_DIR}/${BINARY_NAME}"
    fi
}

uninstall_completions() {
    arrow_blue "Uninstalling shell completions..."

    if [ -f "${BASH_COMPLETION_DIR}/carch" ]; then
        sudo rm -f "${BASH_COMPLETION_DIR}/carch"
        arrow_green "Bash completion removed"
    else
        arrow_yellow "Bash completion not found"
    fi

    if [ -f "${ZSH_COMPLETION_DIR}/_carch" ]; then
        sudo rm -f "${ZSH_COMPLETION_DIR}/_carch"
        arrow_green "Zsh completion removed"
    else
        arrow_yellow "Zsh completion not found"
    fi

    if [ -f "${FISH_COMPLETION_DIR}/carch.fish" ]; then
        sudo rm -f "${FISH_COMPLETION_DIR}/carch.fish"
        arrow_green "Fish completion removed"
    else
        arrow_yellow "Fish completion not found"
    fi
}

uninstall_icons() {
    arrow_blue "Uninstalling icons..."

    for size in 16 24 32 48 64 128 256; do
        if [ -f "${ICON_DIR}/${size}x${size}/apps/carch.png" ]; then
            sudo rm -f "${ICON_DIR}/${size}x${size}/apps/carch.png"
            arrow_green "${size}x${size} icon removed"
        else
            arrow_yellow "${size}x${size} icon not found"
        fi
    done

    if command_exists "gtk-update-icon-cache"; then
        arrow_blue "Updating icon cache..."
        sudo gtk-update-icon-cache -f -t "$ICON_DIR" || arrow_yellow "Failed to update icon cache"
    fi
}

uninstall_man_page() {
    arrow_blue "Uninstalling man page..."

    if [ -f "${MAN_DIR}/carch.1" ]; then
        sudo rm -f "${MAN_DIR}/carch.1"
        arrow_green "Man page removed"

        if command_exists "mandb"; then
            arrow_blue "Updating man database..."
            sudo mandb -q || arrow_yellow "Failed to update man database"
        fi
    else
        arrow_yellow "Man page not found"
    fi
}

uninstall_desktop_file() {
    arrow_blue "Uninstalling desktop file..."

    if [ -f "$DESKTOP_FILE_PATH" ]; then
        sudo rm -f "$DESKTOP_FILE_PATH"
        arrow_green "Desktop file removed"

        if command_exists "update-desktop-database"; then
            arrow_blue "Updating desktop database..."
            sudo update-desktop-database || arrow_yellow "Failed to update desktop database"
        fi
    else
        arrow_yellow "Desktop file not found"
    fi
}

uninstall_config() {
    arrow_blue "Removing configuration directory..."

    if [ -d "$CONFIG_DIR" ]; then
        rm -rf "$CONFIG_DIR"
        arrow_green "Configuration directory removed"
    else
        arrow_yellow "Configuration directory not found"
    fi
}

print_install_success_message() {
    echo ""
    echo "${GREEN}${BOLD}Carch installed successfully!${RESET}"
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
    echo "${GREEN}${BOLD}Carch updated successfully!${RESET}"
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
    echo "${GREEN}${BOLD}Carch uninstalled!${RESET}"
    echo ""
    echo "All Carch components have been removed from your system."
    echo ""
    echo "Thank you for your time using Carch."
}

install() {

    if [ "$(id -u)" -eq 0 ]; then
        arrow_yellow "This script is running as root. Consider running without sudo and let the script call sudo when needed."
    fi

    clear

echo -e "${FLAMINGO}${BOLD}"
cat <<'EOF'
  _____             __
 / ___/__ _________/ /
/ /__/ _ `/ __/ __/ _ \
\___/\_,_/_/  \__/_//_/

https://github.com/harilvfs/carch
EOF
echo "${RESET}"

while true; do
    printf "%b" "${ROSEWATER}${BOLD}Do you want to continue with the installation? [y/N]: ${RESET}"
    read -r confirm
    case "$confirm" in
        [Yy]*)
           echo ""
           break
           ;;

        [Nn]*)
           exit 0
           ;;
        *)
           echo "Invalid please answer y or n."
           ;;
    esac
done

    detect_platform

    check_dependencies

    check_prerelease

    install_binary

    install_completions

    install_icons

    install_man_page

    install_desktop_file

    print_install_success_message
}

update() {

    if [ "$(id -u)" -eq 0 ]; then
        arrow_yellow "This script is running as root. Consider running without sudo and let the script call sudo when needed."
    fi

while true; do
    printf "%b" "${ROSEWATER}${BOLD}Do you want to continue with the carch update? [y/N]: ${RESET}"
    read -r confirm
    case "$confirm" in
        [Yy]*)
           echo ""
           break
           ;;

        [Nn]*)
           exit 0
           ;;
        *)
           echo "Invalid please answer y or n."
           ;;
    esac
done

    detect_platform

    check_dependencies

    check_prerelease

    install_binary

    install_completions

    install_icons

    install_man_page

    install_desktop_file

    print_update_success_message
}

uninstall() {

    if [ "$(id -u)" -eq 0 ]; then
        arrow_yellow "This script is running as root. Consider running without sudo and let the script call sudo when needed."
    fi

while true; do
    printf "%b" "${ROSEWATER}${BOLD}Do you want to continue with the carch uninstallation? [y/N]: ${RESET}"
    read -r confirm
    case "$confirm" in
        [Yy]*)
           echo ""
           break
           ;;

        [Nn]*)
           exit 0
           ;;
        *)
           echo "Invalid please answer y or n."
           ;;
    esac
done

    arrow_blue "Uninstalling Carch..."

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
                arrow_red "Unknown option: $1. Use --help to see available options."
                ;;
        esac
    fi
}

main "$@"
