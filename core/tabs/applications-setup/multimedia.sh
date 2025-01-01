#!/bin/bash

clear

BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

install_paru() {
    if ! command -v paru &> /dev/null; then
        echo -e "${RED}Paru not found. :: Installing...${RESET}"
        sudo pacman -S --needed base-devel

        temp_dir=$(mktemp -d)
        cd "$temp_dir" || { echo -e "${RED}Failed to create temp directory${RESET}"; exit 1; }

        git clone https://aur.archlinux.org/paru.git
        cd paru || { echo -e "${RED}Failed to enter paru directory${RESET}"; exit 1; }
        makepkg -si
        
        cd ..
        rm -rf "$temp_dir"
        echo -e "${GREEN}Paru installed successfully.${RESET}"
    else
        echo -e "${GREEN}:: Paru is already installed.${RESET}"
    fi
}

install_multimedia() {
    install_paru
    while true; do
    echo -e "${BLUE}"
    figlet -f slant "Multimedia"
    echo -e "${RESET}"

    echo -e "${BLUE}Select a multimedia application to install:${RESET}"
    echo -e "1) VLC"
    echo -e "2) Netflix [Unofficial]"
    echo -e "3) Exit"

    read -p "Enter your choice (1-3): " choice
    case $choice in
        1) 
            gum spin --spinner dot --title "Installing VLC..." -- paru -S vlc --noconfirm && \
            version=$(paru -Qi vlc | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **VLC installed successfully! Version: $version**"
            ;;
        2) 
            gim spin --spinner dot --title "Installing Netflix [Unofficial]..." -- paru -S netflix --noconfirm && \
            version=$(paru -Qi netflix | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **Netflix [Unofficial] installed successfully! Version: $version**"
            ;;
        3) 
            break
            ;;
        esac
    done
}

install_multimedia

