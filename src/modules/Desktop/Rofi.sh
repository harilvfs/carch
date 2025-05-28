#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" >/dev/null 2>&1

if ! command -v fzf &> /dev/null; then
    echo -e "${RED}${BOLD}Error: fzf is not installed${NC}"
    echo -e "${YELLOW}Please install fzf before running this script:${NC}"
    echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install fzf"
    echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S fzf"
    exit 1
fi

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
    [[ "$selected" == "Yes" ]]
}

install_rofi_arch() {
    if ! command -v rofi &> /dev/null; then
        echo -e "${CYAN}Rofi is not installed. :: Installing Rofi for Arch...${NC}"
        sudo pacman -S --needed --noconfirm rofi
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
            echo -e "${YELLOW}:: Backup already exists.${NC}"
            if fzf_confirm "Overwrite the existing backup?"; then
                rm -rf "$BACKUP_DIR"
                mkdir -p "$BACKUP_DIR"
                mv "$ROFI_CONFIG_DIR"/* "$BACKUP_DIR"/
                echo -e "${GREEN}:: Existing Rofi configuration has been backed up to ~/.config/rofi_backup.${NC}"
            else
                echo -e "${GREEN}:: Keeping the existing backup. Skipping backup process.${NC}"
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

    mkdir -p "$ROFI_CONFIG_DIR/themes"
    wget -q https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/rofi/themes/nord.rasi -O "$ROFI_CONFIG_DIR/themes/nord.rasi"

    echo -e "${GREEN}:: Rofi configuration applied successfully!${NC}"
}

setup_rofi
