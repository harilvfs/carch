#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

main() {
    while true; do
        clear
        local options=("LibreOffice" "OnlyOffice" "Obsidian" "Joplin" "Calibre" "Exit")

        show_menu "Productivity Apps Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "LibreOffice")
                clear
                local pkg_name="libreoffice"
                if [ "$DISTRO" == "Arch" ]; then
                    pkg_name="libreoffice-fresh"
                fi
                install_package "$pkg_name" "org.libreoffice.LibreOffice"
                ;;

            "OnlyOffice")
                clear
                install_package "onlyoffice-bin" "org.onlyoffice.desktopeditors"
                ;;

            "Obsidian")
                clear
                install_package "obsidian" "md.obsidian.Obsidian"
                ;;

            "Joplin")
                clear
                install_package "joplin-desktop" "net.cozic.joplin_desktop"
                ;;

            "Calibre")
                clear
                install_package "calibre" "com.calibre_ebook.calibre"
                ;;
            "Exit")
                exit 0
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
