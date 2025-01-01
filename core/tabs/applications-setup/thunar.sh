#!/bin/bash

clear

RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
RESET="\033[0m"

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

install_thunarpreview() {
    while true; do
    echo -e "${BLUE}"
    figlet -f slant "Thunar Preview"
    echo -e "${RESET}"

    echo -e "${BLUE}Select an application to install for Thunar preview:${RESET}"
    echo -e "1) Tumbler"
    echo -e "2) Exit"

    read -p "Enter your choice (1-2): " choice
    case $choice in
        1) 
            gum spin --spinner dot --title "Installing Thunar Preview..." -- paru -s tumbler --noconfirm && \
            version=$(paru -Qi tumbler | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **Tumbler installed successfully! Version: $version**"
            ;;
        2) 
            break
            ;;
        esac
    done
}

install_thunarpreview

