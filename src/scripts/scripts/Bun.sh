#!/bin/bash

clear

BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

echo -e "${BLUE}"
figlet -f slant "Bun"
echo -e "${RESET}"

if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    DISTRO="$ID"
    DISTRO_LIKE="${ID_LIKE}" 
else
    gum style --foreground "$RED" "❌ Unable to detect your Linux distribution!"
    exit 1
fi

if [[ "$DISTRO" == "arch" || "$ID_LIKE" == "arch" ]]; then
    PACKAGE_MANAGER="pacman"
elif [[ "$DISTRO" == "fedora" || "$ID_LIKE" == "rhel" || "$ID_LIKE" == "centos" ]]; then
    PACKAGE_MANAGER="dnf"
else
    gum style --foreground "$RED" "❌ Unsupported distribution!"
    exit 1
fi

if command -v bun &>/dev/null; then
    gum style --foreground "$GREEN" "✅ Bun is already installed!"
    exit 0
fi

if ! command -v npm &>/dev/null; then
    gum style --foreground "$RED" "❌ npm is not installed!"
    gum style --bold --foreground "$YELLOW" "ℹ Please install npm first from the main script before installing Bun."
    exit 1
fi

gum confirm "⚠ npm is required to install Bun. Do you want to continue?" || exit 0

gum spin --title "Installing Bun via npm..." -- npm install -g bun

if command -v bun &>/dev/null; then
    gum style --foreground "$GREEN" "✅ Bun installed successfully!"
    exit 0
else
    gum style --foreground "$RED" "❌ npm install -g bun failed! Trying alternate method..."
fi

if [[ "$PACKAGE_MANAGER" == "pacman" ]]; then
    gum spin --title "Installing unzip..." -- sudo pacman -S --noconfirm unzip
elif [[ "$PACKAGE_MANAGER" == "dnf" ]]; then
    gum spin --title "Installing unzip..." -- sudo dnf install -y unzip
fi

gum spin --title "Installing Bun via curl..." -- bash -c "$(curl -fsSL https://bun.sh/install)"

if command -v bun &>/dev/null; then
    gum style --foreground "$GREEN" "✅ Bun installed successfully!"
else
    gum style --foreground "$RED" "❌ Bun installation failed! Please check your internet connection and try again."
fi

