#!/bin/bash

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
RC='\033[0m'

checkAlacritty() {
    if command -v alacritty &> /dev/null; then
        printf "%b\n" "${GREEN}Alacritty is already installed.${RC}"
    else
        printf "%b\n" "${YELLOW}Alacritty is not installed. Installing now...${RC}"
        if [ -x "$(command -v pacman)" ]; then
            sudo pacman -S alacritty --noconfirm
        elif [ -x "$(command -v apt)" ]; then
            sudo apt install alacritty -y
        else
            printf "%b\n" "${RED}Unsupported package manager! Please install Alacritty manually.${RC}"
            exit 1
        fi
        printf "%b\n" "${GREEN}Alacritty has been installed.${RC}"
    fi
}

setupAlacrittyConfig() {
    printf "%b\n" "${YELLOW}Copying Alacritty config files...${RC}"
    if [ -d "${HOME}/.config/alacritty" ] && [ ! -d "${HOME}/.config/alacritty-bak" ]; then
        cp -r "${HOME}/.config/alacritty" "${HOME}/.config/alacritty-bak"
        printf "%b\n" "${GREEN}Existing Alacritty configuration backed up to alacritty-bak.${RC}"
    fi
    mkdir -p "${HOME}/.config/alacritty/"
    curl -sSLo "${HOME}/.config/alacritty/alacritty.toml" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/alacritty/alacritty.toml"
    curl -sSLo "${HOME}/.config/alacritty/keybinds.toml" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/alacritty/keybinds.toml"
    curl -sSLo "${HOME}/.config/alacritty/nordic.toml" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/alacritty/nordic.toml"
    printf "%b\n" "${GREEN}Alacritty configuration files copied.${RC}"
}

checkAlacritty
setupAlacrittyConfig

printf "%b\n" "${GREEN}Alacritty setup complete.${RC}"
