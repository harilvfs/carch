#!/bin/bash

tput init
tput clear

GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
figlet -f slant "Picom"
echo -e "${GREEN}"
cat << "EOF"
Picom is a standalone compositor for Xorg.
EOF
echo -e "${ENDCOLOR}"

install_paru() {
    if ! command -v paru &> /dev/null; then
        echo -e "${RED}Paru is not installed. :: Installing Paru...${ENDCOLOR}"
        sudo pacman -S --needed base-devel
        temp_dir=$(mktemp -d)
        cd "$temp_dir" || { echo -e "${RED}Failed to create temp directory${ENDCOLOR}"; exit 1; }
        git clone https://aur.archlinux.org/paru.git
        cd paru || { echo -e "${RED}Failed to enter paru directory${ENDCOLOR}"; exit 1; }
        makepkg -si
        cd ..
        rm -rf "$temp_dir"
        echo -e "${GREEN}Paru installed successfully.${ENDCOLOR}"
    else
        echo -e "${GREEN}:: Paru is already installed.${ENDCOLOR}"
    fi
}

print_source_message() {
    echo -e "${BLUE}:: This Picom build is from FT-Labs.${ENDCOLOR}"
    echo -e "${BLUE}:: Check out here: ${GREEN}https://github.com/FT-Labs/picom${ENDCOLOR}"
}

install_dependencies_normal() {
    echo -e "${GREEN}:: Installing Picom...${ENDCOLOR}"
    sudo pacman -S --needed picom
}

setup_picom_ftlabs() {
    echo -e "${GREEN}:: Installing Picom FT-Labs (picom-ftlabs-git) via paru...${ENDCOLOR}"
    paru -S picom-ftlabs-git --noconfirm
}

download_config() {
    local config_url="$1"
    local config_path="$HOME/.config/picom.conf"
    mkdir -p ~/.config
    echo -e "${GREEN}:: Downloading Picom configuration...${ENDCOLOR}"
    wget -O "$config_path" "$config_url"
}

print_source_message

choice=$(gum choose "Picom with animation (FT-Labs)" "Picom normal" "Exit")

case "$choice" in
    "Picom with animation (FT-Labs)")
        install_paru
        setup_picom_ftlabs
        download_config "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/picom/picom.conf"
        echo -e "${GREEN}:: Picom setup completed with animations from FT-Labs!${ENDCOLOR}"
        ;;
    "Picom normal")
        install_dependencies_normal
        download_config "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/picom/picom.conf"
        echo -e "${GREEN}:: Picom setup completed without animations!${ENDCOLOR}"
        ;;
    "Exit")
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option. Please try again.${ENDCOLOR}"
        exit 1
        ;;
esac

