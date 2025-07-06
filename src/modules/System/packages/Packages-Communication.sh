#!/usr/bin/env bash

install_communication() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager="$AUR_HELPER -S --noconfirm"
    elif [[ $distro -eq 1 ]]; then
        install_flatpak
        flatpak_cmd="flatpak install -y --noninteractive flathub"
        pkg_manager="install_fedora_package"
    else
        echo -e "${RED}:: Unsupported system. Exiting.${NC}"
        return
    fi

    while true; do
        clear

        options=("Discord" "Better Discord" "Signal" "Element (Matrix)" "Slack" "Teams" "Zoom" "Telegram" "Keybase" "Zulip" "Back to Main Menu")
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
                "Discord")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager discord
                        version=$(pacman -Qi discord | grep Version | awk '{print $3}')
                        echo "Discord installed successfully! Version: $version"
                    else
                        $pkg_manager "discord" "com.discordapp.Discord"
                        echo "Discord installed successfully!"
                    fi
                    ;;

                "Better Discord")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager betterdiscord-installer-bin
                        echo "Better Discord installed successfully!"
                    else
                        echo -e "${YELLOW}:: Better Discord is not available for Fedora.${NC}"
                    fi
                    ;;

                "Signal")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager signal-desktop
                        version=$(pacman -Qi signal-desktop | grep Version | awk '{print $3}')
                        echo "Signal installed successfully! Version: $version"
                    else
                        $pkg_manager "signal-desktop" "org.signal.Signal"
                        echo "Signal installed successfully!"
                    fi
                    ;;

                "Element (Matrix)")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur element-desktop
                        version=$(get_version element-desktop)
                    else
                        $flatpak_cmd im.riot.Riot
                        version="(Flatpak version installed)"
                    fi
                    echo "Element installed successfully! Version: $version"
                    ;;

                "Slack")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur slack-desktop
                        version=$(get_version slack-desktop)
                    else
                        $flatpak_cmd com.slack.Slack
                        version="(Flatpak version installed)"
                    fi
                    echo "Slack installed successfully! Version: $version"
                    ;;

                "Teams")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur teams
                        version=$(get_version teams)
                        echo "Teams installed successfully! Version: $version"
                    else
                        echo "Microsoft Teams is not available in Fedora's repositories. Use the web version instead: https://teams.microsoft.com"
                    fi
                    ;;

                "Zoom")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur zoom
                        version=$(get_version zoom)
                    else
                        $flatpak_cmd us.zoom.Zoom
                        version="(Flatpak version installed)"
                    fi
                    echo "Zoom installed successfully! Version: $version"
                    ;;

                "Telegram")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager telegram-desktop
                        version=$(pacman -Qi telegram-desktop | grep Version | awk '{print $3}')
                        echo "Telegram installed successfully! Version: $version"
                    else
                        $pkg_manager "telegram-desktop" "org.telegram.desktop"
                        echo "Telegram installed successfully!"
                    fi
                    ;;

                "Keybase")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager keybase-bin
                        version=$(pacman -Qi keybase-bin | grep Version | awk '{print $3}')
                        echo "Keybase installed successfully! Version: $version"
                    else
                        sudo dnf install -y https://prerelease.keybase.io/keybase_amd64.rpm
                        echo "Keybase installed successfully!"
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

            esac
        done

        echo "All selected Communication Apps have been installed."
        read -rp "Press Enter to continue..."
    done
}
