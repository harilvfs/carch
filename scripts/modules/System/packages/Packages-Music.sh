#!/usr/bin/env bash

install_music() {
    case "$DISTRO" in
        "Arch")
            install_aur_helper
            pkg_manager="$AUR_HELPER -S --noconfirm"
            ;;
        "Fedora")
            install_flatpak
            pkg_manager="sudo dnf install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            ;;
        "openSUSE")
            install_flatpak
            pkg_manager="sudo zypper install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            ;;
        *)
            exit 1
            ;;
    esac

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
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager youtube-music-bin
                        ;;
                    *)
                        $flatpak_cmd app.ytmdesktop.ytmdesktop
                        ;;
                esac
                ;;
            "Spotube")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager spotube
                        ;;
                    *)
                        $flatpak_cmd com.github.KRTirtho.Spotube
                        ;;
                esac
                ;;
            "Spotify")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager spotify
                        ;;
                    *)
                        $flatpak_cmd com.spotify.Client
                        ;;
                esac
                ;;
            "Rhythmbox")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE" | "Fedora")
                        $pkg_manager rhythmbox
                        ;;
                esac
                ;;
            "Mousai")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE")
                        $pkg_manager mousai
                        ;;
                    "Fedora")
                        $flatpak_cmd io.github.seadve.Mousai
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
