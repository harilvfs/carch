#!/bin/bash

clear

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE="\e[34m"
ENDCOLOR="\e[0m"
RESET='\033[0m'

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

install_communication() {
    install_paru
    while true; do
    echo -e "${BLUE}"
    figlet -f slant "Communication"
    echo -e "${ENDCOLOR}"

        echo -e "${BLUE}Select a communication tool to install:${RESET}"
        echo "1) Discord"
        echo "2) Better Discord"
        echo "3) Signal"
        echo "4) Telegram"
        echo "5) Keybase"
        echo "6) Exit"
        read -p "Enter your choice [1-6]: " comm_choice

        case $comm_choice in
            1)
                gum spin --spinner dot --title "Installing Discord..." -- paru -S --noconfirm discord && \
                version=$(pacman -Qi discord | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **Discord installed successfully! Version: $version**"
                ;;
            2)
                gum spin --spinner dot --title "Installing Better Discord..." -- paru -S --noconfirm betterdiscord-installer-bin&& \
                version=$(pacman -Qi betterdiscord-installer-bin | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **Better Discord installed successfully! Version: $version**"
                ;;
            3)
                gum spin --spinner dot --title "Installing Signal..." -- paru -S --noconfirm signal-desktop && \
                version=$(pacman -Qi signal-desktop | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **Signal installed successfully! Version: $version**"
                ;;
            4)
                gum spin --spinner dot --title "Installing Telegram..." -- paru -S --noconfirm telegram-desktop && \
                version=$(pacman -Qi telegram-desktop | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **Telegram installed successfully! Version: $version**"
                ;;
            5)
                gum spin --spinner dot --title "Installing Keybase..." -- paru -S --noconfirm keybase-bin && \
                version=$(pacman -Qi keybase-bin | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **Keybase installed successfully! Version: $version**"
                ;;
            6)
                break
                ;;
            *)
                echo -e "${RED}Invalid choice, please try again.${RESET}"
                ;;
        esac
    done
}

install_communication


