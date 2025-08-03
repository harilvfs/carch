#!/usr/bin/env bash

install_music() {
    case "$DISTRO" in
        "Arch")
            install_aur_helper
            pkg_manager="$AUR_HELPER -S --noconfirm"
            get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
            ;;
        "Fedora")
            install_flatpak
            pkg_manager="sudo dnf install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            get_version() { rpm -q "$1"; }
            ;;
        "openSUSE")
            install_flatpak
            pkg_manager="sudo zypper install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            get_version() { rpm -q "$1"; }
            ;;
        *)
            echo -e "${RED}:: Unsupported distribution. Exiting.${NC}"
            return
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
                        version=$(get_version youtube-music-bin)
                        ;;
                    *)
                        $flatpak_cmd app.ytmdesktop.ytmdesktop
                        version="Flatpak Version"
                        ;;
                esac
                echo "Youtube-Music installed successfully! Version: $version"
                ;;
            "Spotube")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager spotube
                        version=$(get_version spotube)
                        ;;
                    *)
                        $flatpak_cmd com.github.KRTirtho.Spotube
                        version="Flatpak Version"
                        ;;
                esac
                echo "Spotube installed successfully! Version: $version"
                ;;
            "Spotify")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager spotify
                        version=$(get_version spotify)
                        ;;
                    *)
                        $flatpak_cmd com.spotify.Client
                        version="Flatpak Version"
                        ;;
                esac
                echo "Spotify installed successfully! Version: $version"
                ;;
            "Rhythmbox")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE" | "Fedora")
                        $pkg_manager rhythmbox
                        version=$(get_version rhythmbox)
                        ;;
                esac
                echo "Rhythmbox installed successfully! Version: $version"
                ;;
            "Mousai")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE")
                        $pkg_manager mousai
                        version=$(get_version mousai)
                        ;;
                    "Fedora")
                        $flatpak_cmd io.github.seadve.Mousai
                        version="Flatpak Version"
                        ;;
                esac
                echo "Mousai music identifier installed successfully! Version: $version"
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
