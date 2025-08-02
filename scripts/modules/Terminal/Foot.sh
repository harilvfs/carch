#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

confirm() {
    while true; do
        read -p "$(echo -e "${CYAN}$1 [y/N]: ${NC}")" answer
        case ${answer,,} in
            y | yes) return 0 ;;
            n | no | "") return 1 ;;
            *) echo -e "${YELLOW}Please answer with y/yes or n/no.${NC}" ;;
        esac
    done
}

install_foot() {
    if ! command -v foot &> /dev/null; then
        echo -e "${CYAN}Foot is not installed. :: Installing...${NC}"

        case "$DISTRO" in
            "Arch") sudo pacman -S --needed foot ;;
            "Fedora")
                echo -e "${CYAN}Installing Foot on Fedora...${NC}"
                sudo dnf install foot -y
                ;;
            "openSUSE")
                echo -e "${CYAN}Installing Foot on openSuse...${NC}"
                sudo zypper install -y foot
                ;;
            *)
                echo -e "${RED}Unsupported package manager. Please install Foot manually.${NC}"
                exit 1
                ;;
        esac
    else
        echo -e "${GREEN}Foot is already installed.${NC}"
    fi
}

install_fonts() {
    if confirm "Do you want to install JetBrains Mono Nerd Font?"; then
        case "$DISTRO" in
            "Arch")
                echo -e "${CYAN}Installing JetBrains Mono Nerd Font on Arch-based systems...${NC}"
                sudo pacman -S --needed ttf-jetbrains-mono-nerd
                ;;
            "Fedora")
                echo -e "${CYAN}Installing JetBrains Mono Nerd Font on Fedora...${NC}"
                sudo dnf install -y jetbrains-mono-fonts-all
                ;;
            "openSUSE")
                echo -e "${CYAN}Installing JetBrains Mono Font on openSUSE...${NC}"
                sudo zypper install -y jetbrains-mono-fonts
                ;;
            *)
                echo -e "${RED}Unsupported package manager. Please install the font manually.${NC}"
                ;;
        esac
    else
        echo -e "${CYAN}Skipping font installation. Make sure to install JetBrains Mono Nerd Font manually for proper rendering.${NC}"
    fi
}

setup_config() {
    CONFIG_DIR="$HOME/.config/foot"
    BACKUP_DIR="$HOME/.config/carch/backups/foot.bak"

    if [ -d "$CONFIG_DIR" ]; then
        echo -e "${CYAN}:: Existing Foot configuration detected.${NC}"

        if confirm "Do you want to backup the existing configuration?"; then
            mkdir -p "$(dirname "$BACKUP_DIR")"
            if [ -d "$BACKUP_DIR" ]; then
                echo -e "${YELLOW}Backup already exists.${NC}"
                if confirm "Do you want to overwrite the backup?"; then
                    rm -rf "$BACKUP_DIR"
                else
                    echo -e "${RED}Exiting to prevent data loss.${NC}"
                    exit 0
                fi
            fi
            mv "$CONFIG_DIR" "$BACKUP_DIR"
            mkdir -p "$CONFIG_DIR"
        else
            echo -e "${RED}Exiting to avoid overwriting existing config.${NC}"
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

main() {
    echo -e "${YELLOW}NOTE: This foot configuration uses Fish shell by default.${NC}"
    echo -e "${YELLOW}If you're using Bash or Zsh, make sure to change it in ~/.config/foot/foot.ini${NC}"
    echo -e "${YELLOW}Also, JetBrains Mono Nerd Font is required for this configuration.${NC}"
    echo

    install_foot
    install_fonts
    setup_config
}

main
