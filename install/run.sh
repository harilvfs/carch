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
        sudo $install_cmd &>/dev/null
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

install_package() {
    local package_name="$1"
    if ! pacman -Q "$package_name" &>/dev/null; then
        echo -e "${COLOR_YELLOW}$package_name is not installed. :: Installing...${COLOR_RESET}"
        sudo pacman -S --noconfirm "$package_name" &>/dev/null
        if [ $? -ne 0 ]; then
            echo -e "${COLOR_RED}Failed to install $package_name.${COLOR_RESET}"
            exit 1
        fi
    else
        echo -e "${COLOR_GREEN}$package_name is already installed. Skipping installation.${COLOR_RESET}"
    fi
}

install_package "noto-fonts-emoji"
install_package "ttf-joypixels"
install_package "man-pages"
install_package "man-db"

echo -e "${COLOR_YELLOW}:: Running the external bash command...${COLOR_RESET}"
if ! bash <(curl -L https://chalisehari.com.np/carch); then
    echo -e "${COLOR_RED}Failed to execute the external bash command.${COLOR_RESET}"
    exit 1
fi

