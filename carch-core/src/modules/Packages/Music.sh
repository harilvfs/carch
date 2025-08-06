#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_youtube_music() {
    clear
    install_package "youtube-music-bin" "app.ytmdesktop.ytmdesktop"
}

install_spotube() {
    clear
    install_package "spotube" "com.github.KRTirtho.Spotube"
}

install_spotify() {
    clear
    install_package "spotify" "com.spotify.Client"
}

install_rhythmbox() {
    clear
    install_package "rhythmbox" "org.gnome.Rhythmbox3"
}

install_mousai() {
    clear
    install_package "mousai" "io.github.seadve.Mousai"
}

main() {
    while true; do
        clear
        local options=("Youtube-Music" "Spotube" "Spotify" "Rhythmbox" "Mousai" "Exit")
        show_menu "Music App Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Youtube-Music") install_youtube_music ;;
            "Spotube") install_spotube ;;
            "Spotify") install_spotify ;;
            "Rhythmbox") install_rhythmbox ;;
            "Mousai") install_mousai ;;
            "Exit") exit 0 ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
