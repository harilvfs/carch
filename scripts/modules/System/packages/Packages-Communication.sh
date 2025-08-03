#!/usr/bin/env bash

install_communication() {
    case "$DISTRO" in
        "Arch")
            install_aur_helper
            pkg_manager="sudo pacman -S --noconfirm"
            pkg_manager_aur="$AUR_HELPER -S --noconfirm"
            ;;
        "Fedora")
            install_flatpak
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            pkg_manager="sudo dnf install -y"
            ;;
        "openSUSE")
            install_flatpak
            pkg_manager="sudo zypper install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            ;;
        *)
            exit 1
            ;;
    esac

    while true; do
        clear

        local options=("Discord" "Better Discord" "Signal" "Element (Matrix)" "Slack" "Teams" "Zoom" "Telegram" "Keybase" "Zulip" "ProtonVPN" "Back to Main Menu")

        show_menu "Communication Apps Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Discord")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager discord
                        ;;
                    "Fedora")
                        $pkg_manager "discord" "com.discordapp.Discord"
                        ;;
                    "openSUSE")
                        $pkg_manager discord
                        ;;
                esac
                ;;

            "Better Discord")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur betterdiscord-installer-bin
                        ;;
                    *)
                        echo -e "${YELLOW}:: Better Discord requires manual installation.${NC}"
                        echo "Please visit https://betterdiscord.app/ and download the AppImage for your system."
                        echo "Make sure to make it executable with: chmod +x BetterDiscord.AppImage"
                        ;;
                esac
                ;;

            "Signal")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager signal-desktop
                        ;;
                    "Fedora")
                        $pkg_manager "signal-desktop" "org.signal.Signal"
                        ;;
                    "openSUSE")
                        $flatpak_cmd org.signal.Signal
                        ;;
                esac
                ;;

            "Element (Matrix)")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager element-desktop
                        ;;
                    *)
                        $flatpak_cmd im.riot.Riot
                        ;;
                esac
                ;;

            "Slack")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur slack-desktop
                        ;;
                    *)
                        $flatpak_cmd com.slack.Slack
                        ;;
                esac
                ;;

            "Teams")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur teams
                        ;;
                    *)
                        echo "Microsoft Teams is not available in the repositories. Use the web version instead: https://teams.microsoft.com"
                        ;;
                esac
                ;;

            "Zoom")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur zoom
                        ;;
                    *)
                        $flatpak_cmd us.zoom.Zoom
                        ;;
                esac
                ;;

            "Telegram")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager telegram-desktop
                        ;;
                    "Fedora")
                        $pkg_manager telegram-desktop
                        ;;
                    "openSUSE")
                        $flatpak_cmd org.telegram.desktop
                        ;;
                esac
                ;;

            "Keybase")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur keybase-bin
                        ;;
                    "Fedora")
                        $pkg_manager https://prerelease.keybase.io/keybase_amd64.rpm
                        ;;
                    "openSUSE")
                        $pkg_manager keybase-client
                        ;;
                esac
                ;;

            "Zulip")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur zulip-desktop-bin
                        ;;
                    *)
                        $flatpak_cmd org.zulip.Zulip
                        ;;
                esac
                ;;

            "ProtonVPN")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager proton-vpn-gtk-app
                        ;;
                    "Fedora")
                        echo "Installing ProtonVPN for Fedora..."
                        temp_dir=$(mktemp -d)
                        (   
                            cd "$temp_dir" || exit 1
                            wget "https://repo.protonvpn.com/fedora-$(cut -d' ' -f 3 < /etc/fedora-release)-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.3-1.noarch.rpm"
                            sudo dnf install -y ./protonvpn-stable-release-1.0.3-1.noarch.rpm
                            sudo dnf check-update --refresh
                            sudo dnf install -y proton-vpn-gnome-desktop libappindicator-gtk3 gnome-shell-extension-appindicator gnome-extensions-app
                        )
                        rm -rf "$temp_dir"
                        echo "ProtonVPN installed successfully!"
                        ;;
                    "openSUSE")
                        $pkg_manager protonvpn-gui
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
