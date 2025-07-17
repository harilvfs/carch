#!/usr/bin/env bash

set -euo pipefail

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../fzf.sh" > /dev/null 2>&1

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

check_fzf

if command -v pacman &> /dev/null; then
    DISTRO="arch"
elif command -v dnf &> /dev/null; then
    DISTRO="fedora"
elif command -v zypper &> /dev/null; then
    DISTRO="opensuse"
else
    echo -e "${RED}Unsupported distribution!${NC}"
    exit 1
fi

install_helix() {
    echo -e "${CYAN}Installing Helix editor...${NC}"
    if [[ $DISTRO == "arch" ]]; then
        sudo pacman -S --noconfirm helix noto-fonts-emoji git
    elif [[ $DISTRO == "fedora" ]]; then
        sudo dnf install -y helix google-noto-color-emoji-fonts google-noto-emoji-fonts git
    elif [[ $DISTRO == "opensuse" ]]; then
        sudo zypper install -y helix google-noto-fonts noto-coloremoji-fonts git
    fi
}

install_helix

HELIX_CONFIG="$HOME/.config/helix"
if [[ -d "$HELIX_CONFIG" ]]; then
    fzf_confirm "Existing Helix config found. Do you want to back it up?" && {
        BACKUP_PATH="$HOME/.config/helix.bak.$(date +%s)"
        mv "$HELIX_CONFIG" "$BACKUP_PATH"
        echo -e "${GREEN}Backup created at $BACKUP_PATH${NC}"
    }
fi

echo -e "${CYAN}Cloning Helix configuration...${NC}"
git clone --depth=1 https://github.com/harilvfs/dwm "$HOME/dwm"

if [[ -d "$HOME/dwm/config/helix" ]]; then
    echo -e "${CYAN}Applying Helix configuration...${NC}"
    mkdir -p "$HELIX_CONFIG"
    cp -r "$HOME/dwm/config/helix/"* "$HELIX_CONFIG/"
    echo -e "${GREEN}Helix configuration applied!${NC}"
    rm -rf "$HOME/dwm"
else
    echo -e "${RED}Failed to apply Helix configuration!${NC}"
    exit 1
fi

echo -e "${CYAN}Helix setup complete! Restart your editor to apply changes.${NC}"
