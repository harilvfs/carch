#!/bin/bash

tput init
tput clear
clear

GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

echo "${CYAN}Theme and Icon Setup${RESET}"
echo "${YELLOW}----------------------${RESET}"

# Menu Options with colors
echo "${GREEN}1. Setup Themes${RESET}"
echo "${GREEN}2. Setup Icons${RESET}"
echo "${GREEN}3. Exit to Submenu${RESET}"
read -p "Choose an option: " option

check_and_create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "${BLUE}Created directory: $1${RESET}"
    fi
}

install_dependencies() {
    echo "${BLUE}Installing dependencies...${RESET}"
    if [ "$XDG_SESSION_TYPE" == "x11" ]; then
        pacman -S lxappearance qt5-base qt6-base kvantum --noconfirm
    elif [ "$XDG_SESSION_TYPE" == "wayland" ]; then
        pacman -S nwg-look qt5-base qt6-base kvantum --noconfirm
    else
        echo "${YELLOW}Unknown session type.${RESET}"
        exit 1
    fi
}

setup_themes() {
    echo "${CYAN}Setting up Themes...${RESET}"
    cd /tmp || exit

    git clone https://github.com/harilvfs/themes
    cd themes || exit

    mv * /usr/share/themes/
    check_and_create_dir "$HOME/.config/.themes"
    mv * "$HOME/.config/.themes/"

    rm -rf .git README.md LICENSE

    check_and_create_dir "$HOME/.config/Kvantum"
    cp -r Kvantum "$HOME/.config/"

    echo "${GREEN}Themes have been set up successfully.${RESET}"
}

setup_icons() {
    echo "${CYAN}Setting up Icons...${RESET}"
    cd /tmp || exit

    git clone https://github.com/harilvfs/icons
    cd icons || exit

    mv * /usr/share/icons/
    check_and_create_dir "$HOME/.config/icons"
    mv * "$HOME/.config/icons/"

    rm -rf .git README.md LICENSE

    echo "${GREEN}Icons have been set up successfully.${RESET}"
}

confirm_and_proceed() {
    echo "${YELLOW}This will add themes to themes & icons directories, but you will need to manually select them using the appropriate app for your window manager (lxappearance for X11, nwg-look for Wayland).${RESET}"
    read -p "Do you want to continue? (yes/no): " confirmation

    if [[ "$confirmation" != "yes" && "$confirmation" != "y" ]]; then
        echo "${YELLOW}Operation canceled. Press Enter to return to the submenu.${RESET}"
        read -r
        exec "$0"  
    fi
}

case $option in
    1)
        confirm_and_proceed  
        install_dependencies
        setup_themes
        echo "${BLUE}Use lxappearance for X11 or nwg-look for Wayland to select the theme.${RESET}"
        ;;
    2)
        confirm_and_proceed  
        install_dependencies
        setup_icons
        echo "${BLUE}Use lxappearance for X11 or nwg-look for Wayland to select the icons.${RESET}"
        ;;
    3)
        echo "${YELLOW}Exiting to submenu...${RESET}"
        exit 0
        ;;
    *)
        echo "${YELLOW}Invalid option. Exiting...${RESET}"
        exit 1
        ;;
esac
