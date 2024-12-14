#!/bin/bash

tput init
tput clear

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' 
BLUE="\e[34m"
ENDCOLOR="\e[0m"

install_paru() {
    echo -e "${CYAN}Installing Paru...${NC}"
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
    echo -e "${BLUE}"
    figlet -f slant "Aur"
    echo -e "${ENDCOLOR}"

    echo -e "${CYAN}AUR Setup Menu:${NC}"
    choice=$(gum choose "Install Paru" "Install Yay" "Exit")

    case $choice in
        "Install Paru") install_paru ;;
        "Install Yay") install_yay ;;
        "Exit") exit ;;  
    esac
done

