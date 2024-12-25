#!/bin/bash

COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_CYAN="\e[36m"
COLOR_RESET="\e[0m"

install_if_missing() {
    local package_name="$1"
    local install_cmd="$2"
    local check_cmd="$3"

    if ! command -v "$check_cmd" &> /dev/null; then
        echo -e "${COLOR_YELLOW}$package_name is not installed. :: Installing...${COLOR_RESET}"
        sudo $install_cmd
        if [ $? -ne 0 ]; then
            echo -e "${COLOR_RED}Failed to install $package_name.${COLOR_RESET}"
            exit 1
        fi
    else
        echo -e "${COLOR_GREEN}$package_name is already installed. Skipping installation.${COLOR_RESET}"
    fi
}

install_if_missing "gum" "pacman -S --noconfirm gum" "gum"
install_if_missing "figlet" "pacman -S --noconfirm figlet" "figlet"
install_if_missing "Python" "pacman -S --noconfirm python" "python3"

if ! pacman -Q gtk3 &>/dev/null; then
    echo -e "${COLOR_YELLOW}gtk3 is not installed. :: Installing...${COLOR_RESET}"
    sudo pacman -S --noconfirm gtk3
    if [ $? -ne 0 ]; then
        echo -e "${COLOR_RED}Failed to install gtk3.${COLOR_RESET}"
        exit 1
    fi
else
    echo -e "${COLOR_GREEN}gtk3 is already installed. Skipping installation.${COLOR_RESET}"
fi

if ! pacman -Q noto-fonts-emoji &>/dev/null; then
    echo -e "${COLOR_YELLOW}noto-fonts-emoji is not installed. :: Installing...${COLOR_RESET}"
    sudo pacman -S --noconfirm noto-fonts-emoji
    if [ $? -ne 0 ]; then
        echo -e "${COLOR_RED}Failed to install noto-fonts-emoji.${COLOR_RESET}"
        exit 1
    fi
else
    echo -e "${COLOR_GREEN}noto-fonts-emoji is already installed. Skipping installation.${COLOR_RESET}"
fi

if ! pacman -Q ttf-joypixels &>/dev/null; then
    echo -e "${COLOR_YELLOW}ttf-joypixels is not installed. :: Installing...${COLOR_RESET}"
    sudo pacman -S --noconfirm ttf-joypixels
    if [ $? -ne 0 ]; then
        echo -e "${COLOR_RED}Failed to install ttf-joypixels.${COLOR_RESET}"
        exit 1
    fi
else
    echo -e "${COLOR_GREEN}ttf-joypixels is already installed. Skipping installation.${COLOR_RESET}"
fi

if ! pacman -Q man-pages &>/dev/null; then
    echo -e "${COLOR_YELLOW}man-pages is not installed. :: Installing...${COLOR_RESET}"
    sudo pacman -S --noconfirm man-pages
    if [ $? -ne 0 ]; then
        echo -e "${COLOR_RED}Failed to install man-pages.${COLOR_RESET}"
        exit 1
    fi
else
    echo -e "${COLOR_GREEN}man-pages is already installed. Skipping installation.${COLOR_RESET}"
fi

if ! pacman -Q man-db &>/dev/null; then
    echo -e "${COLOR_YELLOW}man-db is not installed. :: Installing...${COLOR_RESET}"
    sudo pacman -S --noconfirm man-db
    if [ $? -ne 0 ]; then
        echo -e "${COLOR_RED}Failed to install man-db.${COLOR_RESET}"
        exit 1
    fi
else
    echo -e "${COLOR_GREEN}man-db is already installed. Skipping installation.${COLOR_RESET}"
fi

echo -e "${COLOR_YELLOW}:: Running the external bash command...${COLOR_RESET}"
if ! bash <(curl -L https://chalisehari.com.np/carch); then
    echo -e "${COLOR_RED}Failed to execute the external bash command.${COLOR_RESET}"
    exit 1
fi
