#!/usr/bin/env bash

# Installs and configures the Helix text editor, providing a modern and feature-rich code editing environment optimized for both performance and ease of use.

clear

RED="\033[1;31m"
GREEN="\033[1;32m"
CYAN="\033[1;36m"
BLUE="\033[1;34m"
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

if ! command -v fzf &>/dev/null; then
    echo -e "${RED}fzf is required but not installed. Please install it first.${RESET}"
    exit 1
fi

if command -v pacman &>/dev/null; then
    DISTRO="arch"
elif command -v dnf &>/dev/null; then
    DISTRO="fedora"
else
    echo -e "${RED}Unsupported distribution!${RESET}"
    exit 1
fi

install_helix() {
    echo -e "${CYAN}Installing Helix editor...${RESET}"
    if [[ $DISTRO == "arch" ]]; then
        sudo pacman -S --noconfirm helix noto-fonts-emoji git
    elif [[ $DISTRO == "fedora" ]]; then
        sudo dnf install -y helix google-noto-color-emoji-fonts google-noto-emoji-fonts git
    fi
}

install_helix

HELIX_CONFIG="$HOME/.config/helix"
if [[ -d "$HELIX_CONFIG" ]]; then
    fzf_confirm "Existing Helix config found. Do you want to back it up?" && {
        BACKUP_PATH="$HOME/.config/helix.bak.$(date +%s)"
        mv "$HELIX_CONFIG" "$BACKUP_PATH"
        echo -e "${GREEN}Backup created at $BACKUP_PATH${RESET}"
    }
fi

echo -e "${CYAN}Cloning Helix configuration...${RESET}"
git clone --depth=1 https://github.com/harilvfs/dwm "$HOME/dwm"

if [[ -d "$HOME/dwm/config/helix" ]]; then
    echo -e "${CYAN}Applying Helix configuration...${RESET}"
    mkdir -p "$HELIX_CONFIG"
    cp -r "$HOME/dwm/config/helix/"* "$HELIX_CONFIG/"
    echo -e "${GREEN}Helix configuration applied!${RESET}"
    rm -rf "$HOME/dwm"
else
    echo -e "${RED}Failed to apply Helix configuration!${RESET}"
    exit 1
fi

echo -e "${CYAN}Helix setup complete! Restart your editor to apply changes.${RESET}"
