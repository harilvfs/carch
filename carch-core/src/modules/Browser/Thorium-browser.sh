#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_thorium_browser() {
    clear
    case "$DISTRO" in
        "Arch")
            install_package "thorium-browser-bin" ""
            ;;
        "Fedora" | "openSUSE")
            print_message "$YELLOW" "Downloading and installing Thorium Browser..."

            if ! command -v wget &> /dev/null; then
                print_message "$GREEN" "Installing wget..."
                case "$DISTRO" in
                    "Fedora") sudo dnf install -y wget ;;
                    "openSUSE") sudo zypper install -y wget ;;
                esac
            fi

            temp_dir=$(mktemp -d)
            cd "$temp_dir" || {
                print_message "$RED" "Failed to create temp directory"
                return
            }

            print_message "$GREEN" "Fetching latest Thorium Browser release..."
            wget -q --show-progress https://github.com/Alex313031/thorium/releases/latest -O latest
            latest_url=$(grep -o 'https://github.com/Alex313031/thorium/releases/tag/[^"\n]*' latest | head -1)
            latest_version=$(echo "$latest_url" | grep -o '[^/]*$')

            print_message "$GREEN" "Latest version: $latest_version"
            print_message "$GREEN" "Downloading Thorium Browser AVX package..."
            wget -q --show-progress "https://github.com/Alex313031/thorium/releases/download/$latest_version/thorium-browser_${latest_version#M}_AVX.rpm" ||
                wget -q --show-progress "https://github.com/Alex313031/thorium/releases/download/$latest_version/thorium-browser_*_AVX.rpm"

            rpm_file=$(ls thorium*AVX.rpm 2> /dev/null)
            if [ -n "$rpm_file" ]; then
                print_message "$GREEN" "Installing Thorium Browser..."
                case "$DISTRO" in
                    "Fedora") sudo dnf install -y "./$rpm_file" ;;
                    "openSUSE") sudo zypper install -y "./$rpm_file" ;;
                esac
            else
                print_message "$RED" "Failed to download Thorium Browser. Please visit https://thorium.rocks/."
            fi

            cd - > /dev/null || return
            rm -rf "$temp_dir"
            ;;
    esac
}

install_thorium_browser
