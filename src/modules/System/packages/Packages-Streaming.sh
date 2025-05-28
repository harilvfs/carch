#!/usr/bin/env bash

install_streaming() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager_pacman="sudo pacman -S --noconfirm"
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        pkg_manager="sudo dnf install -y"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${RESET}"
        return
    fi

    while true; do
        clear

        options=("OBS Studio" "SimpleScreenRecorder [Git]" "Back to Main Menu")
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
            "OBS Studio")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman obs-studio
                    version=$(get_version obs-studio)
                else
                    $pkg_manager obs-studio
                    version=$(get_version obs-studio)
                fi
                echo "OBS Studio installed successfully! Version: $version"
                ;;

            "SimpleScreenRecorder [Git]")
                clear
                if [[ $distro -eq 0 ]]; then
                    read -rp "The Git version builds from source and may take some time. Proceed? (y/N) " confirm
                    if [[ $confirm =~ ^[Yy]$ ]]; then
                        $pkg_manager_aur simplescreenrecorder-git
                        version=$(get_version simplescreenrecorder-git)
                        echo "SimpleScreenRecorder [Git] installed successfully! Version: $version"
                    else
                        echo "Installation aborted."
                    fi
                else
                    echo -e "${YELLOW}:: SimpleScreenRecorder [Git] is not available on Fedora.${RESET}"
                fi
                ;;

            esac
        done

        echo "All selected Streaming tools have been installed."
        read -rp "Press Enter to continue..."
    done
}
