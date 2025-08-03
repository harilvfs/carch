#!/usr/bin/env bash

install_multimedia() {
    while true; do
        clear
        local options
        if [[ "$DISTRO" == "openSUSE" ]]; then
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
                install_package "vlc" "org.videolan.VLC"
                ;;

            "MPV")
                clear
                install_package "mpv" "io.mpv.Mpv"
                ;;

            "Netflix [Unofficial]")
                clear
                case "$DISTRO" in
                    "Arch")
                        install_package "netflix" ""
                        ;;
                    "Fedora")
                        echo "Netflix Unofficial requires manual installation on Fedora"
                        echo "Installing required dependencies:"
                        sudo dnf install -y wget opencl-utils
                        echo "Installing Microsoft Core Fonts:"
                        sudo yum -y localinstall http://sourceforge.net/projects/postinstaller/files/fuduntu/msttcorefonts-2.0-2.noarch.rpm
                        echo "Installing Wine Silverlight & Netflix Desktop:"
                        sudo yum -y install http://sourceforge.net/projects/postinstaller/files/fedora/releases/19/x86_64/updates/wine-silverligh-1.7.2-1.fc19.x86_64.rpm
                        sudo yum -y install http://sourceforge.net/projects/postinstaller/files/fedora/releases/19/x86_64/updates/netflix-desktop-0.7.0-7.fc19.noarch.rpm
                        ;;
                esac
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
