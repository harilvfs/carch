#!/usr/bin/env bash

clear

RED="\033[1;31m"
GREEN="\033[1;32m"
CYAN="\033[1;36m"
BLUE="\033[1;34m"
RESET="\033[0m"

echo -e "${BLUE}"
figlet -f slant "Helix"
echo -e "${RESET}"

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO=${ID_LIKE:-$ID}
    case "$DISTRO" in
        *arch*) DISTRO="arch" ;;
        *fedora*) DISTRO="fedora" ;;
        *)
            gum style --foreground "$RED" "❌ Unsupported distribution!"
            exit 1
            ;;
    esac
else
    gum style --foreground "$RED" "❌ OS information not found!"
    exit 1
fi

gum confirm "⚠️ This script will configure Helix editor. Do you want to continue?" || exit 0

install_helix() {
    gum style --foreground "$CYAN" "⚡ Installing Helix editor..."

    if [[ $DISTRO == "arch" ]]; then
        sudo pacman -S --noconfirm helix noto-fonts-emoji ttf-joypixels git
    elif [[ $DISTRO == "fedora" ]]; then
        sudo dnf install -y helix google-noto-color-emoji-fonts google-noto-emoji-fonts git
    fi
}

install_helix

HELIX_CONFIG="$HOME/.config/helix"

if [[ -d "$HELIX_CONFIG" ]]; then
    gum confirm "⚠️ Existing Helix config found. Do you want to back it up?" && {
        BACKUP_PATH="$HOME/.config/helix.bak.$(date +%s)"
        mv "$HELIX_CONFIG" "$BACKUP_PATH"
        gum style --foreground "$GREEN" "✅ Backup created at $BACKUP_PATH"
    }
fi

gum spin --title "Cloning Helix configuration..." -- git clone --depth=1 https://github.com/harilvfs/dwm "$HOME/dwm"

if [[ -d "$HOME/dwm/config/helix" ]]; then
    gum spin --title "Applying Helix configuration..." -- cp -r "$HOME/dwm/config/helix" "$HELIX_CONFIG"
    gum style --foreground "$GREEN" "✅ Helix configuration applied!"
    rm -rf "$HOME/dwm"
else
    gum style --foreground "$RED" "❌ Failed to apply Helix configuration!"
    exit 1
fi

gum style --foreground "$CYAN" "⚡ Helix setup complete! Restart your editor to apply changes."

