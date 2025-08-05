#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_steam() {
    clear
    install_package "steam" "com.valvesoftware.Steam"
}

install_lutris() {
    clear
    install_package "lutris" "net.lutris.Lutris"
}

install_heroic_games_launcher() {
    clear
    install_package "heroic-games-launcher-bin" "com.heroicgameslauncher.hgl" "heroic-games-launcher"
}

install_protonup_qt() {
    clear
    install_package "protonup-qt-bin" "net.davidotek.pupgui2" "protonup-qt"
}

install_mangohud() {
    clear
    install_package "mangohud" ""
}

install_gamemode() {
    clear
    install_package "gamemode" ""
}

main() {
    while true; do
        clear
        local options=("Steam" "Lutris" "Heroic Games Launcher" "ProtonUp-Qt" "MangoHud" "GameMode" "Exit")

        show_menu "Gaming Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Steam") install_steam ;;
            "Lutris") install_lutris ;;
            "Heroic Games Launcher") install_heroic_games_launcher ;;
            "ProtonUp-Qt") install_protonup_qt ;;
            "MangoHud") install_mangohud ;;
            "GameMode") install_gamemode ;;
            "Exit") exit 0 ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
