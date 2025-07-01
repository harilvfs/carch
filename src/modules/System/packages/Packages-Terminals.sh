#!/usr/bin/env bash

install_terminals() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager="sudo pacman -S --noconfirm"
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        install_flatpak
        pkg_manager="sudo dnf install -y"
        flatpak_cmd="flatpak install -y --noninteractive flathub"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${RESET}"
        return
    fi

    while true; do
        clear

        options=("Alacritty" "Kitty" "St" "Terminator" "Tilix" "Hyper" "GNOME Terminal" "Konsole" "WezTerm" "Ghostty" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=50% \
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
                "Alacritty")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager alacritty
                    else
                        $pkg_manager alacritty
                    fi
                    version=$(get_version alacritty)
                    echo "Alacritty installed successfully! Version: $version"
                    ;;

                "Kitty")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager kitty
                    else
                        $pkg_manager kitty
                    fi
                    version=$(get_version kitty)
                    echo "Kitty installed successfully! Version: $version"
                    ;;

                "St")
                    clear
                    if [[ distro -eq 0 ]]; then
                        $pkg_manager_aur st
                        version=$(get_version st)
                    else
                        $pkg_manager st
                        version=$(get_version st)
                    fi
                    echo "St Terminal installed successfully! Version: $version"
                    ;;

                "Terminator")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur terminator
                        version=$(get_version terminator)
                    else
                        $pkg_manager terminator
                        version=$(get_version terminator)
                    fi
                    echo "Terminator installed successfully! Version: $version"
                    ;;

                "Tilix")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur tilix
                        version=$(get_version tilix)
                    else
                        $pkg_manager tilix
                        version=$(get_version tilix)
                    fi
                    echo "Tilix installed successfully! Version: $version"
                    ;;

                "Hyper")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur hyper
                        version=$(get_version hyper)
                    else
                        echo "Hyper is not directly available in Fedora repositories."
                        echo "Download from: [Hyper Website](https://hyper.is/)"
                        version="(Manual installation required)"
                    fi
                    echo "Hyper installation completed! Version: $version"
                    ;;

                "GNOME Terminal")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager gnome-terminal
                    else
                        $pkg_manager gnome-terminal
                    fi
                    version=$(get_version gnome-terminal)
                    echo "GNOME Terminal installed successfully! Version: $version"
                    ;;

                "Konsole")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager konsole
                    else
                        $pkg_manager konsole
                    fi
                    version=$(get_version konsole)
                    echo "Konsole installed successfully! Version: $version"
                    ;;

                "WezTerm")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager wezterm
                        version=$(get_version wezterm)
                        echo "WezTerm installed successfully! Version: $version"
                    elif [[ $distro -eq 1 ]]; then
                        if sudo dnf list --installed wezterm &> /dev/null; then
                            version=$(get_version wezterm)
                            echo "WezTerm is already installed! Version: $version"
                        else
                            sudo dnf install -y wezterm
                            if [[ $? -ne 0 ]]; then
                                $flatpak_cmd org.wezfurlong.wezterm
                                version="(Flatpak version installed)"
                            else
                                version=$(get_version wezterm)
                            fi
                            echo "WezTerm installed successfully! Version: $version"
                        fi
                    fi
                    ;;

                "Ghostty")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager ghostty
                    elif [[ $distro -eq 1 ]]; then
                        sudo dnf copr enable pgdev/ghostty -y
                        sudo dnf install -y ghostty
                    fi
                    version=$(get_version ghostty)
                    echo "Ghostty installed successfully! Version: $version"
                    ;;

            esac
        done

        echo "All selected Terminals Package have been installed."
        read -rp "Press Enter to continue..."
    done
}
