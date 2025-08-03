#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

main() {
    while true; do
        clear
        local options
        if [[ "$DISTRO" == "openSUSE" || "$DISTRO" == "Fedora" ]]; then
            # for opensuse and fedora
            options=("VLC" "MPV" "Exit")
        else
            options=("VLC" "MPV" "Netflix [Unofficial]" "Exit")
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
            "Exit")
                exit 0
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
