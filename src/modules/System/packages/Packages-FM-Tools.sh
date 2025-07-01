#!/usr/bin/env bash

install_fm_tools() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        pkg_manager="sudo pacman -S --noconfirm"
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

        options=("Tumbler [Thumbnail Viewer]" "Trash-Cli" "Back to Main Menu")
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
                "Tumbler [Thumbnail Viewer]")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager tumbler
                    else
                        $pkg_manager tumbler
                    fi
                    version=$(get_version tumbler)
                    echo "Tumbler installed successfully! Version: $version"
                    ;;

                "Trash-Cli")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager trash-cli
                    else
                        $pkg_manager trash-cli
                    fi
                    version=$(get_version trash-cli)
                    echo "Trash-Cli installed successfully! Version: $version"
                    ;;

            esac
        done

        echo "All selected FM tools have been installed."
        read -rp "Press Enter to continue..."
    done
}
