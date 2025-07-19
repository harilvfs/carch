#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

installAlacritty() {
    if command -v alacritty &> /dev/null; then
        echo -e "${GREEN}Alacritty is already installed.${NC}"
        return
    fi

    echo -e "${YELLOW}Alacritty is not installed. Installing now...${NC}"

    if [ -x "$(command -v pacman)" ]; then
        sudo pacman -S alacritty --noconfirm
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install alacritty -y
    elif [ -x "$(command -v zypper)" ]; then
        sudo zypper install -y alacritty
    else
        echo -e "${RED}Unsupported package manager! Please install Alacritty manually.${NC}"
        exit 1
    fi

    echo -e "${GREEN}Alacritty has been installed.${NC}"
}

setupAlacrittyConfig() {
    local alacritty_config="${HOME}/.config/alacritty"

    echo -e "${CYAN}:: Setting up Alacritty configuration...${NC}"

    if [ -d "$alacritty_config" ] && [ ! -d "${alacritty_config}-bak" ]; then
        mv "$alacritty_config" "${alacritty_config}-bak"
        echo -e "${YELLOW}:: Existing Alacritty configuration backed up to alacritty-bak.${NC}"
    fi

    mkdir -p "$alacritty_config"

    base_url="https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/alacritty"
    for file in alacritty.toml keybinds.toml nordic.toml catppuccin-mocha.toml; do
        curl -sSLo "$alacritty_config/$file" "$base_url/$file"
    done

    echo -e "${CYAN}:: Running 'alacritty migrate' to update the config...${NC}"
    (cd "$alacritty_config" && alacritty migrate)

    echo -e "${GREEN}:: Alacritty configuration files copied and migrated.${NC}"
}

installAlacritty
setupAlacrittyConfig

echo -e "${GREEN}:: Alacritty setup complete.${NC}"
