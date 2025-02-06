#!/bin/bash

clear

VERSION="4.1.2"

COLOR_RESET="\e[0m"
COLOR_YELLOW="\e[33m"
COLOR_CYAN="\e[36m"
COLOR_RED="\e[31m"

echo -e "${COLOR_CYAN}"
figlet -f slant "Carch"
echo "Version $VERSION"
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
    cd carch-git
elif [[ $CHOICE == "Stable Release" ]]; then
    echo -e "${COLOR_YELLOW}:: Installing Stable Release...${COLOR_RESET}"
    cd carch
fi

makepkg -si

