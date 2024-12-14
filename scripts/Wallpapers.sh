#!/bin/bash

clear

GREEN='\033[0;32m'
CYAN='\033[0;36m'
BLUE="\e[34m"
ENDCOLOR="\e[0m"
NC='\033[0m'

echo -e "${BLUE}"
figlet -f slant "Wallpapers"
cat <<"EOF"
-----------------------------------------------------------------
                Nord & Anime Wallpapers Setup

                          Credits
ChrisTitusTech https://github.com/ChrisTitusTech/nord-background
        2SSK https://github.com/2SSK/Wallpaper-Bank
    Maotseantonio https://github.com/maotseantonio/wallpapers
-----------------------------------------------------------------
EOF
echo -e "${ENDCOLOR}"

PICTURES_DIR="$HOME/Pictures"
WALLPAPERS_DIR="$PICTURES_DIR/wallpapers"

echo -e "${CYAN}Wallpapers will be set up in the Pictures directory (${PICTURES_DIR}).${NC}"

if ! gum confirm "Do you want to continue?"; then
    echo -e "${YELLOW}Operation canceled. Exiting...${NC}"
    exit 0
fi

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
        echo -e "${GREEN}Wallpapers have been successfully set up in your wallpapers directory.${NC}"
    else
        echo -e "${CYAN}Failed to clone the repository.${NC}"
    fi
}

setup_wallpapers

