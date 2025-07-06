#!/usr/bin/env bash

install_multimedia() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        pkg_manager="sudo dnf install -y"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${NC}"
        return
    fi

    while true; do
        clear

        options=("VLC" "Netflix [Unofficial]" "Back to Main Menu")
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
                "VLC")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur vlc
                        version=$(get_version vlc)
                    else
                        $pkg_manager vlc
                        version=$(get_version vlc)
                    fi
                    echo "VLC installed successfully! Version: $version"
                    ;;

                "Netflix [Unofficial]")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur netflix
                        version=$(get_version netflix)
                    else
                        echo "Netflix Unofficial requires manual installation on Fedora"
                        echo "Installing required dependencies:"
                        sudo dnf install -y wget opencl-utils
                        echo "Installing Microsoft Core Fonts:"
                        sudo yum -y localinstall http://sourceforge.net/projects/postinstaller/files/fuduntu/msttcorefonts-2.0-2.noarch.rpm
                        echo "Installing Wine Silverlight & Netflix Desktop:"
                        sudo yum -y install http://sourceforge.net/projects/postinstaller/files/fedora/releases/19/x86_64/updates/wine-silverligh-1.7.2-1.fc19.x86_64.rpm
                        sudo yum -y install http://sourceforge.net/projects/postinstaller/files/fedora/releases/19/x86_64/updates/netflix-desktop-0.7.0-7.fc19.noarch.rpm

                        version="(Manual installation required)"
                    fi
                    echo "Netflix [Unofficial] installed successfully! Version: $version"
                    ;;

            esac
        done

        echo "All selected Multimedia tools have been installed."
        read -rp "Press Enter to continue..."
    done
}
