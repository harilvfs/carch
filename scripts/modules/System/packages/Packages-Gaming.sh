#!/usr/bin/env bash

install_gaming() {
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

        local options=("Steam" "Lutris" "Heroic Games Launcher" "ProtonUp-Qt" "MangoHud" "GameMode" "Back to Main Menu")

        show_menu "Gaming Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Steam")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE")
                        $pkg_manager_pacman steam
                        version=$(get_version steam)
                        ;;
                    "Fedora")
                        $flatpak_cmd com.valvesoftware.Steam
                        version="(Flatpak version installed)"
                        ;;
                esac
                echo "Steam installed successfully! Version: $version"
                ;;

            "Lutris")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE" | "Fedora")
                        $pkg_manager lutris
                        version=$(get_version lutris)
                        ;;
                esac
                echo "Lutris installed successfully! Version: $version"
                ;;

            "Heroic Games Launcher")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur heroic-games-launcher-bin
                        version=$(get_version heroic-games-launcher-bin)
                        ;;
                    *)
                        $flatpak_cmd com.heroicgameslauncher.hgl
                        version="(Flatpak version installed)"
                        ;;
                esac
                echo "Heroic Games Launcher installed successfully! Version: $version"
                ;;

            "ProtonUp-Qt")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur protonup-qt-bin
                        version=$(get_version protonup-qt-bin)
                        ;;
                    *)
                        $flatpak_cmd net.davidotek.pupgui2
                        version="(Flatpak version installed)"
                        ;;
                esac
                echo "ProtonUp-Qt installed successfully! Version: $version"
                ;;

            "MangoHud")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE" | "Fedora")
                        $pkg_manager mangohud
                        version=$(get_version mangohud)
                        ;;
                esac
                echo "MangoHud installed successfully! Version: $version"
                ;;

            "GameMode")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE" | "Fedora")
                        $pkg_manager gamemode
                        version=$(get_version gamemode)
                        ;;
                esac
                echo "GameMode installed successfully! Version: $version"
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
