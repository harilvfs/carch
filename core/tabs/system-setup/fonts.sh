#!/bin/bash

clear

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BLUE="\e[34m"
ENDCOLOR="\e[0m"
NC='\033[0m'

check_dependencies() {
    if ! command -v unzip &>/dev/null; then
        echo -e "${RED}Error: 'unzip' is not installed. :: Please install it first.${NC}"
        exit 1
    fi
}

install_font() {
    local font_name="$1"
    local download_url="$2"
    local scope="$3"

    local download_dir="$HOME/Downloads/fonts"
    local font_download_path="$download_dir/${font_name}.zip"
    local font_extract_dir="$download_dir/${font_name}"
    local target_font_dir

    if [ "$scope" == "system" ]; then
        target_font_dir="/usr/share/fonts"
        if [ "$(id -u)" -ne 0 ]; then
            echo -e "${CYAN}:: Requesting sudo permissions for system-wide installation...${NC}"
            sudo -v || { echo -e "${RED}Failed to obtain sudo permissions. Exiting.${NC}"; exit 1; }
        fi
    else
        target_font_dir="$HOME/.local/share/fonts"
    fi

    mkdir -p "$download_dir" "$target_font_dir"

    echo -e "${CYAN}:: Downloading $font_name to ${download_dir}...${NC}"
    wget -q -O "$font_download_path" "$download_url" || { echo -e "${RED}Failed to download $font_name.${NC}"; exit 1; }

    echo -e "${CYAN}:: Unzipping $font_name...${NC}"
    unzip -q "$font_download_path" -d "$font_extract_dir" || { echo -e "${RED}Failed to unzip $font_name.${NC}"; exit 1; }

    echo -e "${CYAN}:: Installing $font_name to $target_font_dir...${NC}"
    if [ "$scope" == "system" ]; then
        sudo find "$font_extract_dir" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$target_font_dir/" \;
    else
        find "$font_extract_dir" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$target_font_dir/" \;
    fi

    echo -e "${CYAN}:: Refreshing font cache...${NC}"
    if [ "$scope" == "system" ]; then
        sudo fc-cache -vf || echo -e "${RED}Failed to refresh font cache.${NC}"
    else
        fc-cache -vf || echo -e "${RED}Failed to refresh font cache.${NC}"
    fi

    echo -e "${CYAN}:: Cleaning up...${NC}"
    rm -rf "$font_extract_dir" "$font_download_path"

    echo -e "${GREEN}Font $font_name installed successfully!${NC}"

    read -p "Press Enter to return to the font menu..."

}

main_menu() {
    while true; do
        echo -e "${BLUE}"
        figlet -f slant "Fonts"
        echo -e "${ENDCOLOR}"

        echo -e "Select a font to install:"
        echo "1) FiraCode"
        echo "2) Meslo"
        echo "3) JetBrains Mono"
        echo "4) Hack"
        echo "5) CascadiaMono"
        echo "6) Terminus"
        echo "7) Exit"
        read -p "Enter your choice [1-7]: " choice

        case $choice in
            1) install_menu "FiraCode" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip" ;;
            2) install_menu "Meslo" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip" ;;
            3) install_menu "JetBrains Mono" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip" ;;
            4) install_menu "Hack" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip" ;;
            5) install_menu "CascadiaMono" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/CascadiaMono.zip" ;;
            6) install_menu "Terminus" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Terminus.zip" ;;
            7) echo -e "${GREEN}Exiting. Thank you!${NC}"; exit ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
        esac
    done
}

install_menu() {
    local font_name="$1"
    local download_url="$2"

    echo -e "${CYAN}:: Choose installation scope for $font_name:${NC}"
    echo "1) User (Local)"
    echo "2) System (Root Required)"
    read -p "Enter your choice [1-2]: " scope

    case $scope in
        1) install_font "$font_name" "$download_url" "user" ;;
        2) install_font "$font_name" "$download_url" "system" ;;
        *) echo -e "${RED}Invalid selection. Skipping installation.${NC}" ;;
    esac
}

check_dependencies
main_menu


