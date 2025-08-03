#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

main() {
  while true; do
    clear
    local options=("Steam" "Lutris" "Heroic Games Launcher" "ProtonUp-Qt" "MangoHud" "GameMode" "Exit")

    show_menu "Gaming Selection" "${options[@]}"
    get_choice "${#options[@]}"
    local choice_index=$?
    local selection="${options[$((choice_index - 1))]}"

    case "$selection" in
        "Steam")
            clear
            install_package "steam" "com.valvesoftware.Steam"
            ;;

        "Lutris")
            clear
            install_package "lutris" "net.lutris.Lutris"
            ;;

        "Heroic Games Launcher")
            clear
            install_package "heroic-games-launcher-bin" "com.heroicgameslauncher.hgl" "heroic-games-launcher"
            ;;

        "ProtonUp-Qt")
            clear
            install_package "protonup-qt-bin" "net.davidotek.pupgui2" "protonup-qt"
            ;;

        "MangoHud")
            clear
            install_package "mangohud" ""
            ;;

        "GameMode")
            clear
            install_package "gamemode" ""
            ;;
           "Exit")
                exit 0
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
