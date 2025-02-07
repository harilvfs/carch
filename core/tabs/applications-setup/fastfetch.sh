#!/bin/bash

clear

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' 
BLUE="\e[34m"
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
figlet -f slant "Fastfetch"

echo -e "${ENDCOLOR}"

FASTFETCH_DIR="$HOME/.config/fastfetch"
BACKUP_DIR="$HOME/.config/fastfetch_backup"

if command -v fastfetch &> /dev/null; then
    echo -e "${GREEN}Fastfetch is already installed.${NC}"
else
    echo -e "${CYAN}Fastfetch is not installed. :: Installing...${NC}"
    sudo pacman -S fastfetch --noconfirm
fi

if [ -d "$FASTFETCH_DIR" ]; then
    echo -e "${RED}Fastfetch configuration directory already exists.${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${CYAN}Creating backup directory...${NC}"
        mkdir "$BACKUP_DIR"
    fi

    echo -e "${CYAN}:: Backing up existing Fastfetch configuration...${NC}"
    mv "$FASTFETCH_DIR"/* "$BACKUP_DIR/"
    echo -e "${GREEN}Backup completed.${NC}"
fi

echo -e "${CYAN}:: Cloning Fastfetch repository...${NC}"
git clone https://github.com/harilvfs/fastfetch "$FASTFETCH_DIR"

echo -e "${CYAN}:: Cleaning up unnecessary files...${NC}"
rm -rf "$FASTFETCH_DIR/.git" "$FASTFETCH_DIR/LICENSE" "$FASTFETCH_DIR/README.md"

echo -e "${GREEN}Fastfetch setup completed successfully!${NC}"
