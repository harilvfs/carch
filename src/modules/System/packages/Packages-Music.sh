#!/usr/bin/env bash

install_music() {
    detect_distro
    distro=$?
    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager="$AUR_HELPER -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        install_flatpak
        pkg_manager="sudo dnf install -y"
        flatpak_cmd="flatpak install -y --noninteractive flathub"
        get_version() { rpm -q "$1"; }
    elif [[ $distro -eq 2 ]]; then
        install_flatpak
        pkg_manager="sudo zypper install -y"
        flatpak_cmd="flatpak install -y --noninteractive flathub"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${NC}"
        return
    fi

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
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager youtube-music-bin
                    version=$(get_version youtube-music-bin)
                else
                    $flatpak_cmd app.ytmdesktop.ytmdesktop
                    version="Flatpak Version"
                fi
                echo "Youtube-Music installed successfully! Version: $version"
                ;;
            "Spotube")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager spotube
                    version=$(get_version spotube)
                else
                    $flatpak_cmd com.github.KRTirtho.Spotube
                    version="Flatpak Version"
                fi
                echo "Spotube installed successfully! Version: $version"
                ;;
            "Spotify")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager spotify
                    version=$(get_version spotify)
                else
                    $flatpak_cmd com.spotify.Client
                    version="Flatpak Version"
                fi
                echo "Spotify installed successfully! Version: $version"
                ;;
            "Rhythmbox")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager rhythmbox
                    version=$(get_version rhythmbox)
                elif [[ $distro -eq 2 ]]; then
                    $pkg_manager rhythmbox
                    version=$(get_version rhythmbox)
                else
                    $pkg_manager rhythmbox
                    version=$(get_version rhythmbox)
                fi
                echo "Rhythmbox installed successfully! Version: $version"
                ;;
            "Mousai")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager mousai
                    version=$(get_version mousai)
                elif [[ $distro -eq 2 ]]; then
                    $pkg_manager mousai
                    version=$(get_version mousai)
                else
                    $flatpak_cmd io.github.seadve.Mousai
                    version="Flatpak Version"
                fi
                echo "Mousai music identifier installed successfully! Version: $version"
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
