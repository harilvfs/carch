#!/usr/bin/env bash

# Sets up the Ghostty terminal emulator with GPU acceleration and custom configurations.

clear

source "$(dirname "$0")/../colors.sh" >/dev/null 2>&1

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

if ! command -v fzf &> /dev/null; then
    echo -e "${RED}${BOLD}Error: fzf is not installed${NC}"
    echo -e "${YELLOW}Please install fzf before running this script:${NC}"
    echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install fzf"
    echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S fzf"
    exit 1
fi

echo -e "${YELLOW}NOTE: This Ghostty configuration uses JetBrains Mono Nerd Font by default.${RESET}"
echo -e "${YELLOW}You can change themes and other settings in ~/.config/ghostty/config${RESET}"
echo -e "${YELLOW}For more configuration options, check the Ghostty docs at: https://ghostty.org/docs${RESET}"
echo

setup_ghostty() {
    if ! command -v ghostty &> /dev/null; then
        echo -e "${CYAN}Ghostty is not installed. :: Installing...${NC}"

        if command -v pacman &> /dev/null; then
            echo -e "${CYAN}Installing Ghostty on Arch-based systems...${NC}"
            sudo pacman -S --needed ghostty
        elif command -v dnf &> /dev/null; then
            echo -e "${CYAN}Installing Ghostty on Fedora...${NC}"
            sudo dnf copr enable pgdev/ghostty -y
            sudo dnf install ghostty -y
        else
            echo -e "${RED}Unsupported package manager. Please install Ghostty manually.${NC}"
            echo -e "${CYAN}See https://ghostty.org/docs/install for installation instructions.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}Ghostty is already installed.${NC}"
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

    CONFIG_DIR="$HOME/.config/ghostty"
    BACKUP_DIR="$HOME/.config/ghostty.bak"

    if [ -d "$CONFIG_DIR" ]; then
        echo -e "${CYAN}:: Existing Ghostty configuration detected.${NC}"

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
        echo -e "${GREEN}No existing Ghostty configuration found. Creating directory...${NC}"
        mkdir -p "$CONFIG_DIR"
    fi

    echo -e "${CYAN}:: Downloading Ghostty configuration...${NC}"

    wget -q -O "$CONFIG_DIR/config" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/ghostty/config"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Ghostty configuration downloaded successfully!${NC}"
        echo -e "${CYAN}Note: The default theme is set to 'catppuccin-mocha'. You can change this in the config file.${NC}"
        echo -e "${GREEN}Ghostty setup completed!${NC}"
        if [ -d "$BACKUP_DIR" ]; then
            echo -e "${GREEN}Check your backup directory for previous configs at $BACKUP_DIR.${NC}"
        fi
    else
        echo -e "${RED}Failed to download Ghostty configuration.${NC}"
        echo -e "${YELLOW}Please check your internet connection and try again.${NC}"
        if [ -d "$BACKUP_DIR" ]; then
            echo -e "${YELLOW}Restoring backup...${NC}"
            rm -rf "$CONFIG_DIR"
            mv "$BACKUP_DIR" "$CONFIG_DIR"
            echo -e "${GREEN}Backup restored.${NC}"
        fi
    fi
}

setup_ghostty
