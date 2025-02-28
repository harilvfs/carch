#!/bin/bash

clear

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'
BLUE="\e[34m"
RED='\033[0;31m'
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
figlet -f slant "Kitty"
echo -e "${ENDCOLOR}"

echo -e "${RED}WARNING: This script will modify your Kitty configuration. A backup of your existing configuration will be created.${ENDCOLOR}"

if ! gum confirm "Continue with Kitty setup?"; then
    echo -e "${RED}Setup aborted by the user.${NC}"
    exit 1
fi

setup_kitty() {
    if ! command -v kitty &> /dev/null; then
        echo -e "${CYAN}Kitty is not installed. :: Installing...${NC}"
        
        if [ -x "$(command -v pacman)" ]; then
            sudo pacman -S --needed kitty
        elif [ -x "$(command -v dnf)" ]; then
            echo -e "${CYAN}Installing Kitty on Fedora...${NC}"
            sudo dnf install kitty -y
        else
            echo -e "${RED}Unsupported package manager. Please install Kitty manually.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}Kitty is already installed.${NC}"
    fi

    CONFIG_DIR="$HOME/.config/kitty"
    BACKUP_DIR="$HOME/.config/kitty_backup"

    if [ -d "$CONFIG_DIR" ]; then
        echo -e "${CYAN}:: Backing up existing Kitty configuration...${NC}"
        
        if [ ! -d "$BACKUP_DIR" ]; then
            mkdir "$BACKUP_DIR"
        fi

        mv "$CONFIG_DIR"/* "$BACKUP_DIR/" 2>/dev/null
    else
        echo -e "${GREEN}No existing Kitty configuration found.${NC}"
        mkdir -p "$CONFIG_DIR"  
    fi

    echo -e "${CYAN}:: Downloading Kitty configuration files...${NC}"
    
    wget -q -P "$CONFIG_DIR" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/kitty/kitty.conf"
    wget -q -P "$CONFIG_DIR" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/kitty/theme.conf"
    wget -q -P "$CONFIG_DIR" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/kitty/userprefs.conf"

    echo -e "${GREEN}Kitty setup completed! Check your backup directory for previous configs at $BACKUP_DIR.${NC}"
}

install_font() {
    if gum confirm "Do you want to install Cascadia Nerd Font Mono?"; then
        if [ -x "$(command -v pacman)" ]; then
            echo -e "${CYAN}Installing Cascadia Nerd Font Mono on Arch-based systems...${NC}"
            sudo pacman -S --needed ttf-cascadia-mono-nerd
        elif [ -x "$(command -v dnf)" ]; then
            echo -e "${CYAN}For Fedora, please download and install Cascadia Nerd Font Mono manually.${NC}"
            echo -e "${CYAN}Download it from: https://github.com/ryanoasis/nerd-fonts/releases/latest#cascadia-mono${NC}"
            echo -e "${CYAN}Then, unzip and move the font to the ~/.fonts directory and run 'fc-cache -vf'.${NC}"
        else
            echo -e "${RED}Unsupported package manager. Please install Cascadia Nerd Font Mono manually.${NC}"
        fi
    else
        echo -e "${CYAN}Skipping font installation.${NC}"
    fi
}

setup_kitty
install_font
