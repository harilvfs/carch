#!/usr/bin/env bash

clear

source "$(dirname "$0")"/../colors.sh > /dev/null 2>&1

print_message() {
    local color="$1"
    local message="$2"
    printf "%b%s%b\n" "$color" "$message" "$ENDCOLOR"
}

confirm() {
    while true; do
        read -p "$(printf "%b%s%b" "$CYAN" "$1 [y/N]: " "$ENDCOLOR")" answer
        case ${answer,,} in
            y | yes) return 0 ;;
            n | no | "") return 1 ;;
            *) print_message "$YELLOW" "Please answer with y/yes or n/no." ;;
        esac
    done
}

check_distro() {
    if command -v dnf &> /dev/null; then
        print_message "$RED" "You are using Fedora (dnf detected). This script is only for Arch-based systems."
        exit 1
    elif command -v zypper &> /dev/null; then
        print_message "$RED" "You are using openSUSE (zypper detected). This script is only for Arch-based systems."
        exit 1
    elif ! command -v pacman &> /dev/null; then
        print_message "$RED" "This script is for Arch-based distros only. Exiting."
        exit 1
    fi
}

install_chaotic_aur() {
    if [[ $EUID -eq 0 ]]; then
        print_message "$RED" "Please run this script as a normal user, not as root."
        exit 1
    fi

    if grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
        print_message "$GREEN" "Chaotic AUR is already configured in /etc/pacman.conf."
        exit 0
    fi

    if [ ! -d "/etc/pacman.d/gnupg" ]; then
        print_message "$TEAL" "Initializing pacman keys..."
        sudo pacman-key --init || {
            print_message "$RED" "Failed to initialize pacman keys. Please check your system."
            exit 1
        }
    fi

    print_message "$TEAL" "Fetching Chaotic AUR key..."
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com || {
        print_message "$RED" "Failed to fetch the Chaotic AUR key. Please check your internet connection."
        exit 1
    }

    print_message "$TEAL" "Signing the key..."
    sudo pacman-key --lsign-key 3056513887B78AEB || {
        print_message "$RED" "Failed to sign the key. Please try again."
        exit 1
    }

    print_message "$TEAL" "Installing Chaotic AUR keyring..."
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' || {
        print_message "$RED" "Failed to install chaotic-keyring. Please check your internet connection."
        exit 1
    }

    print_message "$TEAL" "Installing Chaotic AUR mirrorlist..."
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' || {
        print_message "$RED" "Failed to install chaotic-mirrorlist. Please check your internet connection."
        exit 1
    }

    print_message "$TEAL" "Adding Chaotic AUR to pacman.conf..."
    echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf > /dev/null || {
        print_message "$RED" "Failed to modify pacman.conf. Please try again with sudo permissions."
        exit 1
    }

    print_message "$TEAL" "Syncing Pacman database..."
    sudo pacman -Syy || {
        print_message "$RED" "Failed to sync pacman database. Please try again."
        exit 1
    }

    print_message "$GREEN" "Chaotic AUR has been installed successfully!"
    echo -e "${GREEN}You can now install packages from Chaotic AUR using pacman.${ENDCOLOR}"
}

main() {
    check_distro
    print_message "$CYAN" "This script will add the Chaotic-AUR repository to your system."
    if confirm "Do you want to proceed with the installation?"; then
        install_chaotic_aur
    else
        print_message "$YELLOW" "Installation cancelled."
    fi
}

main
