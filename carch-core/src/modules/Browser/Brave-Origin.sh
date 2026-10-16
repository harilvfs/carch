#!/usr/bin/env bash

set -o pipefail

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_brave_origin() {
    clear

    if ! command -v curl &> /dev/null; then
        print_message "$YELLOW" "Installing curl..."
        case "$DISTRO" in
            "Arch") sudo pacman -S --noconfirm curl ;;
            "Fedora") sudo dnf install -y curl ;;
            "openSUSE") sudo zypper install -y curl ;;
            *)
                print_message "$RED" "curl is required to install Brave Origin."
                return 1
                ;;
        esac
    fi

    # on arch the official installer falls back to the aur, which needs an aur helper
    if [ "$DISTRO" = "Arch" ]; then
        install_aur_helper
    fi

    print_message "$GREEN" "Installing Brave Origin from the official standalone installer..."
    if curl -fsS https://dl.brave.com/install.sh | FLAVOR=origin sh; then
        print_message "$GREEN" "Brave Origin installed successfully."
    else
        print_message "$RED" "Brave Origin installation failed. Check the output above for details."
    fi
}

install_brave_origin
