#!/bin/bash

clear

GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RESET='\033[0m'
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
figlet -f slant "Themes & Icons"
echo -e "${ENDCOLOR}"

echo -e "${CYAN}Theme and Icon Setup${RESET}"
echo -e "${YELLOW}----------------------${RESET}"

# Use gum to allow the user to select an option
option=$(gum choose "Setup Themes" "Setup Icons" "Exit")

check_and_create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo -e "${BLUE}Created directory: $1${RESET}"
    fi
}

install_dependencies() {
    echo -e "${BLUE}Installing dependencies...${RESET}"
    if [ "$XDG_SESSION_TYPE" == "x11" ]; then
        pacman -S lxappearance qt5-base qt6-base kvantum --noconfirm
    elif [ "$XDG_SESSION_TYPE" == "wayland" ]; then
        pacman -S nwg-look qt5-base qt6-base kvantum --noconfirm
    else
        echo -e "${YELLOW}Unknown session type.${RESET}"
        exit 1
    fi
}

setup_themes() {
    echo -e "${CYAN}Setting up Themes...${RESET}"
    cd /tmp || exit

    git clone https://github.com/harilvfs/themes
    cd themes || exit

    mv * /usr/share/themes/
    check_and_create_dir "$HOME/.config/.themes"
    mv * "$HOME/.config/.themes/"

    rm -rf .git README.md LICENSE

    check_and_create_dir "$HOME/.config/Kvantum"
    cp -r Kvantum "$HOME/.config/"

    echo -e "${GREEN}Themes have been set up successfully.${RESET}"
}

setup_icons() {
    echo -e "${CYAN}Setting up Icons...${RESET}"
    cd /tmp || exit

    git clone https://github.com/harilvfs/icons
    cd icons || exit

    mv * /usr/share/icons/
    check_and_create_dir "$HOME/.config/icons"
    mv * "$HOME/.config/icons/"

    rm -rf .git README.md LICENSE

    echo -e "${GREEN}Icons have been set up successfully.${RESET}"
}

confirm_and_proceed() {
    echo -e "${YELLOW}This will add themes to themes & icons directories, but you will need to manually select them using the appropriate app for your window manager (lxappearance for X11, nwg-look for Wayland).${RESET}"

    if ! gum confirm "Do you want to continue?"; then
        echo -e "${YELLOW}Operation canceled. Press Enter to return to the submenu.${RESET}"
        read -r
        exec "$0"  
    fi
}

case "$option" in
    "Setup Themes")
        confirm_and_proceed  
        install_dependencies
        setup_themes
        echo -e "${BLUE}Use lxappearance for X11 or nwg-look for Wayland to select the theme.${RESET}"
        ;;
    "Setup Icons")
        confirm_and_proceed  
        install_dependencies
        setup_icons
        echo -e "${BLUE}Use lxappearance for X11 or nwg-look for Wayland to select the icons.${RESET}"
        ;;
    "Exit")
        echo -e "${YELLOW}Exiting...${RESET}"
        exit 0
        ;;
    *)
        echo -e "${YELLOW}Invalid option. Exiting...${RESET}"
        exit 1
        ;;
esac

