#!/usr/bin/env bash

install_multimedia() {
    while true; do
        clear
        local options
        if [[ "$DISTRO" == "openSUSE" || "$DISTRO" == "Fedora" ]]; then
            # for opensuse and fedora
            options=("VLC" "MPV" "Back to Main Menu")
        else
            options=("VLC" "MPV" "Netflix [Unofficial]" "Back to Main Menu")
        fi

        show_menu "Multimedia Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "VLC")
                clear
                install_package "vlc" "org.videolan.VLC"
                ;;

            "MPV")
                clear
                install_package "mpv" "io.mpv.Mpv"
                ;;

            "Netflix [Unofficial]")
                clear
                case "$DISTRO" in
                    "Arch")
                        install_package "netflix" ""
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
