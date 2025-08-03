#!/usr/bin/env bash

install_fm_tools() {
    while true; do
        clear

        local options=("Tumbler [Thumbnail Viewer]" "Trash-Cli" "Back to Main Menu")

        show_menu "FM Tools Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Tumbler [Thumbnail Viewer]")
                clear
                install_package "tumbler" ""
                ;;

            "Trash-Cli")
                clear
                install_package "trash-cli" ""
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
