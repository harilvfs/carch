#!/usr/bin/env bash

install_terminals() {
    case "$DISTRO" in
        "Arch")
            install_aur_helper
            pkg_manager="sudo pacman -S --noconfirm"
            pkg_manager_aur="$AUR_HELPER -S --noconfirm"
            get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
            ;;
        "Fedora")
            install_flatpak
            pkg_manager="sudo dnf install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            get_version() { rpm -q "$1"; }
            ;;
        "openSUSE")
            pkg_manager="sudo zypper install -y"
            get_version() { rpm -q "$1"; }
            ;;
        *)
            echo -e "${RED}:: Unsupported distribution. Exiting.${NC}"
            return
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
                version=$(get_version alacritty)
                echo "Alacritty installed successfully! Version: $version"
                ;;

            "Kitty")
                clear
                $pkg_manager kitty
                version=$(get_version kitty)
                echo "Kitty installed successfully! Version: $version"
                ;;

            "St")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur st
                        version=$(get_version st)
                        ;;
                    *)
                        $pkg_manager st
                        version=$(get_version st)
                        ;;
                esac
                echo "St Terminal installed successfully! Version: $version"
                ;;

            "Terminator")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur terminator
                        version=$(get_version terminator)
                        ;;
                    *)
                        $pkg_manager terminator
                        version=$(get_version terminator)
                        ;;
                esac
                echo "Terminator installed successfully! Version: $version"
                ;;

            "Tilix")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur tilix
                        version=$(get_version tilix)
                        ;;
                    *)
                        $pkg_manager tilix
                        version=$(get_version tilix)
                        ;;
                esac
                echo "Tilix installed successfully! Version: $version"
                ;;

            "Hyper")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur hyper
                        version=$(get_version hyper)
                        echo "Hyper installed successfully! Version: $version"
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
                            version=$(get_version hyper)
                            echo "Hyper installed successfully! Version: $version"
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
                version=$(get_version gnome-terminal)
                echo "GNOME Terminal installed successfully! Version: $version"
                ;;

            "Konsole")
                clear
                $pkg_manager konsole
                version=$(get_version konsole)
                echo "Konsole installed successfully! Version: $version"
                ;;

            "WezTerm")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE")
                        $pkg_manager wezterm
                        version=$(get_version wezterm)
                        echo "WezTerm installed successfully! Version: $version"
                        ;;
                    "Fedora")
                        if sudo dnf list --installed wezterm &> /dev/null; then
                            version=$(get_version wezterm)
                            echo "WezTerm is already installed! Version: $version"
                        else
                            $flatpak_cmd org.wezfurlong.wezterm
                            version="(Flatpak version installed)"
                            echo "WezTerm installed successfully! Version: $version"
                        fi
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
                version=$(get_version ghostty)
                echo "Ghostty installed successfully! Version: $version"
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
