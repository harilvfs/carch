#!/bin/bash

COLOR_CYAN="\e[36m"
COLOR_RESET="\e[0m"

install_if_missing() {
    local package_name="$1"
    local install_cmd="$2"
    local check_cmd="$3"

    if ! command -v "$check_cmd" &> /dev/null; then
        echo "$package_name is not installed. Installing..."
        sudo $install_cmd
        if [ $? -ne 0 ]; then
            echo "Failed to install $package_name."
            exit 1
        fi
    else
        echo "$package_name is already installed. Skipping installation."
    fi
}

install_if_missing "libnewt" "pacman -S --noconfirm libnewt" "whiptail"
install_if_missing "gum" "pacman -S --noconfirm gum" "gum"
install_if_missing "figlet" "pacman -S --noconfirm figlet" "figlet"
install_if_missing "Python" "pacman -S --noconfirm python" "python3"

if ! pacman -Q gtk3 &>/dev/null; then
    echo "gtk3 is not installed. Installing..."
    sudo pacman -S --noconfirm gtk3
    if [ $? -ne 0 ]; then
        echo "Failed to install gtk3."
        exit 1
    fi
else
    echo "gtk3 is already installed. Skipping installation."
fi

echo -e "${COLOR_CYAN}Carch has been successfully installed!${COLOR_RESET}"
echo -e "${COLOR_CYAN}Use 'carch' or 'carch-gtk' to run the Carch script.${COLOR_RESET}"
echo -e "${COLOR_CYAN}For available commands, type 'carchcli --help'.${COLOR_RESET}"

