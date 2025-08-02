#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

print_message() {
    local color="$1"
    local message="$2"
    printf "%b%s%b\n" "$color" "$message" "$NC"
}

confirm() {
    while true; do
        read -p "$(printf "%b%s%b" "$CYAN" "$1 [y/N]: " "$NC")" answer
        case ${answer,,} in
            y | yes) return 0 ;;
            n | no | "") return 1 ;;
            *) print_message "$YELLOW" "Please answer with y/yes or n/no." ;;
        esac
    done
}

check_and_install_npm() {
    if command -v npm &> /dev/null; then
        NODE_VERSION=$(node -v)
        NPM_VERSION=$(npm -v)
        print_message "$GREEN" "npm is already installed."
        print_message "$TEAL" "Node.js version: $NODE_VERSION"
        print_message "$TEAL" "npm version: $NPM_VERSION"
        exit 0
    fi

    print_message "$YELLOW" "npm is not installed on your system."

    if ! confirm "Do you want to install Node.js (includes npm) using your package manager?"; then
        print_message "$RED" "Installation aborted."
        exit 1
    fi

    case "$DISTRO" in
        "Arch") sudo pacman -S --noconfirm nodejs npm ;;
        "Fedora") sudo dnf install -y nodejs npm ;;
        "openSUSE") sudo zypper install -y nodejs22 ;;
        *)
            print_message "$RED" "No supported package manager found."
            exit 1
            ;;
    esac

    if command -v npm &> /dev/null; then
        NODE_VERSION=$(node -v)
        NPM_VERSION=$(npm -v)
        print_message "$GREEN" "Node.js and npm installed successfully."
        print_message "$TEAL" "Node.js version: $NODE_VERSION"
        print_message "$TEAL" "npm version: $NPM_VERSION"
    else
        print_message "$RED" "npm installation failed."
        exit 1
    fi
}

check_and_install_npm
