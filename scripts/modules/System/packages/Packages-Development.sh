#!/usr/bin/env bash

install_development() {
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
                        install_package "nodejs" ""
                        install_package "npm" ""
                        ;;
                    "Fedora")
                        install_package "nodejs-npm" ""
                        ;;
                    "openSUSE")
                        install_package "nodejs22" ""
                        ;;
                esac
                ;;

            "Python")
                clear
                case "$DISTRO" in
                    "Arch")
                        install_package "python" ""
                        install_package "python-pip" ""
                        ;;
                    "Fedora")
                        install_package "python3" ""
                        install_package "python3-pip" ""
                        ;;
                    "openSUSE")
                        install_package "python313" ""
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
                local pkg_name="go"
                if [ "$DISTRO" == "Fedora" ]; then
                    pkg_name="golang"
                fi
                install_package "$pkg_name" ""
                ;;

            "Docker")
                clear
                install_package "docker" ""
                sudo systemctl enable --now docker
                sudo usermod -aG docker "$USER"
                echo "Note: You may need to log out and back in for group changes to take effect."
                ;;

            "Postman")
                clear
                install_package "postman-bin" "com.getpostman.Postman" "postman"
                ;;

            "DBeaver")
                clear
                install_package "dbeaver" "io.dbeaver.DBeaverCommunity"
                ;;

            "Hugo")
                clear
                install_package "hugo" ""
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
