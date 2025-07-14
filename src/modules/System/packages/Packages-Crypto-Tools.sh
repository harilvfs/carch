#!/usr/bin/env bash

install_crypto_tools() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        pkg_manager="sudo dnf install -y"
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

        options=("Electrum" "Back to Main Menu")
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
                "Electrum")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur electrum
                        version=$(get_version electrum)
                        echo "Electrum installed successfully! Version: $version"
                    elif [[ $distro -eq 1 ]]; then
                        $pkg_manager electrum
                        version=$(get_version electrum)
                        echo "Electrum installed successfully! Version: $version"
                    else
                        $flatpak_cmd org.electrum.electrum
                        version="(Flatpak version installed)"
                        echo "Electrum installed successfully! Version: $version"
                    fi
                    ;;
            esac
        done

        echo "All selected Crypto tools have been installed."
        read -rp "Press Enter to continue..."
    done
}
