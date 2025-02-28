#!/bin/bash

clear

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BLUE="\e[34m"
NC='\033[0m'

FONTS_DIR="$HOME/.fonts"

check_dependencies() {
    if ! command -v unzip &>/dev/null; then
        echo -e "${RED}Error: 'unzip' is not installed. Please install it first.${NC}"
        exit 1
    fi

    if ! command -v gum &>/dev/null; then
        echo -e "${RED}Error: 'gum' is not installed. Please install it first.${NC}"
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
    local font_url="$2"

    echo -e "${CYAN}:: Downloading $font_name to /tmp...${NC}"
    curl -L "$font_url" -o "/tmp/${font_name}.zip"

    echo -e "${CYAN}:: Extracting $font_name...${NC}"
    mkdir -p "$FONTS_DIR"
    unzip -q "/tmp/${font_name}.zip" -d "$FONTS_DIR"

    echo -e "${CYAN}:: Refreshing font cache...${NC}"
    fc-cache -vf

    echo -e "${GREEN}$font_name installed successfully in $FONTS_DIR!${NC}"
}

choose_fonts() {
    echo -e "${BLUE}"
    figlet -f slant "Fonts"
    echo -e "${GREEN} Select Font With 'x' Key ${NC}"
    echo -e "${NC}"

    FONT_SELECTION=$(gum choose --no-limit "FiraCode" "Meslo" "JetBrains Mono" "Hack" "CascadiaMono" "Terminus" "Exit")

    if [[ "$FONT_SELECTION" == "Exit" ]]; then
        echo -e "${GREEN}Exiting. Thank you!${NC}"
        exit 0
    fi

    for font in $FONT_SELECTION; do
        case "$font" in
            "FiraCode")
                if [[ "$OS_TYPE" == "arch" ]]; then
                    install_font_arch "ttf-firacode-nerd"
                else
                    install_font_fedora "FiraCode" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip"
                fi
                ;;
            "Meslo")
                if [[ "$OS_TYPE" == "arch" ]]; then
                    install_font_arch "ttf-meslo-nerd"
                else
                    install_font_fedora "Meslo" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip"
                fi
                ;;
            "JetBrains Mono")
                if [[ "$OS_TYPE" == "arch" ]]; then
                    install_font_arch "ttf-jetbrains-mono-nerd"
                else
                    install_font_fedora "JetBrainsMono" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"
                fi
                ;;
            "Hack")
                if [[ "$OS_TYPE" == "arch" ]]; then
                    install_font_arch "ttf-hack-nerd"
                else
                    install_font_fedora "Hack" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip"
                fi
                ;;
            "CascadiaMono")
                if [[ "$OS_TYPE" == "arch" ]]; then
                    install_font_arch "ttf-cascadia-mono-nerd"
                else
                    install_font_fedora "CascadiaMono" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/CascadiaMono.zip"
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

check_dependencies
detect_os
choose_fonts

