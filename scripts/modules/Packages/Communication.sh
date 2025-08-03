#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

main() {
    while true; do
        clear
        local options=("Discord" "Better Discord" "Signal" "Element (Matrix)" "Slack" "Teams" "Zoom" "Telegram" "Keybase" "Zulip" "ProtonVPN" "Exit")

        show_menu "Communication Apps Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Discord")
                clear
                install_package "discord" "com.discordapp.Discord"
                ;;

            "Better Discord")
                clear
                case "$DISTRO" in
                    "Arch")
                        install_package "betterdiscord-installer-bin" ""
                        ;;
                    *)
                        print_message "$YELLOW" "Better Discord requires manual installation."
                        echo "Please visit https://betterdiscord.app/ and download the AppImage for your system."
                        echo "Make sure to make it executable with: chmod +x BetterDiscord.AppImage"
                        ;;
                esac
                ;;

            "Signal")
                clear
                install_package "signal-desktop" "org.signal.Signal"
                ;;

            "Element (Matrix)")
                clear
                install_package "element-desktop" "im.riot.Riot"
                ;;

            "Slack")
                clear
                install_package "slack-desktop" "com.slack.Slack" "slack-desktop"
                ;;

            "Teams")
                clear
                case "$DISTRO" in
                    "Arch")
                        install_package "teams" ""
                        ;;
                    *)
                        echo "Microsoft Teams is not available in the repositories. Use the web version instead: https://teams.microsoft.com"
                        ;;
                esac
                ;;

            "Zoom")
                clear
                install_package "zoom" "us.zoom.Zoom"
                ;;

            "Telegram")
                clear
                install_package "telegram-desktop" "org.telegram.desktop"
                ;;

            "Keybase")
                clear
                case "$DISTRO" in
                    "Arch")
                        install_package "keybase-bin" ""
                        ;;
                    "Fedora")
                        install_package "https://prerelease.keybase.io/keybase_amd64.rpm" ""
                        ;;
                    "openSUSE")
                        install_package "keybase-client" ""
                        ;;
                esac
                ;;

            "Zulip")
                clear
                install_package "zulip-desktop-bin" "org.zulip.Zulip" "zulip-desktop"
                ;;

            "ProtonVPN")
                clear
                case "$DISTRO" in
                    "Arch")
                        install_package "proton-vpn-gtk-app" ""
                        ;;
                    "Fedora")
                        print_message "$GREEN" "Installing ProtonVPN for Fedora..."
                        local temp_dir
                        temp_dir=$(mktemp -d)
                        (   
                            cd "$temp_dir" || exit 1
                            wget "https://repo.protonvpn.com/fedora-$(cut -d' ' -f 3 < /etc/fedora-release)-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.3-1.noarch.rpm"
                            sudo dnf install -y ./protonvpn-stable-release-1.0.3-1.noarch.rpm
                            sudo dnf check-update --refresh
                            sudo dnf install -y proton-vpn-gnome-desktop libappindicator-gtk3 gnome-shell-extension-appindicator gnome-extensions-app
                        )
                        rm -rf "$temp_dir"
                        print_message "$GREEN" "ProtonVPN installed successfully!"
                        ;;
                    "openSUSE")
                        install_package "protonvpn-gui" ""
                        ;;
                esac
                ;;
            "Exit")
                exit 0
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
