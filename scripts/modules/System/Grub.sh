#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

GRUB_THEME_DIR="$HOME/.local/share/Top-5-Bootloader-Themes"

print_message() {
    local color="$1"
    local message="$2"
    printf "%b:: %s%b\n" "$color" "$message" "$NC"
}

confirm() {
    while true; do
        read -p "$(printf "%b:: %s%b" "$CYAN" "$1 [y/N]: " "$NC")" answer
        case ${answer,,} in
            y | yes) return 0 ;;
            n | no | "") return 1 ;;
            *) print_message "$YELLOW" "Please answer with y/yes or n/no." ;;
        esac
    done
}

check_existing_dir() {
    if [[ -d "$GRUB_THEME_DIR" ]]; then
        print_message "$RED" "Directory $GRUB_THEME_DIR already exists."
        if confirm "Do you want to overwrite it?"; then
            print_message "$TEAL" "Removing existing directory..."
            rm -rf "$GRUB_THEME_DIR"
        else
            print_message "$RED" "Aborting installation."
            exit 1
        fi
    fi
}

clone_repo() {
    print_message "$TEAL" "Cloning GRUB themes repository..."
    git clone https://github.com/harilvfs/Top-5-Bootloader-Themes "$GRUB_THEME_DIR"
}

install_theme() {
    print_message "$TEAL" "Running the installation script..."
    cd "$GRUB_THEME_DIR" || exit
    sudo ./install.sh
}

main() {
    print_message "$TEAL" "This Grub Theme Script is from Chris Titus Tech."
    print_message "$TEAL" "Check out the source code here: https://github.com/harilvfs/Top-5-Bootloader-Themes"
    check_existing_dir
    clone_repo
    install_theme
}

main
