#!/usr/bin/env bash

clear

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' 
BLUE="\e[34m"
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
figlet -f slant "Fastfetch"
echo -e "${ENDCOLOR}"

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

if ! fzf_confirm "Continue with Fastfetch setup?"; then
    echo -e "${RED}Setup aborted by the user.${NC}"
    exit 1
fi

FASTFETCH_DIR="$HOME/.config/fastfetch"
BACKUP_DIR="$HOME/.config/fastfetch_backup"

if command -v fastfetch &>/dev/null; then
    echo -e "${GREEN}Fastfetch is already installed.${NC}"
else
    echo -e "${CYAN}Fastfetch is not installed. Installing...${NC}"
    
    if [ -x "$(command -v pacman)" ]; then
        sudo pacman -S fastfetch git --noconfirm
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install fastfetch git -y
    else
        echo -e "${RED}Unsupported package manager! Please install Fastfetch manually.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Fastfetch has been installed.${NC}"
fi

if [ -d "$FASTFETCH_DIR" ]; then
    echo -e "${RED}Fastfetch configuration directory already exists.${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${CYAN}Creating backup directory...${NC}"
        mkdir -p "$BACKUP_DIR"
    fi
    echo -e "${CYAN}Backing up existing Fastfetch configuration...${NC}"
    mv "$FASTFETCH_DIR"/* "$BACKUP_DIR/" 2>/dev/null
    echo -e "${GREEN}Backup completed.${NC}"
fi

TEMP_DIR="/tmp/fastfetch-repo"
echo -e "${CYAN}Cloning Fastfetch repository...${NC}"
git clone https://github.com/harilvfs/fastfetch "$TEMP_DIR"

echo -e "${CYAN}Switching to old-days branch...${NC}"
cd "$TEMP_DIR" || exit 1
git switch old-days

mkdir -p "$FASTFETCH_DIR"

echo -e "${CYAN}Copying fastfetch configuration to ~/.config/...${NC}"
cp -r "$TEMP_DIR"/fastfetch/* "$FASTFETCH_DIR/"

echo -e "${CYAN}Cleaning up temporary files...${NC}"
rm -rf "$TEMP_DIR"
rm -rf "$FASTFETCH_DIR/.git" "$FASTFETCH_DIR/LICENSE" "$FASTFETCH_DIR/README.md"

while true; do
    read -rp "Are you using Alacritty? (y/n): " alacritty_choice
    case "$alacritty_choice" in
        [Yy]) 
            echo -e "${CYAN}Applying Alacritty-specific configuration...${NC}"
            if cd "$FASTFETCH_DIR"; then
                rm -f config.jsonc
                curl -sSLo config.jsonc "https://raw.githubusercontent.com/harilvfs/i3wmdotfiles/refs/heads/main/fastfetch/config.jsonc"
                echo -e "${GREEN}Updated Fastfetch config for Alacritty.${NC}"
            else
                echo -e "${RED}Error: Could not change to Fastfetch directory.${NC}"
            fi
            break
            ;;
        [Nn]) 
            echo -e "${CYAN}Skipping Alacritty-specific configuration.${NC}"
            break
            ;;
        *) echo -e "${CYAN}Please enter y or n.${NC}" ;;
    esac
done

echo -e "${GREEN}Fastfetch setup completed successfully!${NC}"
