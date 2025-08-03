#!/usr/bin/env bash

install_terminals() {
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
                install_package "alacritty" ""
                ;;

            "Kitty")
                clear
                install_package "kitty" ""
                ;;

            "St")
                clear
                install_package "st" ""
                ;;

            "Terminator")
                clear
                install_package "terminator" ""
                ;;

            "Tilix")
                clear
                install_package "tilix" ""
                ;;

            "Hyper")
                clear
                case "$DISTRO" in
                    "Arch")
                        install_package "hyper" ""
                        ;;
                    "Fedora" | "openSUSE")
                        print_message "$GREEN" "Downloading Hyper RPM..."
                        cd /tmp || exit
                        wget -O hyper-3.4.1.x86_64.rpm https://github.com/vercel/hyper/releases/download/v3.4.1/hyper-3.4.1.x86_64.rpm
                        if [[ $? -eq 0 ]]; then
                            case "$DISTRO" in
                                "Fedora") sudo dnf install -y hyper-3.4.1.x86_64.rpm ;;
                                "openSUSE") sudo zypper install -y hyper-3.4.1.x86_64.rpm ;;
                            esac
                            rm -f hyper-3.4.1.x86_64.rpm
                        else
                            print_message "$RED" "Failed to download Hyper RPM."
                        fi
                        ;;
                esac
                ;;

            "GNOME Terminal")
                clear
                install_package "gnome-terminal" ""
                ;;

            "Konsole")
                clear
                install_package "konsole" ""
                ;;

            "WezTerm")
                clear
                install_package "wezterm" "org.wezfurlong.wezterm"
                ;;

            "Ghostty")
                clear
                if [ "$DISTRO" == "Fedora" ]; then
                    sudo dnf copr enable pgdev/ghostty -y
                fi
                install_package "ghostty" ""
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
