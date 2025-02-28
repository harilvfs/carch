#!/bin/bash

clear

GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
figlet -f slant "Grub"
echo -e "${ENDCOLOR}"

GRUB_THEME_DIR="$HOME/.local/share/Top-5-Bootloader-Themes"

print_message() {
    echo -e "${BLUE}:: This bootloader setup script is from Chris Titus Tech.${ENDCOLOR}"
    echo -e "${BLUE}:: Check out his GitHub for more: ${GREEN}https://github.com/christitustech${ENDCOLOR}"
}

check_existing_dir() {
    if [[ -d "$GRUB_THEME_DIR" ]]; then
        echo -e "${RED}:: Directory $GRUB_THEME_DIR already exists.${ENDCOLOR}"
        if gum confirm "Do you want to overwrite it?"; then
            echo -e "${BLUE}:: Removing existing directory...${ENDCOLOR}"
            rm -rf "$GRUB_THEME_DIR"
        else
            echo -e "${RED}:: Aborting installation.${ENDCOLOR}"
            exit 1
        fi
    fi
}

clone_repo() {
    echo -e "${BLUE}:: Cloning GRUB themes repository...${ENDCOLOR}"
    git clone https://github.com/harilvfs/Top-5-Bootloader-Themes "$GRUB_THEME_DIR"
}

install_theme() {
    echo -e "${BLUE}:: Running the installation script...${ENDCOLOR}"
    cd "$GRUB_THEME_DIR" || exit
    sudo ./install.sh
}

print_message

echo -e "${RED}:: WARNING: Ensure you have backed up your GRUB configuration before proceeding.${ENDCOLOR}"

if ! gum confirm "Continue with Grub setup?"; then
    echo -e "${RED}:: Setup aborted by the user.${ENDCOLOR}"
    exit 1
fi

check_existing_dir
clone_repo
install_theme

echo -e "${GREEN}:: GRUB setup completed.${ENDCOLOR}"

if gum confirm "Do you want to reboot now?"; then
    gum spin --spinner dot --title "Rebooting system..." -- sudo reboot
fi

