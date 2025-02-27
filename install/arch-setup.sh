#!/bin/bash

VERSION="4.1.4"

COLOR_RESET="\e[0m"
COLOR_YELLOW="\e[33m"
COLOR_CYAN="\e[36m"
COLOR_RED="\e[31m"

if [ -f /etc/os-release ]; then
    DISTRO=$(grep ^NAME= /etc/os-release | cut -d= -f2 | tr -d '"')
elif command -v lsb_release &>/dev/null; then
    DISTRO=$(lsb_release -d | cut -f2)
else
    DISTRO="Unknown Linux Distribution"
fi

check_and_install() {
    local pkg="$1"
    if ! command -v "$pkg" &>/dev/null; then
        echo -e "${COLOR_YELLOW}:: Installing missing dependency: $pkg${COLOR_RESET}"
        sudo pacman -Sy --noconfirm "$pkg"
    fi
}

check_and_install "gum"
check_and_install "figlet"
check_and_install "ttf-jetbrains-mono-nerd"
check_and_install "ttf-jetbrains-mono"

clear

echo -e "${COLOR_CYAN}"
figlet -f slant "Carch"
echo "Version $VERSION"
echo "Distribution: $DISTRO"
echo -e "${COLOR_RESET}"

echo -e "${COLOR_YELLOW}Select installation type:${COLOR_RESET}"
CHOICE=$(gum choose "Rolling Release" "Stable Release" "Cancel")

if [[ $CHOICE == "Cancel" ]]; then
    echo -e "${COLOR_RED}Installation canceled by the user.${COLOR_RESET}"
    exit 0
fi

mkdir -p ~/.cache/carch-install
cd ~/.cache/carch-install || exit 1

rm -rf pkgs

git clone https://github.com/carch-org/pkgs
cd pkgs || exit 1

if [[ $CHOICE == "Rolling Release" ]]; then
    echo -e "${COLOR_YELLOW}:: Installing Rolling Release...${COLOR_RESET}"
    cd carch-git || exit
elif [[ $CHOICE == "Stable Release" ]]; then
    echo -e "${COLOR_YELLOW}:: Installing Stable Release...${COLOR_RESET}"
    cd carch || exit
fi

makepkg -si

