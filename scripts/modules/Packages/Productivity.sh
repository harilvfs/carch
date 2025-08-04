#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_libreoffice() {
    clear
    local pkg_name="libreoffice"
    if [ "$DISTRO" == "Arch" ]; then
        pkg_name="libreoffice-fresh"
    fi
    install_package "$pkg_name" "org.libreoffice.LibreOffice"
}

install_onlyoffice() {
    clear
    install_package "onlyoffice-bin" "org.onlyoffice.desktopeditors"
}

install_obsidian() {
    clear
    install_package "obsidian" "md.obsidian.Obsidian"
}

install_joplin() {
    clear
    install_package "joplin-desktop" "net.cozic.joplin_desktop"
}

install_calibre() {
    clear
    install_package "calibre" "com.calibre_ebook.calibre"
}

main() {
    while true; do
        clear
        local options=("LibreOffice" "OnlyOffice" "Obsidian" "Joplin" "Calibre" "Exit")

        show_menu "Productivity Apps Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "LibreOffice") install_libreoffice ;;
            "OnlyOffice") install_onlyoffice ;;
            "Obsidian") install_obsidian ;;
            "Joplin") install_joplin ;;
            "Calibre") install_calibre ;;
            "Exit") exit 0 ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
