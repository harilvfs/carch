#!/usr/bin/env bash

# Installs and configures the Fish shell, offering an interactive and user-friendly command-line environment with advanced features such as auto-suggestions and a clean syntax.

clear

GREEN="\033[0;32m"
CYAN="\033[0;36m"
RED="\033[0;31m"
RESET="\033[0m"

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

fzf_confirm() {
    local prompt="$1"
    local options=("Yes" "No")
    local selected=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                     --height=40% \
                                                     --prompt="$prompt " \
                                                     --header="Confirm" \
                                                     --pointer="➤" \
                                                     --color='fg:white,fg+:green,bg+:black,pointer:green')

    if [[ "$selected" == "Yes" ]]; then
        return 0
    else
        return 1
    fi
}

print_color() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${RESET}"
}

detect_distro() {
    if command -v pacman &>/dev/null; then
        DISTRO="arch"
    elif command -v dnf &>/dev/null; then
        DISTRO="fedora"
    else
        print_color "$RED" "Unsupported distribution!"
        exit 1
    fi
}

install_fish() {
    print_color "$CYAN" "Installing Fish shell..."

    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm fish noto-fonts-emoji git
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y fish google-noto-color-emoji-fonts google-noto-emoji-fonts git
    else
        print_color "$RED" "Unsupported distro: $DISTRO"
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
        print_color "$RED" "Unsupported distro: $DISTRO"
        exit 1
    fi
}

detect_distro

install_fish

FISH_CONFIG="$HOME/.config/fish"
if [[ -d "$FISH_CONFIG" ]]; then
    fzf_confirm "Existing Fish config found. Do you want to back it up?" && {
        BACKUP_PATH="$HOME/.config/fish.bak.$(date +%s)"
        mv "$FISH_CONFIG" "$BACKUP_PATH"
        print_color "$GREEN" "Backup created at $BACKUP_PATH"
    }
fi

echo "Cloning Fish configuration..."
git clone --depth=1 https://github.com/harilvfs/dwm "$HOME/dwm"
if [[ -d "$HOME/dwm/config/fish" ]]; then
    echo "Applying Fish configuration..."
    cp -r "$HOME/dwm/config/fish" "$FISH_CONFIG"
    print_color "$GREEN" "Fish configuration applied!"
    rm -rf "$HOME/dwm"
else
    print_color "$RED" "Failed to apply Fish configuration!"
    exit 1
fi


CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
FISH_PATH=$(command -v fish)

if [[ "$CURRENT_SHELL" == "$FISH_PATH" ]]; then
    print_color "$GREEN" "Fish is already your default shell."
else
    fzf_confirm "Fish is not your default shell. Set it as default?" && {
        print_color "$CYAN" "Setting Fish as your default shell..."
        chsh -s "$FISH_PATH"
        print_color "$GREEN" "Fish is now set as your default shell!"
    }
fi

install_zoxide
print_color "$GREEN" "Zoxide initialized in Fish!"
print_color "$CYAN" "Fish setup complete! Restart your shell to apply changes."
