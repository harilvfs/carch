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
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${RESET}"
        return
    fi

    while true; do
        clear

        options=("Youtube-Music" "Spotube" "Spotify" "Rhythmbox" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
            "Youtube-Music")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager youtube-music-bin
                    version=$(get_version youtube-music-bin)
                else
                    flatpak install -y flathub app.ytmdesktop.ytmdesktop
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
                    flatpak install -y flathub com.github.KRTirtho.Spotube
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
                    flatpak install -y flathub com.spotify.Client
                    version="Flatpak Version"
                fi
                echo "Spotify installed successfully! Version: $version"
                ;;

            "Rhythmbox")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager rhythmbox
                else
                    $pkg_manager rhythmbox
                fi
                version=$(get_version rhythmbox)
                echo "Rhythmbox installed successfully! Version: $version"
                ;;

            esac
        done

        echo "All selected Music Apps have been installed."
        read -rp "Press Enter to continue..."
    done
}
