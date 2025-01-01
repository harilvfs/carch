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

install_streaming() {
    install_paru
    while true; do
    echo -e "${BLUE}"
    figlet -f slant "Streaming"
    echo -e "${RESET}"

    echo -e "${BLUE}Select streaming tools to install:${RESET}"
    echo -e "1) OBS Studio"
    echo -e "2) SimpleScreenRecorder [Git]"
    echo -e "3) Exit"

    read -p "Enter your choice (1/2/3): " choice

    case $choice in
        1) 
            gum spin --spinner dot --title "Installing OBS Studio..." -- sudo pacman -S --noconfirm obs-studio && \
            version=$(pacman -Qi obs-studio | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **OBS Studio installed successfully! Version: $version**"
            ;;
        2) 
            gum spin --spinner dot --title "Installing SimpleScreenRecorder [Git]..." -- paru -S --noconfirm simplescreenrecorder-git && \
            version=$(pacman -Qi simplescreenrecorder-git | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **SimpleScreenRecorder [Git] installed successfully! Version: $version**"
            ;;
        3) 
            break
            ;;
        esac
    done
}

install_streaming

