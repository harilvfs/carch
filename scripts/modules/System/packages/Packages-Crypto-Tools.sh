#!/usr/bin/env bash

install_crypto_tools() {
    while true; do
        clear

        local options=("Electrum" "Back to Main Menu")

        show_menu "Crypto Tools Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Electrum")
                clear
                install_package "electrum" "org.electrum.electrum"
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
