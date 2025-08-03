#!/usr/bin/env bash

install_productivity() {
    case "$DISTRO" in
        "Arch")
            install_aur_helper
            pkg_manager_aur="$AUR_HELPER -S --noconfirm"
            pkg_manager_pacman="sudo pacman -S --noconfirm"
            get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
            ;;
        "Fedora")
            install_flatpak
            pkg_manager="sudo dnf install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            get_version() { rpm -q "$1"; }
            ;;
        "openSUSE")
            install_flatpak
            pkg_manager="sudo zypper install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            get_version() { rpm -q "$1"; }
            ;;
        *)
            echo -e "${RED}:: Unsupported distribution. Exiting.${NC}"
            return
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
                        version=$(get_version libreoffice-fresh)
                        ;;
                    *)
                        $pkg_manager libreoffice
                        version=$(get_version libreoffice)
                        ;;
                esac
                echo "LibreOffice installed successfully! Version: $version"
                ;;

            "OnlyOffice")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur onlyoffice-bin
                        version=$(get_version onlyoffice-bin)
                        ;;
                    *)
                        $flatpak_cmd org.onlyoffice.desktopeditors
                        version="(Flatpak version installed)"
                        ;;
                esac
                echo "OnlyOffice installed successfully! Version: $version"
                ;;

            "Obsidian")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur obsidian
                        version=$(get_version obsidian)
                        ;;
                    *)
                        $flatpak_cmd md.obsidian.Obsidian
                        version="(Flatpak version installed)"
                        ;;
                esac
                echo "Obsidian installed successfully! Version: $version"
                ;;

            "Joplin")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur joplin-desktop
                        version=$(get_version joplin-desktop)
                        ;;
                    *)
                        $flatpak_cmd net.cozic.joplin_desktop
                        version="(Flatpak version installed)"
                        ;;
                esac
                echo "Joplin installed successfully! Version: $version"
                ;;

            "Calibre")
                clear
                case "$DISTRO" in
                    "Arch" | "Fedora" | "openSUSE")
                        $pkg_manager calibre
                        version=$(get_version calibre)
                        ;;
                esac
                echo "Calibre installed successfully! Version: $version"
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
