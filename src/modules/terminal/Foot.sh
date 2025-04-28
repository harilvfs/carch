#!/usr/bin/env bash

# Sets up the Foot terminal emulator with wayland support and custom configurations.

clear

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'
BLUE="\e[34m"
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET="\033[0m"

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

fzf_confirm() {
    local prompt="$1"
    local options=("Yes" "No")
    local selected=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                     --height=40% \
                                                     --prompt="$prompt " \
                                                     --header="Confirm" \
                                                     --pointer="➤" \
                                                     --color='fg:white,fg+:green,bg+:black,pointer:green')
    
    if [[ "$selected" == "Yes" ]]; then
        return 0
    else
        return 1
    fi
}

echo -e "${YELLOW}NOTE: This foot configuration uses Fish shell by default.${RESET}"
echo -e "${YELLOW}If you're using Bash or Zsh, make sure to change it in ~/.config/foot/foot.ini${RESET}"
echo -e "${YELLOW}Also, JetBrains Mono Nerd Font is required for this configuration.${RESET}"
echo

setup_foot() {
    if ! command -v foot &> /dev/null; then
        echo -e "${CYAN}Foot is not installed. :: Installing...${NC}"
        
        if command -v pacman &> /dev/null; then
            sudo pacman -S --needed foot
        elif command -v dnf &> /dev/null; then
            echo -e "${CYAN}Installing Foot on Fedora...${NC}"
            sudo dnf install foot -y
        else
            echo -e "${RED}Unsupported package manager. Please install Foot manually.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}Foot is already installed.${NC}"
    fi

    if fzf_confirm "Do you want to install JetBrains Mono Nerd Font?"; then
        if command -v pacman &> /dev/null; then
            echo -e "${CYAN}Installing JetBrains Mono Nerd Font on Arch-based systems...${NC}"
            sudo pacman -S --needed ttf-jetbrains-mono-nerd
        elif command -v dnf &> /dev/null; then
            echo -e "${CYAN}Installing JetBrains Mono Nerd Font on Fedora...${NC}"
            sudo dnf install jetbrains-mono-fonts-all -y
            
            echo -e "${YELLOW}For Nerd Font symbols, you may need to manually install:${RESET}"
            echo -e "${CYAN}Download JetBrains Mono Nerd Font from: https://github.com/ryanoasis/nerd-fonts/releases/latest${NC}"
            echo -e "${CYAN}Then, unzip and move the fonts to the ~/.local/share/fonts directory and run 'fc-cache -fv'.${NC}"
        else
            echo -e "${RED}Unsupported package manager. Please install the font manually.${NC}"
        fi
    else
        echo -e "${CYAN}Skipping font installation. Make sure to install JetBrains Mono Nerd Font manually for proper rendering.${NC}"
    fi

    CONFIG_DIR="$HOME/.config/foot"
    BACKUP_DIR="$HOME/.config/foot.bak"

    if [ -d "$CONFIG_DIR" ]; then
        echo -e "${CYAN}:: Existing Foot configuration detected.${NC}"
        
        if fzf_confirm "Do you want to backup the existing configuration?"; then
            if [ -d "$BACKUP_DIR" ]; then
                echo -e "${YELLOW}Backup already exists.${RESET}"
                if fzf_confirm "Do you want to overwrite the backup?"; then
                    rm -rf "$BACKUP_DIR"
                else
                    echo -e "${RED}Exiting to prevent data loss.${RESET}"
                    exit 0
                fi
            fi
            mv "$CONFIG_DIR" "$BACKUP_DIR"
            mkdir -p "$CONFIG_DIR"
        else
            echo -e "${RED}Exiting to avoid overwriting existing config.${RESET}"
            exit 0
        fi
    else
        echo -e "${GREEN}No existing Foot configuration found. Creating directory...${NC}"
        mkdir -p "$CONFIG_DIR"
    fi

    echo -e "${CYAN}:: Downloading Foot configuration...${NC}"
    
    wget -q -O "$CONFIG_DIR/foot.ini" "https://raw.githubusercontent.com/harilvfs/swaydotfiles/refs/heads/main/foot/foot.ini"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Foot configuration downloaded successfully!${NC}"
        echo -e "${GREEN}Foot setup completed!${NC}"
        if [ -d "$BACKUP_DIR" ]; then
            echo -e "${GREEN}Check your backup directory for previous configs at $BACKUP_DIR.${NC}"
        fi
    else
        echo -e "${RED}Failed to download Foot configuration.${NC}"
        echo -e "${YELLOW}Please check your internet connection and try again.${NC}"
        if [ -d "$BACKUP_DIR" ]; then
            echo -e "${YELLOW}Restoring backup...${NC}"
            rm -rf "$CONFIG_DIR"
            mv "$BACKUP_DIR" "$CONFIG_DIR"
            echo -e "${GREEN}Backup restored.${NC}"
        fi
    fi
}

setup_foot 
