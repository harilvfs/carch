#!/bin/bash

VERSION="4.1.6"
COLOR_RESET="\e[0m"
COLOR_YELLOW="\e[33m"
COLOR_CYAN="\e[36m"
COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"

if [ -f /etc/os-release ]; then
    DISTRO=$(grep ^NAME= /etc/os-release | cut -d= -f2 | tr -d '"')
elif command -v lsb_release &>/dev/null; then
    DISTRO=$(lsb_release -d | cut -f2)
else
    DISTRO="Unknown Linux Distribution"
fi

ARCH=$(uname -m)

check_and_install() {
    local pkg="$1"
    if ! pacman -Qi "$pkg" &>/dev/null; then
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
echo "Architecture: $ARCH"
echo -e "${COLOR_RESET}"

echo -e "${COLOR_GREEN}NOTE: Stable Release is recommended. Binary package is also suitable for use.${COLOR_RESET}"
echo -e "${COLOR_RED}Git package is not fully recommended as it grabs the latest commit which may have bugs.${COLOR_RESET}"
echo

echo -e "${COLOR_YELLOW}Select installation type:${COLOR_RESET}"
CHOICE=$(gum choose "Stable Release [Recommended]" "Carch-bin [Compile Binary]" "Carch-git [GitHub Latest Commit]" "Cancel")

if [[ $CHOICE == "Cancel" ]]; then
    echo -e "${COLOR_RED}Installation canceled by the user.${COLOR_RESET}"
    exit 0
fi

mkdir -p ~/.cache/carch-install
cd ~/.cache/carch-install || exit 1
rm -rf pkgs
git clone https://github.com/carch-org/pkgs
cd pkgs || exit 1

if [[ $CHOICE == "Carch-git [GitHub Latest Commit]" ]]; then
    echo -e "${COLOR_YELLOW}:: Installing Git Version (Latest Commit)...${COLOR_RESET}"
    cd carch-git || exit
elif [[ $CHOICE == "Carch-bin [Compile Binary]" ]]; then
    echo -e "${COLOR_YELLOW}:: Installing Binary Package...${COLOR_RESET}"
    cd carch-bin || exit
elif [[ $CHOICE == "Stable Release [Recommended]" ]]; then
    echo -e "${COLOR_YELLOW}:: Installing Stable Release...${COLOR_RESET}"
    cd carch || exit
fi

makepkg -si
