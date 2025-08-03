#!/usr/bin/env bash

install_gaming() {
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
                        ;;
                    "Fedora")
                        $flatpak_cmd com.valvesoftware.Steam
                        ;;
                esac
                ;;

            "Lutris")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE" | "Fedora")
                        $pkg_manager lutris
                        ;;
                esac
                ;;

            "Heroic Games Launcher")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur heroic-games-launcher-bin
                        ;;
                    *)
                        $flatpak_cmd com.heroicgameslauncher.hgl
                        ;;
                esac
                ;;

            "ProtonUp-Qt")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur protonup-qt-bin
                        ;;
                    *)
                        $flatpak_cmd net.davidotek.pupgui2
                        ;;
                esac
                ;;

            "MangoHud")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE" | "Fedora")
                        $pkg_manager mangohud
                        ;;
                esac
                ;;

            "GameMode")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE" | "Fedora")
                        $pkg_manager gamemode
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
