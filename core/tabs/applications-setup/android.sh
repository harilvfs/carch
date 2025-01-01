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

install_android() {
    install_paru
    while true; do
    echo -e "${BLUE}"
    figlet -f slant "Android"
    echo -e "${RESET}"

    echo -e "${BLUE}Select an Android-related application to install:${RESET}"
    echo -e "1) Gvfs-MTP [Displays Android phones via USB]"
    echo -e "2) ADB"
    echo -e "3) Exit"

    read -p "Enter your choice (1-3): " android_choice
    
    case $android_choice in
        1) 
            gum spin --spinner dot --title "Installing Gvfs-MTP..." -- paru -S --noconfirm gvfs-mtp  && \
            version=$(paru -Qi gvfs-mtp | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **Gvfs-MTP installed successfully! Version: $version**"
            ;;
        2) 
            gum spin --spinner dot --title "Installing ADB..." -- paru -S --noconfirm adb && \
            version=$(paru -Qi adb | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **ADB installed successfully! Version: $version**"
            ;;
        3) 
            break
            ;;
        esac
    done
}

install_android
