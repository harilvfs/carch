#!/bin/bash

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' 
BLUE="\e[34m"
ENDCOLOR="\e[0m"

install_paru() {
    echo -e "${CYAN}:: Installing Paru...${NC}"
    sudo pacman -S --needed base-devel

    temp_dir=$(mktemp -d)
    cd "$temp_dir" || { echo -e "${RED}Failed to create temp directory${NC}"; exit 1; }

    git clone https://aur.archlinux.org/paru.git
    cd paru || { echo -e "${RED}Failed to enter paru directory${NC}"; exit 1; }
    makepkg -si

    cd ..
    rm -rf "$temp_dir"
    echo -e "${GREEN}Paru installed successfully.${NC}"
}

install_yay() {
    echo -e "${CYAN}:: Installing Yay...${NC}"
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
    echo -e "${BLUE}"
    figlet -f slant "Aur"
    echo -e "${ENDCOLOR}"

    echo -e "${CYAN}:: AUR Setup Menu${NC}"
    echo -e "Please select an option:"
    echo -e "1) Install Paru"
    echo -e "2) Install Yay"
    echo -e "3) Exit"
    
    read -p "Enter your choice (1/2/3): " choice

    case $choice in
        1) install_paru ;;
        2) install_yay ;;
        3) exit ;;
        *) echo -e "${RED}Invalid choice. Please try again.${NC}" ;;
    esac
done


