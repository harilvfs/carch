#!/bin/bash

# Colors for messages
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
    local tmp_dir="/tmp/font_install"
    local font_dirs=("$HOME/.local/share/fonts" "$HOME/.fonts" "/usr/share/TTF")

    mkdir -p "$tmp_dir"
    
    echo -e "${CYAN}Downloading $font_name...${NC}"
    wget -q -P "$tmp_dir" "$download_url" || { echo -e "${RED}Failed to download $font_name.${NC}"; exit 1; }

    echo -e "${CYAN}Unzipping $font_name...${NC}"
    unzip -q "$tmp_dir/$(basename "$download_url")" -d "$tmp_dir" || { echo -e "${RED}Failed to unzip the font.${NC}"; exit 1; }

    echo -e "${CYAN}Installing $font_name...${NC}"
    for dir in "${font_dirs[@]}"; do
        if [[ "$dir" == "/usr/share/TTF" ]]; then
            if [[ ! -d "$dir" ]]; then
                echo -e "${CYAN}Creating system font directory $dir...${NC}"
                sudo mkdir -p "$dir" || { echo -e "${RED}Failed to create directory $dir. Check permissions.${NC}"; continue; }
            fi
            (cd "$tmp_dir" && sudo mv * "$dir" 2>/dev/null) || echo -e "${RED}Failed to move fonts to $dir.${NC}"
        else
            mkdir -p "$dir"
            (cd "$tmp_dir" && mv * "$dir" 2>/dev/null) || echo -e "${RED}No valid font files found for $dir.${NC}"
        fi
    done

    echo -e "${CYAN}Refreshing font cache...${NC}"
    fc-cache -vf || echo -e "${RED}Failed to refresh font cache.${NC}"

    # Cleanup
    echo -e "${CYAN}Cleaning up temporary files...${NC}"
    rm -rf "$tmp_dir"

    echo -e "${GREEN}Font $font_name installed successfully!${NC}"
}

main_menu() {

echo -e "${BLUE}"
cat <<"EOF"
-------------------------------------------------------------------------------------------------------

██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗         ███████╗ ██████╗ ███╗   ██╗████████╗███████╗
██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║         ██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔════╝
██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║         █████╗  ██║   ██║██╔██╗ ██║   ██║   ███████╗
██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║         ██╔══╝  ██║   ██║██║╚██╗██║   ██║   ╚════██║
██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗    ██║     ╚██████╔╝██║ ╚████║   ██║   ███████║
╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝    ╚═╝      ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝
                                                                                                      
-------------------------------------------------------------------------------------------------------
EOF
echo -e "${ENDCOLOR}"


    while true; do
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

