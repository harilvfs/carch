#!/usr/bin/env bash

install_terminals() {
    case "$DISTRO" in
        "Arch")
            install_aur_helper
            pkg_manager="sudo pacman -S --noconfirm"
            pkg_manager_aur="$AUR_HELPER -S --noconfirm"
            ;;
        "Fedora")
            install_flatpak
            pkg_manager="sudo dnf install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
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
        local options=("Alacritty" "Kitty" "St" "Terminator" "Tilix" "Hyper" "GNOME Terminal" "Konsole" "WezTerm" "Ghostty" "Back to Main Menu")

        show_menu "Terminals Installation" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Alacritty")
                clear
                $pkg_manager alacritty
                ;;

            "Kitty")
                clear
                $pkg_manager kitty
                ;;

            "St")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur st
                        ;;
                    *)
                        $pkg_manager st
                        ;;
                esac
                ;;

            "Terminator")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur terminator
                        ;;
                    *)
                        $pkg_manager terminator
                        ;;
                esac
                ;;

            "Tilix")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur tilix
                        ;;
                    *)
                        $pkg_manager tilix
                        ;;
                esac
                ;;

            "Hyper")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur hyper
                        ;;
                    "Fedora" | "openSUSE")
                        echo ":: Downloading Hyper RPM..."
                        cd /tmp || exit
                        wget -O hyper-3.4.1.x86_64.rpm https://github.com/vercel/hyper/releases/download/v3.4.1/hyper-3.4.1.x86_64.rpm
                        if [[ $? -eq 0 ]]; then
                            case "$DISTRO" in
                                "Fedora") sudo dnf install -y hyper-3.4.1.x86_64.rpm ;;
                                "openSUSE") sudo zypper install -y hyper-3.4.1.x86_64.rpm ;;
                            esac
                            rm -f hyper-3.4.1.x86_64.rpm
                        else
                            echo -e "${RED}!! Failed to download Hyper RPM.${NC}"
                        fi
                        ;;
                esac
                ;;

            "GNOME Terminal")
                clear
                $pkg_manager gnome-terminal
                ;;

            "Konsole")
                clear
                $pkg_manager konsole
                ;;

            "WezTerm")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE")
                        $pkg_manager wezterm
                        ;;
                    "Fedora")
                        $flatpak_cmd org.wezfurlong.wezterm
                        ;;
                esac
                ;;

            "Ghostty")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE")
                        $pkg_manager ghostty
                        ;;
                    "Fedora")
                        sudo dnf copr enable pgdev/ghostty -y
                        sudo dnf install -y ghostty
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
