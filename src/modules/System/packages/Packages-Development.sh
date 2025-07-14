#!/usr/bin/env bash

install_development() {
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

        options=("Node.js" "Python" "Rust" "Go" "Docker" "Postman" "DBeaver" "Hugo" "Back to Main Menu")
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
                "Node.js")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman nodejs npm
                        version=$(get_version nodejs)
                    elif [[ $distro -eq 1 ]]; then
                        $pkg_manager nodejs-npm
                        version=$(get_version nodejs)
                    else
                        $pkg_manager nodejs
                        version=$(get_version nodejs)
                    fi
                    echo "Node.js installed successfully! Version: $version"
                    ;;

                "Python")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman python python-pip
                        version=$(get_version python)
                    elif [[ $distro -eq 1 ]]; then
                        $pkg_manager python3 python3-pip
                        version=$(get_version python3)
                    else
                        $pkg_manager python313
                        version=$(get_version python313)
                    fi
                    echo "Python installed successfully! Version: $version"
                    ;;

                "Rust")
                    clear
                    bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
                    source "$HOME/.cargo/env"
                    version=$(rustc --version | awk '{print $2}')
                    echo "Rust installed successfully! Version: $version"
                    ;;

                "Go")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman go
                        version=$(get_version go)
                    elif [[ $distro -eq 1 ]]; then
                        $pkg_manager golang
                        version=$(get_version golang)
                    else
                        $pkg_manager go
                        version=$(get_version go)
                    fi
                    echo "Go installed successfully! Version: $version"
                    ;;

                "Docker")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman docker
                    elif [[ $distro -eq 1 ]]; then
                        $pkg_manager docker
                    else
                        $pkg_manager docker
                    fi
                    sudo systemctl enable --now docker
                    sudo usermod -aG docker "$USER"
                    version=$(get_version docker)
                    echo "Docker installed successfully! Version: $version"
                    echo "Note: You may need to log out and back in for group changes to take effect."
                    ;;

                "Postman")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur postman-bin
                        version=$(get_version postman-bin)
                    else
                        $flatpak_cmd com.getpostman.Postman
                        version="(Flatpak version installed)"
                    fi
                    echo "Postman installed successfully! Version: $version"
                    ;;

                "DBeaver")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman dbeaver
                        version=$(get_version dbeaver)
                    else
                        $flatpak_cmd io.dbeaver.DBeaverCommunity
                        version="(Flatpak version installed)"
                    fi
                    echo "DBeaver installed successfully! Version: $version"
                    ;;

                "Hugo")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman hugo
                        version=$(get_version hugo)
                    elif [[ $distro -eq 1 ]]; then
                        $pkg_manager hugo
                        version=$(get_version hugo)
                    else
                        $pkg_manager hugo
                        version=$(get_version hugo)
                    fi
                    echo "Hugo installed successfully! Version: $version"
                    ;;

            esac
        done

        echo "All selected Development tools have been installed."
        read -rp "Press Enter to continue..."
    done
}
