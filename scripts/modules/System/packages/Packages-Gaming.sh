#!/usr/bin/env bash

install_gaming() {
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
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
