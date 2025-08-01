#!/usr/bin/env bash

install_multimedia() {
    detect_distro
    distro=$?
    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager="sudo pacman -S --noconfirm"
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        pkg_manager="sudo dnf install -y"
        get_version() { rpm -q "$1"; }
    elif [[ $distro -eq 2 ]]; then
        pkg_manager="sudo zypper install -y"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${NC}"
        return
    fi

    while true; do
        clear
        local options
        if [[ $distro -eq 2 ]]; then
            # for opensuse
            options=("VLC" "MPV" "Back to Main Menu")
        else
            options=("VLC" "MPV" "Netflix [Unofficial]" "Back to Main Menu")
        fi

        show_menu "Multimedia Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "VLC")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur vlc
                    version=$(get_version vlc)
                elif [[ $distro -eq 2 ]]; then
                    $pkg_manager vlc
                    version=$(get_version vlc)
                else
                    $pkg_manager vlc
                    version=$(get_version vlc)
                fi
                echo "VLC installed successfully! Version: $version"
                ;;

            "MPV")
                clear
                $pkg_manager mpv
                version=$(get_version mpv)
                echo "MPV installed successfully! Version: $version"
                ;;

            "Netflix [Unofficial]")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur netflix
                    version=$(get_version netflix)
                elif [[ $distro -eq 1 ]]; then
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
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
