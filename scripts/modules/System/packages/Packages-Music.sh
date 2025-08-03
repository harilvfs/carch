#!/usr/bin/env bash

install_music() {
    while true; do
        clear
        local options=("Youtube-Music" "Spotube" "Spotify" "Rhythmbox" "Mousai" "Back to Main Menu")
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
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
