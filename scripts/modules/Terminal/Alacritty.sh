#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

installAlacritty() {
    if command -v alacritty &> /dev/null; then
        echo -e "${GREEN}Alacritty is already installed.${NC}"
        return
    fi

    echo -e "${YELLOW}Alacritty is not installed. Installing now...${NC}"

    case "$DISTRO" in
        "Arch") sudo pacman -S alacritty --noconfirm ;;
        "Fedora") sudo dnf install alacritty -y ;;
        "openSUSE") sudo zypper install -y alacritty ;;
        *)
            echo -e "${RED}Unsupported package manager! Please install Alacritty manually.${NC}"
            exit 1
            ;;
    esac

    echo -e "${GREEN}Alacritty has been installed.${NC}"
}

setupAlacrittyConfig() {
    local alacritty_config_dir="$HOME/.config/alacritty"
    local backup_dir="$HOME/.config/carch/backups"

    echo -e "${CYAN}:: Setting up Alacritty configuration...${NC}"

    if [ -d "$alacritty_config_dir" ]; then
        echo -e "${YELLOW}:: Existing Alacritty configuration detected.${NC}"
        if confirm "Do you want to backup the existing configuration?"; then
            mkdir -p "$backup_dir"
            local backup_path="$backup_dir/alacritty.bak"
            if [ -d "$backup_path" ]; then
                echo -e "${YELLOW}Backup already exists. Overwriting...${NC}"
                rm -rf "$backup_path"
            fi
            mv "$alacritty_config_dir" "$backup_path"
            echo -e "${GREEN}:: Existing Alacritty configuration backed up to $backup_path.${NC}"
        else
            echo -e "${CYAN}:: Skipping backup. Your existing configuration will be overwritten.${NC}"
        fi
    fi

    mkdir -p "$alacritty_config_dir"

    base_url="https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/alacritty"
    for file in alacritty.toml keybinds.toml nordic.toml catppuccin-mocha.toml; do
        curl -sSLo "$alacritty_config_dir/$file" "$base_url/$file"
    done

    echo -e "${CYAN}:: Running 'alacritty migrate' to update the config...${NC}"
    (cd "$alacritty_config_dir" && alacritty migrate)

    echo -e "${GREEN}:: Alacritty configuration files copied and migrated.${NC}"
}

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

main() {
    installAlacritty
    setupAlacrittyConfig
    echo -e "${GREEN}:: Alacritty setup complete.${NC}"
}

main
