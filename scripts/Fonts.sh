#!/bin/bash

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BLUE="\e[34m"
ENDCOLOR="\e[0m"
NC='\033[0m'

check_dependencies() {
    if ! command -v unzip &>/dev/null; then
        echo -e "${RED}Error: 'unzip' is not installed. Please install it first.${NC}"
        exit 1
    fi
}

install_font() {
    local font_name="$1"
    local download_url="$2"
    local download_dir="$HOME/Downloads/fonts"
    local font_download_path="$download_dir/${font_name}.zip"
    local font_extract_dir="$download_dir/${font_name}"

    mkdir -p "$download_dir"

    echo -e "${CYAN}Downloading $font_name to ${download_dir}...${NC}"
    wget -q -O "$font_download_path" "$download_url" || { echo -e "${RED}Failed to download $font_name.${NC}"; exit 1; }

    echo -e "${CYAN}Unzipping $font_name...${NC}"
    unzip -q "$font_download_path" -d "$font_extract_dir" || { echo -e "${RED}Failed to unzip $font_name.${NC}"; exit 1; }

    echo -e "${CYAN}Installing $font_name...${NC}"

    local target_font_dir="$HOME/.local/share/fonts"
    mkdir -p "$target_font_dir"

    find "$font_extract_dir" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec mv {} "$target_font_dir/" \;

    echo -e "${CYAN}Refreshing font cache...${NC}"
    fc-cache -vf || echo -e "${RED}Failed to refresh font cache.${NC}"

    echo -e "${CYAN}Cleaning up...${NC}"
    rm -rf "$font_extract_dir" "$font_download_path"

    echo -e "${GREEN}Font $font_name installed successfully!${NC}"
}

main_menu() {
    while true; do
        clear
        echo -e "${BLUE}"
        figlet -f slant "Fonts"
        echo -e "${ENDCOLOR}"
        choice=$(gum choose "FiraCode" "Meslo" "JetBrains Mono" "Hack" "Cascadia" "Terminus" "Exit")

        case $choice in
            "FiraCode") install_font "FiraCode" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip" ;;
            "Meslo") install_font "Meslo" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip" ;;
            "JetBrains Mono") install_font "JetBrains" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip" ;;
            "Hack") install_font "Hack" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip" ;;
            "Cascadia") install_font "Cascadia" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/CascadiaMono.zip" ;;
            "Terminus") install_font "Terminus" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Terminus.zip" ;;
            "Exit") echo -e "${GREEN}Exiting. Thank you!${NC}"; exit ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
        esac
    done
}

tput clear
check_dependencies
main_menu

