#!/bin/bash

clear

BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

install_editing() {
    while true; do
    echo -e "${BLUE}"
    figlet -f slant "Editing Tools"
    echo -e "${RESET}"

    echo -e "${BLUE}Select editing tools to install:${RESET}"
    echo -e "1) GIMP (Image)"
    echo -e "2) Kdenlive (Videos)"
    echo -e "3) Exit"

    read -p "Enter your choice (1/2/3): " editing_choice

    case $editing_choice in
        1) 
            gum spin --spinner dot --title "Installing GIMP..." -- sudo pacman -S --noconfirm gimp && \
            version=$(pacman -Qi gimp | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **GIMP installed successfully! Version: $version**"
            ;;
        2) 
            gum spin --spinner dot --title "Installing Kdenlive..." -- sudo pacman -S --noconfirm kdenlive && \
            version=$(pacman -Qi kdenlive | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **Kdenlive installed successfully! Version: $version**"
            ;;
        3) 
            break 
            ;;
        
        esac
    done
}

install_editing

