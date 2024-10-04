#!/bin/bash

# Initialize colors for themes
tput init
tput clear
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to install Kitty and set up configuration
setup_kitty() {
    # Check if Kitty is installed
    if ! command -v kitty &> /dev/null; then
        echo -e "${CYAN}Kitty is not installed. Installing...${NC}"
        sudo pacman -S --needed kitty
    else
        echo -e "${GREEN}Kitty is already installed.${NC}"
    fi

    # Create the config directory if it doesn't exist
    CONFIG_DIR="$HOME/.config/kitty"
    BACKUP_DIR="$HOME/.config/kitty_backup"

    # Check if the kitty config directory exists
    if [ -d "$CONFIG_DIR" ]; then
        echo -e "${CYAN}Backing up existing Kitty configuration...${NC}"
        
        # Move existing configuration to the backup directory
        if [ ! -d "$BACKUP_DIR" ]; then
            mkdir "$BACKUP_DIR"
        fi

        # Move the current configuration to the backup directory
        mv "$CONFIG_DIR"/* "$BACKUP_DIR/" 2>/dev/null
    else
        echo -e "${GREEN}No existing Kitty configuration found.${NC}"
        mkdir -p "$CONFIG_DIR"  # Create the directory if it does not exist
    fi

    # Download the new configuration files
    echo -e "${CYAN}Downloading Kitty configuration files...${NC}"
    wget -q -P "$CONFIG_DIR" https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/kitty/kitty.conf
    wget -q -P "$CONFIG_DIR" https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/kitty/nord.conf

    echo -e "${GREEN}Kitty setup completed! Check your backup directory for previous configs at $BACKUP_DIR.${NC}"
}

# Run the setup function
setup_kitty
