#!/usr/bin/env bash

install_filemanagers() {
    while true; do
        clear

        local options=("Nemo" "Thunar" "Dolphin" "LF (Terminal File Manager)" "Ranger" "Nautilus" "Yazi" "Back to Main Menu")

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
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
