#!/bin/bash

tput init
tput clear

GREEN='\033[0;32m'
CYAN='\033[0;36m'
BLUE="\e[34m"
RED='\033[0;31m'
ENDCOLOR="\e[0m"
NC='\033[0m'

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

install_font() {
    local font_name="$1"
    local download_url="$2"
    local tmp_dir="$HOME/tmp_font_install"
    
    mkdir -p "$tmp_dir"
    
    echo -e "${CYAN}Downloading $font_name...${NC}"
    wget -q -P "$tmp_dir" "$download_url"
    
    echo -e "${CYAN}Unzipping $font_name...${NC}"
    unzip -q "$tmp_dir/${font_name}.zip" -d "$tmp_dir"
    
    mkdir -p "$HOME/.local/share/fonts"
    mkdir -p "$HOME/.fonts"
    
    echo -e "${CYAN}Installing $font_name...${NC}"
    
    if [ -n "$(find "$tmp_dir" -name "*.ttf")" ]; then
        cp "$tmp_dir/"*.ttf "$HOME/.local/share/fonts/"
        cp "$tmp_dir/"*.ttf "$HOME/.fonts/"
        sudo cp "$tmp_dir/"*.ttf /usr/share/fonts/
        sudo cp "$tmp_dir/"*.ttf /usr/share/fonts/ttf/
    else
        echo -e "${GREEN}No .ttf font files found. Checking for other font file types...${NC}"
        cp "$tmp_dir/"*.otf "$HOME/.local/share/fonts/" 2>/dev/null
        cp "$tmp_dir/"*.otf "$HOME/.fonts/" 2>/dev/null
        sudo cp "$tmp_dir/"*.otf /usr/share/fonts/ 2>/dev/null
        sudo cp "$tmp_dir/"*.otf /usr/share/fonts/ttf/ 2>/dev/null
    fi

    fc-cache -vf
    
    echo -e "${GREEN}Font $font_name applied successfully!${NC}"

    rm -rf "$tmp_dir"
}

while true; do
    echo -e "${BLUE}Choose a Nerd Font to install:${ENDCOLOR}"
    echo -e "${CYAN}1) FiraCode${NC}"
    echo -e "${CYAN}2) Meslo${NC}"
    echo -e "${CYAN}3) JetBrains Mono${NC}"
    echo -e "${CYAN}4) Hack${NC}"
    echo -e "${CYAN}5) Cascadia${NC}"
    echo -e "${CYAN}6) Terminus${NC}"
    echo -e "${CYAN}7) Exit${NC}"
    
    read -p "Enter your choice: " choice

    case $choice in
        1) install_font "FiraCode" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip" ;;
        2) install_font "Meslo" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip" ;;
        3) install_font "JetBrains" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip" ;;
        4) install_font "Hack" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip" ;;
        5) install_font "Cascadia" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/CascadiaMono.zip" ;;
        6) install_font "Terminus" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Terminus.zip" ;;
        7) echo -e "${GREEN}Exiting. Thank you!${NC}"; exit ;;
        *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
    esac
done

