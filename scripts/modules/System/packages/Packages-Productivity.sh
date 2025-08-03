#!/usr/bin/env bash

install_productivity() {
    while true; do
        clear

        local options=("LibreOffice" "OnlyOffice" "Obsidian" "Joplin" "Calibre" "Back to Main Menu")

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

            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
