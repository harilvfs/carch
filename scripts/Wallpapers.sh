#!/bin/bash

tput init
tput clear
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}====================================${NC}"
echo -e "${CYAN}    Nord & Anime Wallpapers Setup    ${NC}"
echo -e "${CYAN}====================================${NC}"
echo -e "${CYAN}Credits:${NC}"
echo -e "${CYAN}Nord Wallpapers from Chris Titus - ${NC}https://github.com/ChrisTitusTech/nord-background${NC}"
echo -e "${CYAN}Anime Wallpapers from 2SSK - ${NC}https://github.com/2SSK/Wallpaper-Bank${NC}"
echo -e "${CYAN}======================================================================================${NC}"
echo

PICTURES_DIR="$HOME/Pictures"
WALLPAPERS_DIR="$PICTURES_DIR/wallpapers"

if [ ! -d "$PICTURES_DIR" ]; then
    echo -e "${CYAN}Creating the Pictures directory...${NC}"
    mkdir -p "$PICTURES_DIR"
fi

setup_wallpapers() {
    echo -e "${CYAN}Cloning the wallpapers repository from Harilvfs...${NC}"
    git clone https://github.com/harilvfs/wallpapers "$WALLPAPERS_DIR"

    if [ -d "$WALLPAPERS_DIR" ]; then
        echo -e "${CYAN}Cleaning up unnecessary files from the repository...${NC}"
        cd "$WALLPAPERS_DIR"
        rm -rf .git README.md docs/
        echo -e "${GREEN}Nord wallpapers have been successfully set up in your wallpapers directory.${NC}"
    else
        echo -e "${CYAN}Failed to clone the repository.${NC}"
    fi
}

setup_wallpapers

