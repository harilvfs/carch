#!/usr/bin/env bash

clear

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BLUE="\e[34m"
NC='\033[0m'

FONTS_DIR="$HOME/.fonts"

get_latest_release() {
    curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" | 
    grep '"tag_name":' | 
    sed -E 's/.*"v([^"]+)".*/\1/'
}

fzf_confirm() {
    local prompt="$1"
    local options=("Yes" "No")
    local selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="$prompt " --height=10 --layout=reverse --border)
    
    if [[ "$selected" == "Yes" ]]; then
        return 0
    else
        return 1
    fi
}

fzf_select_fonts() {
    local options=("FiraCode" "Meslo" "JetBrains Mono" "Hack" "CascadiaMono" "Terminus" "Exit")
    printf "%s\n" "${options[@]}" | fzf --prompt="Select fonts (TAB to mark, ENTER to confirm): " --multi --height=15 --layout=reverse --border
}

check_dependencies() {
    if ! command -v unzip &>/dev/null; then
        echo -e "${RED}Error: 'unzip' is not installed. Please install it first.${NC}"
        exit 1
    fi

    if ! command -v fzf &>/dev/null; then
        echo -e "${RED}Error: 'fzf' is not installed. Please install it first.${NC}"
        exit 1
    fi

    if ! command -v curl &>/dev/null; then
        echo -e "${RED}Error: 'curl' is not installed. Please install it first.${NC}"
        exit 1
    fi
}

install_font_arch() {
    local font_pkg="$1"
    echo -e "${CYAN}:: Installing $font_pkg via pacman...${NC}"
    sudo pacman -S --noconfirm "$font_pkg"
    echo -e "${GREEN}$font_pkg installed successfully!${NC}"
}

install_font_fedora() {
    local font_name="$1"
    local latest_version=$(get_latest_release)
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${latest_version}/${font_name}.zip"

    echo -e "${CYAN}:: Downloading $font_name version ${latest_version} to /tmp...${NC}"
    curl -L "$font_url" -o "/tmp/${font_name}.zip"

    echo -e "${CYAN}:: Extracting $font_name...${NC}"
    mkdir -p "$FONTS_DIR"
    unzip -q "/tmp/${font_name}.zip" -d "$FONTS_DIR"

    echo -e "${CYAN}:: Refreshing font cache...${NC}"
    fc-cache -vf

    echo -e "${GREEN}$font_name installed successfully in $FONTS_DIR!${NC}"
}

choose_fonts() {
    local return_to_menu=true

    while $return_to_menu; do
        clear
        if command -v figlet &>/dev/null; then
            echo -e "${BLUE}"
            figlet -f slant "Fonts"
            echo -e "${NC}"
        fi
        
        echo -e "${GREEN}Select fonts to install (use TAB to select multiple)${NC}"

        FONT_SELECTION=$(fzf_select_fonts)

        if [[ "$FONT_SELECTION" == *"Exit"* ]]; then
            echo -e "${GREEN}Exiting font installation. Thank you!${NC}"
            return
        fi

        for font in $FONT_SELECTION; do
            case "$font" in
                "FiraCode")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "ttf-firacode-nerd"
                    else
                        install_font_fedora "FiraCode"
                    fi
                    ;;
                "Meslo")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "ttf-meslo-nerd"
                    else
                        install_font_fedora "Meslo"
                    fi
                    ;;
                "JetBrains Mono")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "ttf-jetbrains-mono-nerd" "ttf-jetbrains-mono"
                    else
                        install_font_fedora "JetBrainsMono"
                    fi
                    ;;
                "Hack")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "ttf-hack-nerd"
                    else
                        install_font_fedora "Hack"
                    fi
                    ;;
                "CascadiaMono")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "ttf-cascadia-mono-nerd" "ttf-cascadia-code-nerd"
                    else
                        install_font_fedora "CascadiaMono"
                    fi
                    ;;
                "Terminus")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "terminus-font"
                    else
                        echo -e "${RED}Terminus font is not available as a Nerd Font.${NC}"
                    fi
                    ;;
            esac
        done

        echo -e "${GREEN}All selected fonts installed successfully!${NC}"
        echo -e "${CYAN}Press Enter to return to the font selection menu or type 'q' to quit...${NC}"
        read -r choice
        
        if [[ "$choice" == "q" ]]; then
            return_to_menu=false
        fi
    done
}

detect_os() {
    if command -v pacman &>/dev/null; then
        OS_TYPE="arch"
    elif command -v dnf &>/dev/null; then
        OS_TYPE="fedora"
    else
        echo -e "${RED}Unsupported OS. Please install fonts manually.${NC}"
        exit 1
    fi
}

main() {
    check_dependencies
    detect_os
    
    if ! fzf_confirm "This script will install Nerd Fonts on your system. Continue?"; then
        echo -e "${RED}Setup aborted by the user. Exiting...${NC}"
        exit 1
    fi
    
    choose_fonts
    
    echo -e "${GREEN}Font installation completed. Thank you for using this script!${NC}"
}

main
