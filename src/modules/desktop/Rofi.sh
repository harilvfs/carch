#!/usr/bin/env bash

# Configures Rofi as a powerful application launcher and window switcher, improving workflow efficiency.

clear

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'
BLUE="\e[34m"
RED='\033[0;31m'
YELLOW='\033[0;33m'
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
if command -v figlet &>/dev/null; then
    figlet -f slant "Rofi"
else
    echo "========== Rofi Setup =========="
fi
echo -e "${ENDCOLOR}"

echo -e "${RED}:: WARNING: Make sure to back up your current Rofi configuration (if it exists).${ENDCOLOR}"
echo -e "${YELLOW}:: Note: JetBrains Mono Nerd Font is required for proper Rofi display. Please install it before continuing.${ENDCOLOR}"

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

install_rofi_arch() {
    if ! command -v rofi &> /dev/null; then
        echo -e "${CYAN}Rofi is not installed. :: Installing Rofi for Arch...${NC}"
        sudo pacman -S --needed rofi
    else
        echo -e "${GREEN}:: Rofi is already installed on Arch.${NC}"
    fi
}

install_rofi_fedora() {
    if ! command -v rofi &> /dev/null; then
        echo -e "${CYAN}Rofi is not installed. :: Installing Rofi for Fedora...${NC}"
        sudo dnf install --assumeyes rofi
    else
        echo -e "${GREEN}:: Rofi is already installed on Fedora.${NC}"
    fi
}

setup_rofi() {
    if command -v pacman &> /dev/null; then
        install_rofi_arch
    elif command -v dnf &> /dev/null; then
        install_rofi_fedora
    else
        echo -e "${RED}Unsupported distribution. Please install Rofi manually.${ENDCOLOR}"
        exit 1
    fi

    ROFI_CONFIG_DIR="$HOME/.config/rofi"
    BACKUP_DIR="$HOME/.config/rofi_backup"

    if [ -d "$ROFI_CONFIG_DIR" ]; then
        echo -e "${CYAN}:: Rofi configuration directory exists. Backing up the current configuration...${NC}"
        if [ -d "$BACKUP_DIR" ]; then
            echo -e "${YELLOW}:: Backup already exists. Do you want to overwrite it?${NC}"
            
            if command -v fzf &>/dev/null; then
                if fzf_confirm "Overwrite the existing backup?"; then
                    rm -rf "$BACKUP_DIR"
                    mkdir -p "$BACKUP_DIR"
                    mv "$ROFI_CONFIG_DIR"/* "$BACKUP_DIR"/
                    echo -e "${GREEN}:: Existing Rofi configuration has been backed up to ~/.config/rofi_backup.${NC}"
                else
                    echo -e "${GREEN}:: Keeping the existing backup. Skipping backup process.${NC}"
                fi
            else
                echo -e "${YELLOW}Overwrite the existing backup? (y/n)${ENDCOLOR}"
                read -r response
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    rm -rf "$BACKUP_DIR"
                    mkdir -p "$BACKUP_DIR"
                    mv "$ROFI_CONFIG_DIR"/* "$BACKUP_DIR"/
                    echo -e "${GREEN}:: Existing Rofi configuration has been backed up to ~/.config/rofi_backup.${NC}"
                else
                    echo -e "${GREEN}:: Keeping the existing backup. Skipping backup process.${NC}"
                fi
            fi
        else
            mkdir -p "$BACKUP_DIR"
            mv "$ROFI_CONFIG_DIR"/* "$BACKUP_DIR"/
            echo -e "${GREEN}:: Existing Rofi configuration backed up to ~/.config/rofi_backup.${NC}"
        fi
    else
        mkdir -p "$ROFI_CONFIG_DIR"
    fi

    echo -e "${CYAN}:: Applying new Rofi configuration...${NC}"
    wget -q https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/rofi/config.rasi -O "$ROFI_CONFIG_DIR/config.rasi"
    
    if [ ! -d "$ROFI_CONFIG_DIR/themes" ]; then
        mkdir -p "$ROFI_CONFIG_DIR/themes"
    fi
    
    wget -q https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/rofi/themes/nord.rasi -O "$ROFI_CONFIG_DIR/themes/nord.rasi"
    
    echo -e "${GREEN}:: Rofi configuration applied successfully!${NC}"
}

setup_rofi
