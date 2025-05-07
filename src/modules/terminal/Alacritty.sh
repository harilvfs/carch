#!/usr/bin/env bash

# Configures the Alacritty terminal emulator using my preferred settings for optimal performance.

clear

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BLUE="\e[34m"
ENDCOLOR="\e[0m"
RESET='\033[0m'

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

installAlacritty() {
    if command -v alacritty &>/dev/null; then
        echo -e "${GREEN}Alacritty is already installed.${RESET}"
        return
    fi

    echo -e "${YELLOW}Alacritty is not installed. Installing now...${RESET}"

    if [ -x "$(command -v pacman)" ]; then
        sudo pacman -S alacritty --noconfirm
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install alacritty -y
    else
        echo -e "${RED}Unsupported package manager! Please install Alacritty manually.${RESET}"
        exit 1
    fi

    echo -e "${GREEN}Alacritty has been installed.${RESET}"
}

setupAlacrittyConfig() {
    local alacritty_config="${HOME}/.config/alacritty"

    echo -e "${CYAN}:: Setting up Alacritty configuration...${RESET}"

    if [ -d "$alacritty_config" ] && [ ! -d "${alacritty_config}-bak" ]; then
        mv "$alacritty_config" "${alacritty_config}-bak"
        echo -e "${YELLOW}:: Existing Alacritty configuration backed up to alacritty-bak.${RESET}"
    fi

    mkdir -p "$alacritty_config"

    base_url="https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/alacritty"
    for file in alacritty.toml keybinds.toml nordic.toml; do
        curl -sSLo "$alacritty_config/$file" "$base_url/$file"
    done

    echo -e "${CYAN}:: Running 'alacritty migrate' to update the config...${RESET}"
    (cd "$alacritty_config" && alacritty migrate)

    echo -e "${GREEN}:: Alacritty configuration files copied and migrated.${RESET}"
}

installAlacritty
setupAlacrittyConfig

echo -e "${GREEN}:: Alacritty setup complete.${RESET}"
