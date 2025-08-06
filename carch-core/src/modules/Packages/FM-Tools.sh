#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_tumbler() {
    clear
    install_package "tumbler" ""
}

install_trash_cli() {
    clear
    install_package "trash-cli" ""
}

main() {
    while true; do
        clear
        local options=("Tumbler [Thumbnail Viewer]" "Trash-Cli" "Exit")

        show_menu "FM Tools Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Tumbler [Thumbnail Viewer]") install_tumbler ;;
            "Trash-Cli") install_trash_cli ;;
            "Exit") exit 0 ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
