#!/bin/bash

tput init
tput clear
GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
figlet -f slant "Grub"
echo -e "${ENDCOLOR}"

print_message() {
    echo -e "${BLUE}:: This bootloader setup script is from Chris Titus Tech.${ENDCOLOR}"
    echo -e "${BLUE}:: Check out his GitHub for more: ${GREEN}https://github.com/christitustech${ENDCOLOR}"
}

request_sudo() {
    echo -e "${BLUE}:: Requesting sudo access to avoid permission issues during the script...${ENDCOLOR}"
    sudo -v || { echo -e "${RED}Sudo access required. Exiting...${ENDCOLOR}"; exit 1; }
}

backup_grub() {
    echo -e "${BLUE}:: Backing up /etc/default/grub to /etc/default/grub.backup...${ENDCOLOR}"
    if ! sudo cp -r /etc/default/grub /etc/default/grub.backup; then
        echo -e "${RED}Failed to back up GRUB configuration. Exiting...${ENDCOLOR}"
        exit 1
    fi
}

install_grub_theme() {
    echo -e "${BLUE}:: Cloning the GRUB themes repository from Chris Titus Tech...${ENDCOLOR}"
    cd /tmp || exit
    if ! git clone https://github.com/ChrisTitusTech/Top-5-Bootloader-Themes.git; then
        echo -e "${RED}Failed to clone the repository. Exiting...${ENDCOLOR}"
        exit 1
    fi

    echo -e "${BLUE}:: Running the GRUB theme installation...${ENDCOLOR}"
    cd Top-5-Bootloader-Themes || exit
    if ! sudo ./install.sh; then
        echo -e "${RED}GRUB theme installation failed. Exiting...${ENDCOLOR}"
        exit 1
    fi
}

print_message
echo -e "${RED}:: WARNING: Please ensure you have backed up your old GRUB configuration before proceeding.${ENDCOLOR}"

if ! gum confirm "Continue with Grub setup?"; then
    echo -e "${RED}Setup aborted by the user.${NC}"
    exit 1
fi

request_sudo
backup_grub
install_grub_theme

echo -e "${GREEN}GRUB setup completed. Please reboot your system to see the changes.${ENDCOLOR}"

