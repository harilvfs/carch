#!/usr/bin/env bash

install_filemanagers() {
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

        options=("Nemo" "Thunar" "Dolphin" "LF (Terminal File Manager)" "Ranger" "Nautilus" "Yazi" "Back to Main Menu")
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
                "Nemo")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager nemo
                    else
                        $pkg_manager nemo
                    fi
                    version=$(get_version nemo)
                    echo "Nemo installed successfully! Version: $version"
                    ;;

                "Thunar")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager thunar
                    else
                        $pkg_manager thunar
                    fi
                    version=$(get_version thunar)
                    echo "Thunar installed successfully! Version: $version"
                    ;;

                "Dolphin")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager dolphin
                    else
                        $pkg_manager dolphin
                    fi
                    version=$(get_version dolphin)
                    echo "Dolphin installed successfully! Version: $version"
                    ;;

                "LF (Terminal File Manager)")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager lf
                    else
                        sudo dnf copr enable lsevcik/lf -y
                        $pkg_manager lf
                    fi
                    version=$(get_version lf)
                    echo "LF installed successfully! Version: $version"
                    ;;

                "Ranger")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager ranger
                    else
                        $pkg_manager ranger
                    fi
                    version=$(get_version ranger)
                    echo "Ranger installed successfully! Version: $version"
                    ;;

                "Nautilus")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager nautilus
                    else
                        $pkg_manager nautilus
                    fi
                    version=$(get_version nautilus)
                    echo "Nautilus installed successfully! Version: $version"
                    ;;

                "Yazi")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager yazi
                    else
                        sudo dnf copr enable varlad/yazi -y
                        $pkg_manager yazi
                    fi
                    version=$(get_version yazi)
                    echo "Yazi installed successfully! Version: $version"
                    ;;

            esac
        done

        echo "All selected Filemanagers have been installed."
        read -rp "Press Enter to continue..."
    done
}
