#!/bin/bash

tput init
tput clear
checkAlacritty() {
    if command -v alacritty &> /dev/null; then
        printf "Alacritty is already installed.\n"
    else
        printf "Alacritty is not installed. Installing now...\n"
        if [ -x "$(command -v pacman)" ]; then
            sudo pacman -S alacritty --noconfirm
        elif [ -x "$(command -v apt)" ]; then
            sudo apt install alacritty -y
        else
            printf "Unsupported package manager! Please install Alacritty manually.\n"
            exit 1
        fi
        printf "Alacritty has been installed.\n"
    fi
}

setupAlacrittyConfig() {
    printf "Copying Alacritty config files...\n"
    if [ -d "${HOME}/.config/alacritty" ] && [ ! -d "${HOME}/.config/alacritty-bak" ]; then
        cp -r "${HOME}/.config/alacritty" "${HOME}/.config/alacritty-bak"
        printf "Existing Alacritty configuration backed up to alacritty-bak.\n"
    fi
    mkdir -p "${HOME}/.config/alacritty/"
    curl -sSLo "${HOME}/.config/alacritty/alacritty.toml" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/alacritty/alacritty.toml"
    curl -sSLo "${HOME}/.config/alacritty/keybinds.toml" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/alacritty/keybinds.toml"
    curl -sSLo "${HOME}/.config/alacritty/nordic.toml" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/alacritty/nordic.toml"
    printf "Alacritty configuration files copied.\n"
}

checkAlacritty
setupAlacrittyConfig

printf "Alacritty setup complete.\n"
