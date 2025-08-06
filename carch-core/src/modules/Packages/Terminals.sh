#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_alacritty() {
    clear
    install_package "alacritty" ""
}

install_kitty() {
    clear
    install_package "kitty" ""
}

install_st() {
    clear
    install_package "st" ""
}

install_terminator() {
    clear
    install_package "terminator" ""
}

install_tilix() {
    clear
    install_package "tilix" ""
}

install_hyper() {
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
}

install_gnome_terminal() {
    clear
    install_package "gnome-terminal" ""
}

install_konsole() {
    clear
    install_package "konsole" ""
}

install_wezterm() {
    clear
    install_package "wezterm" "org.wezfurlong.wezterm"
}

install_ghostty() {
    clear
    if [ "$DISTRO" == "Fedora" ]; then
        sudo dnf copr enable pgdev/ghostty -y
    fi
    install_package "ghostty" ""
}

main() {
    while true; do
        clear
        local options=("Alacritty" "Kitty" "St" "Terminator" "Tilix" "Hyper" "GNOME Terminal" "Konsole" "WezTerm" "Ghostty" "Exit")

        show_menu "Terminals Installation" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Alacritty") install_alacritty ;;
            "Kitty") install_kitty ;;
            "St") install_st ;;
            "Terminator") install_terminator ;;
            "Tilix") install_tilix ;;
            "Hyper") install_hyper ;;
            "GNOME Terminal") install_gnome_terminal ;;
            "Konsole") install_konsole ;;
            "WezTerm") install_wezterm ;;
            "Ghostty") install_ghostty ;;
            "Exit") exit 0 ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
