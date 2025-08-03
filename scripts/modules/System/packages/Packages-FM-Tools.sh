#!/usr/bin/env bash

install_fm_tools() {
    case "$DISTRO" in
        "Arch")
            pkg_manager="sudo pacman -S --noconfirm"
            ;;
        "Fedora")
            pkg_manager="sudo dnf install -y"
            ;;
        "openSUSE")
            pkg_manager="sudo zypper install -y"
            ;;
        *)
            exit 1
            ;;
    esac

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
                $pkg_manager tumbler
                ;;

            "Trash-Cli")
                clear
                $pkg_manager trash-cli
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
