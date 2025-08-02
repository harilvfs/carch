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

setup_kitty() {
    if ! command -v kitty &> /dev/null; then
        echo -e "${CYAN}Kitty is not installed. :: Installing...${NC}"

        case "$DISTRO" in
            "Arch") sudo pacman -S --needed --noconfirm kitty ;;
            "Fedora") sudo dnf install kitty -y ;;
            "openSUSE") sudo zypper install -y kitty ;;
            *)
                echo -e "${RED}Unsupported package manager. Please install Kitty manually.${NC}"
                exit 1
                ;;
        esac
    else
        echo -e "${GREEN}Kitty is already installed.${NC}"
    fi

    CONFIG_DIR="$HOME/.config/kitty"
    BACKUP_DIR="$HOME/.config/carch/backups/kitty.bak"

    if [ -d "$CONFIG_DIR" ]; then
        echo -e "${CYAN}:: Existing Kitty configuration detected.${NC}"
        if confirm "Do you want to backup the existing configuration?"; then
            mkdir -p "$(dirname "$BACKUP_DIR")"
            if [ -d "$BACKUP_DIR" ]; then
                echo -e "${YELLOW}Backup already exists. Overwriting...${NC}"
                rm -rf "$BACKUP_DIR"
            fi
            mv "$CONFIG_DIR" "$BACKUP_DIR"
            echo -e "${GREEN}:: Existing Kitty configuration backed up to $BACKUP_DIR.${NC}"
        else
            echo -e "${CYAN}:: Skipping backup. Your existing configuration will be overwritten.${NC}"
        fi
    fi

    mkdir -p "$CONFIG_DIR"

    echo -e "${CYAN}:: Downloading Kitty configuration files...${NC}"

    wget -q -P "$CONFIG_DIR" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/kitty/kitty.conf"
    wget -q -P "$CONFIG_DIR" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/kitty/theme.conf"
    wget -q -P "$CONFIG_DIR" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/kitty/userprefs.conf"
    wget -q -P "$CONFIG_DIR" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/kitty/tabs.conf"
    echo -e "${GREEN}Kitty setup completed! Check your backup directory for previous configs at $BACKUP_DIR.${NC}"
}

install_font() {
    if confirm "Do you want to install recommended fonts (Cascadia and JetBrains Mono Nerd Fonts)?"; then
        case "$DISTRO" in
            "Arch")
                echo -e "${CYAN}Installing recommended fonts on Arch-based systems...${NC}"
                sudo pacman -S --needed ttf-cascadia-mono-nerd ttf-jetbrains-mono-nerd ttf-jetbrains-mono
                ;;
            "Fedora" | "openSUSE")
                echo -e "${CYAN}For Fedora and openSUSE, please download and install the fonts manually.${NC}"
                echo -e "${CYAN}Download Cascadia Nerd Font from: https://github.com/ryanoasis/nerd-fonts/releases/latest#cascadia-mono${NC}"
                echo -e "${CYAN}Download JetBrains Mono Nerd Font from: https://github.com/ryanoasis/nerd-fonts/releases/latest#jetbrains-mono${NC}"
                echo -e "${CYAN}Then, unzip and move the fonts to the ~/.fonts or ~/.local/share/fonts directory and run 'fc-cache -vf'.${NC}"
                ;;
            *)
                echo -e "${RED}Unsupported package manager. Please install the fonts manually.${NC}"
                ;;
        esac
    else
        echo -e "${CYAN}Skipping font installation.${NC}"
    fi
}

setup_kitty
install_font
