#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

main() {
  while true; do
    clear
    local options=("Youtube-Music" "Spotube" "Spotify" "Rhythmbox" "Mousai" "Exit")
    show_menu "Music App Selection" "${options[@]}"
    get_choice "${#options[@]}"
    local choice_index=$?
    local selection="${options[$((choice_index - 1))]}"

    case "$selection" in
        "Youtube-Music")
            clear
            install_package "youtube-music-bin" "app.ytmdesktop.ytmdesktop"
            ;;
        "Spotube")
            clear
            install_package "spotube" "com.github.KRTirtho.Spotube"
            ;;
        "Spotify")
            clear
            install_package "spotify" "com.spotify.Client"
            ;;
        "Rhythmbox")
            clear
            install_package "rhythmbox" "org.gnome.Rhythmbox3"
            ;;
        "Mousai")
            clear
            install_package "mousai" "io.github.seadve.Mousai"
            ;;
           "Exit")
                exit 0
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
