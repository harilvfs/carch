#!/bin/bash

tput init
tput clear
GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"

print_source_message() {
    echo -e "${BLUE}This Picom build is from FT-Labs.${ENDCOLOR}"
    echo -e "${BLUE}Check out here: ${GREEN}https://github.com/FT-Labs/picom${ENDCOLOR}"
}

install_dependencies_animation() {
    echo -e "${GREEN}Installing necessary dependencies for Picom with animations...${ENDCOLOR}"
    sudo pacman -S --needed libx11 libx11-xcb libXext xproto xcb xcb-util xcb-damage xcb-dpms xcb-xfixes xcb-shape xcb-renderutil xcb-render xcb-randr xcb-composite xcb-image xcb-present xcb-glx pixman libdbus libconfig libGL libEGL libepoxy libpcre2 libev uthash meson ninja picom
}

install_dependencies_normal() {
    echo -e "${GREEN}Installing Picom...${ENDCOLOR}"
    sudo pacman -S --needed picom
}

setup_picom() {
    echo -e "${GREEN}Cloning Picom repository...${ENDCOLOR}"
    git clone https://github.com/FT-Labs/picom ~/picom
    cd ~/picom || { echo -e "${RED}Failed to enter picom directory. Exiting...${ENDCOLOR}"; exit 1; }

    echo -e "${GREEN}Setting up Picom...${ENDCOLOR}"
    meson setup --buildtype=release build
    ninja -C build

    echo -e "${GREEN}Picom built successfully.${ENDCOLOR}"
}

download_config() {
    local config_url="$1"
    local config_path="$HOME/.config/picom.conf"
    mkdir -p ~/.config
    echo -e "${GREEN}Downloading Picom configuration...${ENDCOLOR}"
    wget -O "$config_path" "$config_url"
}

print_source_message

echo -e "${BLUE}Select an option for Picom setup:${ENDCOLOR}"
echo "1. Picom with animation (dwm)"
echo "2. Picom normal"
echo "3. Exit"

read -p "Enter your choice [1-3]: " choice

case "$choice" in
    1)
        install_dependencies_animation
        setup_picom
        download_config "https://raw.githubusercontent.com/harilvfs/i3wmdotfiles/refs/heads/main/picom/picom-animations/picom.conf"
        echo -e "${GREEN}Picom setup completed with animations!${ENDCOLOR}"
        ;;
    2)
        install_dependencies_normal
        download_config "https://raw.githubusercontent.com/harilvfs/i3wmdotfiles/refs/heads/main/picom/picom.conf"
        echo -e "${GREEN}Picom setup completed without animations!${ENDCOLOR}"
        ;;
    3)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option. Please try again.${ENDCOLOR}"
        exit 1
        ;;
esac
