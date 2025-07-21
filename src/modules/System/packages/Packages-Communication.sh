#!/usr/bin/env bash

install_communication() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager="$AUR_HELPER -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        install_flatpak
        flatpak_cmd="flatpak install -y --noninteractive flathub"
        pkg_manager="install_fedora_package"
    elif [[ $distro -eq 2 ]]; then
        install_flatpak
        pkg_manager="sudo zypper install -y"
        flatpak_cmd="flatpak install -y --noninteractive flathub"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported system. Exiting.${NC}"
        return
    fi

    while true; do
        clear

        local options=("Discord" "Better Discord" "Signal" "Element (Matrix)" "Slack" "Teams" "Zoom" "Telegram" "Keybase" "Zulip" "Back to Main Menu")

        show_menu "Communication Apps Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Discord")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager discord
                    version=$(pacman -Qi discord | grep Version | awk '{print $3}')
                    echo "Discord installed successfully! Version: $version"
                elif [[ $distro -eq 1 ]]; then
                    $pkg_manager "discord" "com.discordapp.Discord"
                    echo "Discord installed successfully!"
                else
                    $pkg_manager discord
                    version=$(get_version discord)
                    echo "Discord installed successfully! Version: $version"
                fi
                ;;

            "Better Discord")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager betterdiscord-installer-bin
                    echo "Better Discord installed successfully!"
                else
                    echo -e "${YELLOW}:: Better Discord requires manual installation.${NC}"
                    echo "Please visit https://betterdiscord.app/ and download the AppImage for your system."
                    echo "Make sure to make it executable with: chmod +x BetterDiscord.AppImage"
                fi
                ;;

            "Signal")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager signal-desktop
                    version=$(pacman -Qi signal-desktop | grep Version | awk '{print $3}')
                    echo "Signal installed successfully! Version: $version"
                elif [[ $distro -eq 1 ]]; then
                    $pkg_manager "signal-desktop" "org.signal.Signal"
                    echo "Signal installed successfully!"
                else
                    $flatpak_cmd org.signal.Signal
                    version="(Flatpak version installed)"
                    echo "Signal installed successfully! Version: $version"
                fi
                ;;

            "Element (Matrix)")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager element-desktop
                    version=$(get_version element-desktop)
                    echo "Element installed successfully! Version: $version"
                else
                    $flatpak_cmd im.riot.Riot
                    version="(Flatpak version installed)"
                    echo "Element installed successfully! Version: $version"
                fi
                ;;

            "Slack")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager slack-desktop
                    version=$(get_version slack-desktop)
                    echo "Slack installed successfully! Version: $version"
                else
                    $flatpak_cmd com.slack.Slack
                    version="(Flatpak version installed)"
                    echo "Slack installed successfully! Version: $version"
                fi
                ;;

            "Teams")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager teams
                    version=$(get_version teams)
                    echo "Teams installed successfully! Version: $version"
                else
                    echo "Microsoft Teams is not available in the repositories. Use the web version instead: https://teams.microsoft.com"
                fi
                ;;

            "Zoom")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager zoom
                    version=$(get_version zoom)
                    echo "Zoom installed successfully! Version: $version"
                else
                    $flatpak_cmd us.zoom.Zoom
                    version="(Flatpak version installed)"
                    echo "Zoom installed successfully! Version: $version"
                fi
                ;;

            "Telegram")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager telegram-desktop
                    version=$(pacman -Qi telegram-desktop | grep Version | awk '{print $3}')
                    echo "Telegram installed successfully! Version: $version"
                elif [[ $distro -eq 1 ]]; then
                    $pkg_manager "telegram-desktop" "org.telegram.desktop"
                    echo "Telegram installed successfully!"
                else
                    $flatpak_cmd org.telegram.desktop
                    version="(Flatpak version installed)"
                    echo "Telegram installed successfully! Version: $version"
                fi
                ;;

            "Keybase")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager keybase-bin
                    version=$(pacman -Qi keybase-bin | grep Version | awk '{print $3}')
                    echo "Keybase installed successfully! Version: $version"
                elif [[ $distro -eq 1 ]]; then
                    sudo dnf install -y https://prerelease.keybase.io/keybase_amd64.rpm
                    echo "Keybase installed successfully!"
                else
                    $pkg_manager keybase-client
                    version=$(get_version keybase-client)
                    echo "Keybase installed successfully! Version: $version"
                fi
                ;;

            "Zulip")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager zulip-desktop-bin
                    version=$(pacman -Qi zulip-desktop-bin | grep Version | awk '{print $3}')
                    echo "Zulip installed successfully! Version: $version"
                else
                    $flatpak_cmd org.zulip.Zulip
                    version="(Flatpak version installed)"
                    echo "Zulip installed successfully! Version: $version"
                fi
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
