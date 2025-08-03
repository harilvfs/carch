#!/usr/bin/env bash

install_productivity() {
    case "$DISTRO" in
        "Arch")
            install_aur_helper
            pkg_manager_aur="$AUR_HELPER -S --noconfirm"
            pkg_manager_pacman="sudo pacman -S --noconfirm"
            ;;
        "Fedora")
            install_flatpak
            pkg_manager="sudo dnf install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            ;;
        "openSUSE")
            install_flatpak
            pkg_manager="sudo zypper install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            ;;
        *)
            exit 1
            ;;
    esac

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
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_pacman libreoffice-fresh
                        ;;
                    *)
                        $pkg_manager libreoffice
                        ;;
                esac
                ;;

            "OnlyOffice")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur onlyoffice-bin
                        ;;
                    *)
                        $flatpak_cmd org.onlyoffice.desktopeditors
                        ;;
                esac
                ;;

            "Obsidian")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur obsidian
                        ;;
                    *)
                        $flatpak_cmd md.obsidian.Obsidian
                        ;;
                esac
                ;;

            "Joplin")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur joplin-desktop
                        ;;
                    *)
                        $flatpak_cmd net.cozic.joplin_desktop
                        ;;
                esac
                ;;

            "Calibre")
                clear
                case "$DISTRO" in
                    "Arch" | "Fedora" | "openSUSE")
                        $pkg_manager calibre
                        ;;
                esac
                ;;

            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
