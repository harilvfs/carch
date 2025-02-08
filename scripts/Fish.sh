#!/usr/bin/env bash

clear

GREEN="#a6e3a1"
CYAN="#89dceb"
RED="#f38ba8"
BLUE="\033[1;34m"
RESET="\033[0m"

echo -e "${BLUE}"
figlet -f slant "Fish"
echo -e "${RESET}"

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO=$ID
else
    gum style --foreground "$RED" "❌ Unsupported distribution!"
    exit 1
fi

gum confirm "⚠️ This script will configure Fish shell. Nerd Font Are Recommended. Do you want to continue?" || exit 0

install_fish() {
    gum style --foreground "$CYAN" "🐟 Installing Fish shell..."
    if [[ $DISTRO == "arch" ]]; then
        sudo pacman -S --noconfirm fish noto-fonts-emoji ttf-joypixels
    elif [[ $DISTRO == "fedora" ]]; then
        sudo dnf install -y fish google-noto-color-emoji-fonts google-noto-emoji-fonts
    fi
}

install_fish

FISH_CONFIG="$HOME/.config/fish"

if [[ -d "$FISH_CONFIG" ]]; then
    gum confirm "⚠️ Existing Fish config found. Do you want to back it up?" && {
        BACKUP_PATH="$HOME/.config/fish.bak.$(date +%s)"
        mv "$FISH_CONFIG" "$BACKUP_PATH"
        gum style --foreground "$GREEN" "✅ Backup created at $BACKUP_PATH"
    }
fi

gum spin --title "Cloning Fish configuration..." -- git clone --depth=1 https://github.com/harilvfs/dwm "$HOME/dwm"

if [[ -d "$HOME/dwm/config/fish" ]]; then
    gum spin --title "Applying Fish configuration..." -- cp -r "$HOME/dwm/config/fish" "$FISH_CONFIG"
    gum style --foreground "$GREEN" "✅ Fish configuration applied!"
    rm -rf "$HOME/dwm"
else
    gum style --foreground "$RED" "❌ Failed to apply Fish configuration!"
    exit 1
fi

install_zoxide() {
    if [[ $DISTRO == "arch" ]]; then
        gum spin --title "Installing zoxide..." -- sudo pacman -S --noconfirm zoxide
    elif [[ $DISTRO == "fedora" ]]; then
        gum spin --title "Installing zoxide..." -- sudo dnf install -y zoxide
    fi
}

echo "zoxide init fish | source" >>"$FISH_CONFIG/config.fish"
gum style --foreground "$GREEN" "✅ Zoxide initialized in Fish!"

gum style --foreground "$CYAN" "🐟 Fish setup complete! Restart your shell to apply changes."

