#!/usr/bin/env bash

install_development() {
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
                        ;;
                    "Fedora")
                        $pkg_manager nodejs-npm
                        ;;
                    "openSUSE")
                        $pkg_manager nodejs22
                        ;;
                esac
                ;;

            "Python")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_pacman python python-pip
                        ;;
                    "Fedora")
                        $pkg_manager python3 python3-pip
                        ;;
                    "openSUSE")
                        $pkg_manager python313
                        ;;
                esac
                ;;

            "Rust")
                clear
                bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
                source "$HOME/.cargo/env"
                ;;

            "Go")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE")
                        $pkg_manager_pacman go
                        ;;
                    "Fedora")
                        $pkg_manager golang
                        ;;
                esac
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
                echo "Note: You may need to log out and back in for group changes to take effect."
                ;;

            "Postman")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur postman-bin
                        ;;
                    *)
                        $flatpak_cmd com.getpostman.Postman
                        ;;
                esac
                ;;

            "DBeaver")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_pacman dbeaver
                        ;;
                    *)
                        $flatpak_cmd io.dbeaver.DBeaverCommunity
                        ;;
                esac
                ;;

            "Hugo")
                clear
                case "$DISTRO" in
                    "Arch" | "Fedora" | "openSUSE")
                        $pkg_manager hugo
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
