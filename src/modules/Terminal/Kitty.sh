#!/usr/bin/env bash

set -euo pipefail

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../fzf.sh" > /dev/null 2>&1

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

setup_kitty() {
    if ! command -v kitty &> /dev/null; then
        echo -e "${CYAN}Kitty is not installed. :: Installing...${NC}"

        if [ -x "$(command -v pacman)" ]; then
            sudo pacman -S --needed --noconfirm kitty
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf install kitty -y
        elif [ -x "$(command -v zypper)" ]; then
            sudo zypper install -y kitty
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
        mv "$CONFIG_DIR"/* "$BACKUP_DIR/" 2> /dev/null
    else
        echo -e "${GREEN}No existing Kitty configuration found.${NC}"
        mkdir -p "$CONFIG_DIR"
    fi

    echo -e "${CYAN}:: Downloading Kitty configuration files...${NC}"

    wget -q -P "$CONFIG_DIR" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/kitty/kitty.conf"
    wget -q -P "$CONFIG_DIR" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/kitty/theme.conf"
    wget -q -P "$CONFIG_DIR" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/kitty/userprefs.conf"
    wget -q -P "$CONFIG_DIR" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/kitty/tabs.conf"
    echo -e "${GREEN}Kitty setup completed! Check your backup directory for previous configs at $BACKUP_DIR.${NC}"
}

install_font() {
    if fzf_confirm "Do you want to install recommended fonts (Cascadia and JetBrains Mono Nerd Fonts)?"; then
        if [ -x "$(command -v pacman)" ]; then
            echo -e "${CYAN}Installing recommended fonts on Arch-based systems...${NC}"
            sudo pacman -S --needed ttf-cascadia-mono-nerd ttf-jetbrains-mono-nerd ttf-jetbrains-mono
        elif [ -x "$(command -v dnf)" ] || [ -x "$(command -v zypper)" ]; then
            echo -e "${CYAN}For Fedora and openSUSE, please download and install the fonts manually.${NC}"
            echo -e "${CYAN}Download Cascadia Nerd Font from: https://github.com/ryanoasis/nerd-fonts/releases/latest#cascadia-mono${NC}"
            echo -e "${CYAN}Download JetBrains Mono Nerd Font from: https://github.com/ryanoasis/nerd-fonts/releases/latest#jetbrains-mono${NC}"
            echo -e "${CYAN}Then, unzip and move the fonts to the ~/.fonts or ~/.local/share/fonts directory and run 'fc-cache -vf'.${NC}"
        else
            echo -e "${RED}Unsupported package manager. Please install the fonts manually.${NC}"
        fi
    else
        echo -e "${CYAN}Skipping font installation.${NC}"
    fi
}

check_fzf
setup_kitty
install_font
