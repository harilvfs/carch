#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

print_message() {
    local color="$1"
    local message="$2"
    printf "%b:: %s%b\n" "$color" "$message" "$NC"
}

check_curl() {
    if ! command -v curl &> /dev/null; then
        print_message "$YELLOW" "Installing curl..."
        case "$DISTRO" in
            "Arch") sudo pacman -S --noconfirm curl ;;
            "Fedora") sudo dnf install -y curl ;;
            "openSUSE") sudo zypper install -y curl ;;
            *)
                exit 1
                ;;
        esac
    fi
}

install_bun() {
    print_message "$GREEN" "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash

    if [ $? -eq 0 ]; then
        print_message "$GREEN" "Bun has been installed successfully!"
    else
        print_message "$RED" "Failed to install Bun."
        exit 1
    fi
}

main() {
    check_curl
    install_bun
}

main
