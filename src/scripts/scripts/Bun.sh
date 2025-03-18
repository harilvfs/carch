#!/bin/bash

check_fzf() {
    if ! command -v fzf &>/dev/null; then
        echo -e "${YELLOW}Installing fzf...${RESET}"
        if [[ "$PACKAGE_MANAGER" == "pacman" ]]; then
            sudo pacman -S --noconfirm fzf
        elif [[ "$PACKAGE_MANAGER" == "dnf" ]]; then
            sudo dnf install -y fzf
        fi
    fi
}

clear
BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

echo -e "${BLUE}"
figlet -f slant "Bun"
echo -e "${RESET}"

if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    DISTRO="$ID"
    DISTRO_LIKE="${ID_LIKE}" 
else
    echo -e "${RED}❌ Unable to detect your Linux distribution!${RESET}"
    exit 1
fi

if [[ "$DISTRO" == "arch" || "$ID_LIKE" == "arch" ]]; then
    PACKAGE_MANAGER="pacman"
elif [[ "$DISTRO" == "fedora" || "$ID_LIKE" == "rhel" || "$ID_LIKE" == "centos" ]]; then
    PACKAGE_MANAGER="dnf"
else
    echo -e "${RED}❌ Unsupported distribution!${RESET}"
    exit 1
fi

check_fzf

if command -v bun &>/dev/null; then
    echo -e "${GREEN}✅ Bun is already installed!${RESET}"
    exit 0
fi

if ! command -v npm &>/dev/null; then
    echo -e "${RED}❌ npm is not installed!${RESET}"
    echo -e "${YELLOW}ℹ Please install npm first from the main script before installing Bun.${RESET}"
    exit 1
fi

options=("Yes" "No")
continue_install=$(printf "%s\n" "${options[@]}" | fzf --prompt="⚠ npm is required to install Bun. Do you want to continue? " --height=10 --layout=reverse --border)

if [[ "$continue_install" != "Yes" ]]; then
    exit 0
fi

echo -e "${YELLOW}Installing Bun via npm...${RESET}"
npm install -g bun

if command -v bun &>/dev/null; then
    echo -e "${GREEN}✅ Bun installed successfully!${RESET}"
    exit 0
else
    echo -e "${RED}❌ npm install -g bun failed! Trying alternate method...${RESET}"
fi

if [[ "$PACKAGE_MANAGER" == "pacman" ]]; then
    echo -e "${YELLOW}Installing unzip...${RESET}"
    sudo pacman -S --noconfirm unzip
elif [[ "$PACKAGE_MANAGER" == "dnf" ]]; then
    echo -e "${YELLOW}Installing unzip...${RESET}"
    sudo dnf install -y unzip
fi

echo -e "${YELLOW}Installing Bun via curl...${RESET}"
bash -c "$(curl -fsSL https://bun.sh/install)"

if command -v bun &>/dev/null; then
    echo -e "${GREEN}✅ Bun installed successfully!${RESET}"
else
    echo -e "${RED}If Bun doesn't appear on your system automatically, source your ~/.profile, .zshrc, or .bashrc.${RESET}"
fi
