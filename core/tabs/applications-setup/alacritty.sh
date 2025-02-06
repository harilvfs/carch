#!/bin/bash

clear

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BLUE="\e[34m"
ENDCOLOR="\e[0m"
RESET='\033[0m'

echo -e "${BLUE}"
figlet -f slant "Alacritty"
echo -e "${ENDCOLOR}"

confirm_continue() {
    echo -e "${YELLOW}Warning: If you already have an Alacritty configuration, make sure to back it up before proceeding.${RESET}"
    while true; do
        read -rp "Do you want to continue with the setup? (y/n): " choice
        case "$choice" in
            [Yy]) break ;;
            [Nn]) 
                echo -e "${RED}Setup aborted by the user.${RESET}"
                exit 1
                ;;
            *) echo -e "${YELLOW}Please enter y or n.${RESET}" ;;
        esac
    done
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

confirm_continue
installAlacritty
setupAlacrittyConfig

echo -e "${GREEN}:: Alacritty setup complete.${RESET}"

