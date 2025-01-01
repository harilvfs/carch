#!/bin/bash

clear

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'
BLUE="\e[34m"
RED='\033[0;31m'
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
figlet -f slant "Rofi"
echo -e "${ENDCOLOR}"

echo -e "${RED}:: WARNING: Make sure to back up your current Rofi configuration (if it exists).${ENDCOLOR}"

setup_rofi() {
    if ! command -v rofi &> /dev/null; then
        echo -e "${CYAN}Rofi is not installed. :: Installing Rofi...${NC}"
        sudo pacman -S rofi
    else
        echo -e "${GREEN}:: Rofi is already installed.${NC}"
    fi

    ROFI_CONFIG_DIR="$HOME/.config/rofi"
    BACKUP_DIR="$HOME/.config/rofi_backup"

    if [ -d "$ROFI_CONFIG_DIR" ]; then
        echo -e "${CYAN}:: Rofi configuration directory exists. Backing up the current configuration...${NC}"
        
        if [ ! -d "$BACKUP_DIR" ]; then
            mkdir -p "$BACKUP_DIR"
        fi

        mv "$ROFI_CONFIG_DIR"/* "$BACKUP_DIR"/
        echo -e "${GREEN}:: Existing Rofi configuration backed up to ~/.config/rofi_backup.${NC}"
    else
        mkdir -p "$ROFI_CONFIG_DIR"
    fi

    echo -e "${CYAN}:: Applying new Rofi configuration...${NC}"
    wget -q https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/rofi/config.rasi -O "$ROFI_CONFIG_DIR/config.rasi"

    if [ ! -d "$ROFI_CONFIG_DIR/themes" ]; then
        mkdir -p "$ROFI_CONFIG_DIR/themes"
    fi

    wget -q https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/rofi/themes/nord.rasi -O "$ROFI_CONFIG_DIR/themes/nord.rasi"

    echo -e "${GREEN}:: Rofi configuration applied successfully!${NC}"
}

setup_rofi

