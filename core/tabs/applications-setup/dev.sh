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

install_github() {
    install_paru
    while true; do
    echo -e "${BLUE}"
    figlet -f slant "Dev Tools"
    echo -e "${ENDCOLOR}"

        echo -e "${BLUE}Select a Developer tool to install:${RESET}"
        echo "1) Git"
        echo "2) GitHub Desktop"
        echo "3) GitHub-CLI"
        echo "4) Exit"
        read -p "Enter your choice [1-4]: " github_choice

        case $github_choice in

            1)
                gum spin --spinner dot --title "Installing Git..." -- paru -S --noconfirm git && \
                version=$(paru -Qi git | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **Git installed successfully! Version: $version**"
                ;;
            2)
                gum spin --spinner dot --title "Installing GitHub Desktop..." -- paru -S --noconfirm github-desktop-bin && \
                version=$(paru -Qi github-desktop-bin | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **GitHub Desktop installed successfully! Version: $version**"
                ;;
            3)
                gum spin --spinner dot --title "Installing GitHub Cli..." -- sudo pacman -S --noconfirm github-cli && \
                version=$(pacman -Qi github-cli | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **GitHub Cli installed successfully! Version: $version**"
                ;;
            4)
                break
                ;;
            *)
                echo -e "${RED}Invalid option${RESET}"
                ;;
        esac
    done
}

install_github
