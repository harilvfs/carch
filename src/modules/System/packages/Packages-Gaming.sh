#!/usr/bin/env bash

install_gaming() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
        pkg_manager_pacman="sudo pacman -S --noconfirm"
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

        options=("Steam" "Lutris" "Heroic Games Launcher" "ProtonUp-Qt" "MangoHud" "GameMode" "Back to Main Menu")
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
                "Steam")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman steam
                        version=$(get_version steam)
                    elif [[ $distro -eq 2 ]]; then
                        $pkg_manager steam
                        version=$(get_version steam)
                    else
                        $flatpak_cmd com.valvesoftware.Steam
                        version="(Flatpak version installed)"
                    fi
                    echo "Steam installed successfully! Version: $version"
                    ;;

                "Lutris")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman lutris
                        version=$(get_version lutris)
                    elif [[ $distro -eq 2 ]]; then
                        $pkg_manager lutris
                        version=$(get_version lutris)
                    else
                        $pkg_manager lutris
                        version=$(get_version lutris)
                    fi
                    echo "Lutris installed successfully! Version: $version"
                    ;;

                "Heroic Games Launcher")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur heroic-games-launcher-bin
                        version=$(get_version heroic-games-launcher-bin)
                    else
                        $flatpak_cmd com.heroicgameslauncher.hgl
                        version="(Flatpak version installed)"
                    fi
                    echo "Heroic Games Launcher installed successfully! Version: $version"
                    ;;

                "ProtonUp-Qt")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur protonup-qt-bin
                        version=$(get_version protonup-qt-bin)
                    else
                        $flatpak_cmd net.davidotek.pupgui2
                        version="(Flatpak version installed)"
                    fi
                    echo "ProtonUp-Qt installed successfully! Version: $version"
                    ;;

                "MangoHud")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman mangohud
                        version=$(get_version mangohud)
                    elif [[ $distro -eq 2 ]]; then
                        $pkg_manager mangohud
                        version=$(get_version mangohud)
                    else
                        $pkg_manager mangohud
                        version=$(get_version mangohud)
                    fi
                    echo "MangoHud installed successfully! Version: $version"
                    ;;

                "GameMode")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman gamemode
                        version=$(get_version gamemode)
                    elif [[ $distro -eq 2 ]]; then
                        $pkg_manager gamemode
                        version=$(get_version gamemode)
                    else
                        $pkg_manager gamemode
                        version=$(get_version gamemode)
                    fi
                    echo "GameMode installed successfully! Version: $version"
                    ;;

            esac
        done

        echo "All selected Gaming Platform have been installed."
        read -rp "Press Enter to continue..."
    done
}
