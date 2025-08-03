#!/usr/bin/env bash

install_filemanagers() {
    case "$DISTRO" in
        "Arch")
            pkg_manager="sudo pacman -S --noconfirm"
            ;;
        "Fedora")
            pkg_manager="sudo dnf install -y"
            ;;
        "openSUSE")
            pkg_manager="sudo zypper install -y"
            ;;
        *)
            exit 1
            ;;
    esac

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
                $pkg_manager nemo
                ;;

            "Thunar")
                clear
                $pkg_manager thunar
                ;;

            "Dolphin")
                clear
                $pkg_manager dolphin
                ;;

            "LF (Terminal File Manager)")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE")
                        $pkg_manager lf
                        ;;
                    "Fedora")
                        sudo dnf copr enable lsevcik/lf -y
                        $pkg_manager lf
                        ;;
                esac
                ;;

            "Ranger")
                clear
                $pkg_manager ranger
                ;;

            "Nautilus")
                clear
                $pkg_manager nautilus
                ;;

            "Yazi")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE")
                        $pkg_manager yazi
                        ;;
                    "Fedora")
                        sudo dnf copr enable varlad/yazi -y
                        $pkg_manager yazi
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
