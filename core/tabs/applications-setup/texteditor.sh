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

install_texteditor() {
    while true; do 
    echo -e "${BLUE}"
    figlet -f slant "Text Editor"
    echo -e "${RESET}"

    echo -e "${BLUE}Select a text editor to install:${RESET}"
    echo -e "1) Cursor (AI Code Editor)"
    echo -e "2) Visual Studio Code (VSCODE)"
    echo -e "3) Vscodium"
    echo -e "4) ZED Editor"
    echo -e "5) Neovim"
    echo -e "6) Vim"
    echo -e "7) Code-OSS"
    echo -e "8) Exit"

    read -p "Enter your choice (1-8): " choice
    case $choice in
        1) 
            gum spin --spinner dot --title "Installing Cursor (AI Code Editor)..." -- paru -S cursor-bin --noconfirm && \
            version=$(paru -Qi cursor-bin | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **Cursor installed successfully! Version: $version**"
            ;;
        2)
            gum spin --spinner dot --title "Installing Visual Studio Code..." -- paru -S visual-studio-code-bin --noconfirm && \
            version=$(paru -Qi visual-studio-code-bin | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **Visual Studio Code installed successfully! Version: $version**"
            ;;
        3) 
            gum spin --spinner dot --title "Installing Vscodium..." -- paru -S vscodium-bin --noconfirm && \
            version=$(paru -Qi vscodium-bin | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **Vscodium installed successfully! Version: $version**"
            ;;
        4) 
            gum spin --spinner dot --title "Installing ZED Editor..." -- paru -S zed-preview-bin --noconfirm && \
            version=$(paru -Qi zed-preview-bin | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **ZED Editor installed successfully! Version: $version**"
            ;;
        5) 
            gum spin --spinner dot --title "Installing Neovim..." -- paru -S neovim --noconfirm && \
            version=$(paru -Qi neovim | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **Neovim installed successfully! Version: $version**"
            ;;
        6)
            gum spin --spinner dot --title "Installing Vim..." -- paru -S vim --noconfirm && \
            version=$(paru -Qi vim | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **Vim installed successfully! Version: $version**"
            ;;
        7) 
            gum spin --spinner dot --title "Installing Code-OSS..." -- paru -S coder-oss --noconfirm && \
            version=$(paru -Qi coder-oss | grep Version | awk '{print $3}') && \
            clear
            gum format "🎉 **Code-OSS installed successfully! Version: $version**"
            ;;
        8)
            break 
            ;;
        esac
    done
}

install_texteditor

