#!/bin/bash

clear

BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

install_filemanagers() {
    while true; do
    echo -e "${BLUE}"
    figlet -f slant "File Managers"
    echo -e "${RESET}"

    echo -e "${BLUE}Select a file manager to install:${RESET}"
    echo -e "1) Nemo"
    echo -e "2) Thunar"
    echo -e "3) Dolphin"
    echo -e "4) LF (Terminal File Manager)"
    echo -e "5) Ranger"
    echo -e "6) Nautilus"
    echo -e "7) Yazi"
    echo -e "8) Exit"

    read -p "Enter your choice (1-8): " filemanager_choice
    case $filemanager_choice in
        1) 
            gum spin --spinner dot --title "Installing Nemo..." -- sudo pacman -S nemo --noconfirm && \
            version=$(pacman -Qi nemo | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **Nemo installed successfully! Version: $version**"
            ;;
        2) 
            gum spin --spinner dot --title "Installing Thunar..." -- sudo pacman -S thunar --noconfirm && \
            version=$(pacman -Qi thunar | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **Thunar installed successfully! Version: $version**"
            ;;
        3) 
            gum spin --spinner dot --title "Installing Dolphin..." -- sudo pacman -S dolphin --noconfirm && \
            version=$(pacman -Qi dolphin | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **Dolphin installed successfully! Version: $version**"
            ;;
        4) 
            gum spin --spinner dot --title "Installing LF..." -- sudo pacman -S lf --noconfirm && \
            version=$(pacman -Qi lf | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **LF installed successfully! Version: $version**"
            ;;
        5) 
            gum spin --spinner dot --title "Installing Ranger..." -- sudo pacman -S ranger --noconfirm && \
            version=$(pacman -Qi ranger | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **Ranger installed successfully! Version: $version**"
            ;;
        6)  
            gum spin --spinner dot --title "Installing Nautilus..." -- sudo pacman -S nautilus --noconfirm && \
            version=$(pacman -Qi nautilus | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **Nautilus installed successfully! Version: $version**"
            ;;
        7) 
            gum spin --spinner dot --title "Installing Yazi..." -- sudo pacman -S yazi --noconfirm && \
            version=$(pacman -Qi yazi | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **Yazi installed successfully! Version: $version**"
            ;;
        8) 
            break
            ;;
        esac
    done
}

install_filemanagers

