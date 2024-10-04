#!/bin/bash

tput init
tput clear
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' 

install_paru() {
    echo -e "${CYAN}Installing Paru...${NC}"
    sudo pacman -S --needed base-devel

    temp_dir=$(mktemp -d)
    cd "$temp_dir" || { echo -e "${RED}Failed to create temp directory${NC}"; exit 1; }

    # Clone and install paru
    git clone https://aur.archlinux.org/paru.git
    cd paru || { echo -e "${RED}Failed to enter paru directory${NC}"; exit 1; }
    makepkg -si

    cd ..
    rm -rf "$temp_dir"
    echo -e "${GREEN}Paru installed successfully.${NC}"
}

install_yay() {
    echo -e "${CYAN}Installing Yay...${NC}"
    sudo pacman -S --needed git base-devel

    temp_dir=$(mktemp -d)
    cd "$temp_dir" || { echo -e "${RED}Failed to create temp directory${NC}"; exit 1; }

    git clone https://aur.archlinux.org/yay.git
    cd yay || { echo -e "${RED}Failed to enter yay directory${NC}"; exit 1; }
    makepkg -si

    cd ..
    rm -rf "$temp_dir"
    echo -e "${GREEN}Yay installed successfully.${NC}"
}

while true; do
    clear
    echo -e "${CYAN}AUR Setup Menu:${NC}"
    echo "1) Install Paru"
    echo "2) Install Yay"
    echo "3) Exit"
    read -p "Choose an option: " aur_choice

    case $aur_choice in
        1) install_paru ;;
        2) install_yay ;;
        3) clear; exit ;;  
        *) echo -e "${RED}Invalid option. Please choose again.${NC}" ;;
    esac
done
