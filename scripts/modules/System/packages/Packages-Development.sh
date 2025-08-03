#!/usr/bin/env bash

install_development() {
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

        local options=("Node.js" "Python" "Rust" "Go" "Docker" "Postman" "DBeaver" "Hugo" "Back to Main Menu")

        show_menu "Development Tools Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Node.js")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_pacman nodejs npm
                        version=$(get_version nodejs)
                        ;;
                    "Fedora")
                        $pkg_manager nodejs-npm
                        version=$(get_version nodejs)
                        ;;
                    "openSUSE")
                        $pkg_manager nodejs22
                        version=$(get_version nodejs22)
                        ;;
                esac
                echo "Node.js installed successfully! Version: $version"
                ;;

            "Python")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_pacman python python-pip
                        version=$(get_version python)
                        ;;
                    "Fedora")
                        $pkg_manager python3 python3-pip
                        version=$(get_version python3)
                        ;;
                    "openSUSE")
                        $pkg_manager python313
                        version=$(get_version python313)
                        ;;
                esac
                echo "Python installed successfully! Version: $version"
                ;;

            "Rust")
                clear
                bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
                source "$HOME/.cargo/env"
                version=$(rustc --version | awk '{print $2}')
                echo "Rust installed successfully! Version: $version"
                ;;

            "Go")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE")
                        $pkg_manager_pacman go
                        version=$(get_version go)
                        ;;
                    "Fedora")
                        $pkg_manager golang
                        version=$(get_version golang)
                        ;;
                esac
                echo "Go installed successfully! Version: $version"
                ;;

            "Docker")
                clear
                case "$DISTRO" in
                    "Arch" | "Fedora" | "openSUSE")
                        $pkg_manager docker
                        ;;
                esac
                sudo systemctl enable --now docker
                sudo usermod -aG docker "$USER"
                version=$(get_version docker)
                echo "Docker installed successfully! Version: $version"
                echo "Note: You may need to log out and back in for group changes to take effect."
                ;;

            "Postman")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur postman-bin
                        version=$(get_version postman-bin)
                        ;;
                    *)
                        $flatpak_cmd com.getpostman.Postman
                        version="(Flatpak version installed)"
                        ;;
                esac
                echo "Postman installed successfully! Version: $version"
                ;;

            "DBeaver")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_pacman dbeaver
                        version=$(get_version dbeaver)
                        ;;
                    *)
                        $flatpak_cmd io.dbeaver.DBeaverCommunity
                        version="(Flatpak version installed)"
                        ;;
                esac
                echo "DBeaver installed successfully! Version: $version"
                ;;

            "Hugo")
                clear
                case "$DISTRO" in
                    "Arch" | "Fedora" | "openSUSE")
                        $pkg_manager hugo
                        version=$(get_version hugo)
                        ;;
                esac
                echo "Hugo installed successfully! Version: $version"
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
