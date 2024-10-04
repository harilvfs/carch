#!/bin/bash

tput init
tput clear
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' 

setup_nord_backgrounds() {
    echo -e "${CYAN}These Nord backgrounds are from Chris Titus Tech. You can check out his GitHub at:${NC}"
    echo -e "${CYAN}https://github.com/ChrisTitusTech${NC}"
    
    PICTURES_DIR="$HOME/Pictures"
    
    if [ ! -d "$PICTURES_DIR" ]; then
        echo -e "${CYAN}Creating the Pictures directory...${NC}"
        mkdir -p "$PICTURES_DIR"
    fi

    echo -e "${CYAN}Cloning the Nord backgrounds repository...${NC}"
    git clone https://github.com/ChrisTitusTech/nord-background "$PICTURES_DIR/nord-background"

    if [ -d "$PICTURES_DIR/nord-background" ]; then
        rm -rf "$PICTURES_DIR/nord-background/.git"
        echo -e "${GREEN}Nord backgrounds have been successfully set up in your Pictures directory.${NC}"
    else
        echo -e "${CYAN}Failed to clone the repository.${NC}"
    fi
}

setup_nord_backgrounds
