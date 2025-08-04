#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_nemo() {
    clear
    install_package "nemo" ""
}

install_thunar() {
    clear
    install_package "thunar" ""
}

install_dolphin() {
    clear
    install_package "dolphin" ""
}

install_lf() {
    clear
    if [ "$DISTRO" == "Fedora" ]; then
        sudo dnf copr enable lsevcik/lf -y
    fi
    install_package "lf" ""
}

install_ranger() {
    clear
    install_package "ranger" ""
}

install_nautilus() {
    clear
    install_package "nautilus" ""
}

install_yazi() {
    clear
    if [ "$DISTRO" == "Fedora" ]; then
        sudo dnf copr enable varlad/yazi -y
    fi
    install_package "yazi" ""
}

main() {
    while true; do
        clear
        local options=("Nemo" "Thunar" "Dolphin" "LF (Terminal File Manager)" "Ranger" "Nautilus" "Yazi" "Exit")

        show_menu "File Manager Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Nemo") install_nemo ;;
            "Thunar") install_thunar ;;
            "Dolphin") install_dolphin ;;
            "LF (Terminal File Manager)") install_lf ;;
            "Ranger") install_ranger ;;
            "Nautilus") install_nautilus ;;
            "Yazi") install_yazi ;;
            "Exit") exit 0 ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
