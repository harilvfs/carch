#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

main() {
  while true; do
    clear
    local options=("Nemo" "Thunar" "Dolphin" "LF (Terminal File Manager)" "Ranger" "Nautilus" "Yazi" "Exit")

    show_menu "File Manager Selection" "${options[@]}"
    get_choice "${#options[@]}"
    local choice_index=$?
    local selection="${options[$((choice_index - 1))]}"

    case "$selection" in
        "Nemo")
            clear
            install_package "nemo" ""
            ;;

        "Thunar")
            clear
            install_package "thunar" ""
            ;;

        "Dolphin")
            clear
            install_package "dolphin" ""
            ;;

        "LF (Terminal File Manager)")
            clear
            if [ "$DISTRO" == "Fedora" ]; then
                sudo dnf copr enable lsevcik/lf -y
            fi
            install_package "lf" ""
            ;;

        "Ranger")
            clear
            install_package "ranger" ""
            ;;

        "Nautilus")
            clear
            install_package "nautilus" ""
            ;;

        "Yazi")
            clear
            if [ "$DISTRO" == "Fedora" ]; then
                sudo dnf copr enable varlad/yazi -y
            fi
            install_package "yazi" ""
            ;;
           "Exit")
                exit 0
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
