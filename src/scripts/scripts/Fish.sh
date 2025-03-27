#!/usr/bin/env bash

clear

GREEN="#a6e3a1"
CYAN="#89dceb"
RED="#f38ba8"
BLUE="\033[1;34m"
RESET="\033[0m"

echo -e "${BLUE}"
if command -v figlet &>/dev/null; then
    figlet -f slant "Fish"
else
    echo "========== Fish Setup =========="
fi
echo -e "${RESET}"

fzf_confirm() {
    local prompt="$1"
    local options=("Yes" "No")
    local selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="$prompt " --height=10 --layout=reverse --border)
    
    if [[ "$selected" == "Yes" ]]; then
        return 0
    else
        return 1
    fi
}

print_color() {
    local color="$1"
    local message="$2"
    echo -e "\e[38;2;$(echo $color | sed 's/#//;s/\(..\)\(..\)\(..\)/\1;\2;\3/') m$message\e[0m"
}

detect_distro() {
    if command -v pacman &>/dev/null; then
        DISTRO="arch"
    elif command -v dnf &>/dev/null; then
        DISTRO="fedora"
    else
        print_color "$RED" "❌ Unsupported distribution!"
        exit 1
    fi
}

install_fish() {
    print_color "$CYAN" "🐟 Installing Fish shell..."
    
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm fish noto-fonts-emoji ttf-joypixels git
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y fish google-noto-color-emoji-fonts google-noto-emoji-fonts git
    else
        print_color "$RED" "❌ Unsupported distro: $DISTRO"
        exit 1
    fi
}

install_zoxide() {
    print_color "$CYAN" "Installing zoxide..."
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm zoxide
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y zoxide
    else
        print_color "$RED" "❌ Unsupported distro: $DISTRO"
        exit 1
    fi
}

detect_distro

fzf_confirm "⚠️ This script will configure Fish shell. Nerd Font Are Recommended. Do you want to continue?" || exit 0

install_fish

FISH_CONFIG="$HOME/.config/fish"
if [[ -d "$FISH_CONFIG" ]]; then
    fzf_confirm "⚠️ Existing Fish config found. Do you want to back it up?" && {
        BACKUP_PATH="$HOME/.config/fish.bak.$(date +%s)"
        mv "$FISH_CONFIG" "$BACKUP_PATH"
        print_color "$GREEN" "✅ Backup created at $BACKUP_PATH"
    }
fi

echo "Cloning Fish configuration..."
git clone --depth=1 https://github.com/harilvfs/dwm "$HOME/dwm"
if [[ -d "$HOME/dwm/config/fish" ]]; then
    echo "Applying Fish configuration..."
    cp -r "$HOME/dwm/config/fish" "$FISH_CONFIG"
    print_color "$GREEN" "✅ Fish configuration applied!"
    rm -rf "$HOME/dwm"
else
    print_color "$RED" "❌ Failed to apply Fish configuration!"
    exit 1
fi

install_zoxide
print_color "$GREEN" "✅ Zoxide initialized in Fish!"
print_color "$CYAN" "🐟 Fish setup complete! Restart your shell to apply changes."
