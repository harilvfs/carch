#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_usbutils() {
    clear
    install_package "usbutils" ""
}

install_wireless_tools() {
    clear
    case "$DISTRO" in
        "Fedora")
            print_message "$RED" "wireless-tools has been deprecated by Fedora. Use a modern tool like 'iw' instead."
            ;;
        *)
            install_package "wireless-tools" ""
            ;;
    esac
}

install_iw() {
    clear
    install_package "iw" ""
}

main() {
    while true; do
        clear
        local options=("usbutils" "wireless-tools" "iw" "Exit")

        show_menu "Networking Tools Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "usbutils") install_usbutils ;;
            "wireless-tools") install_wireless_tools ;;
            "iw") install_iw ;;
            "Exit") exit 0 ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
