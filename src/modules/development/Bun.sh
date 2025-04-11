#!/usr/bin/env bash

# Installs and configures Bun, a fast JavaScript runtime for modern development.

BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

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

if command -v pacman &> /dev/null; then
    PACKAGE_MANAGER="pacman"
elif command -v dnf &> /dev/null; then
    PACKAGE_MANAGER="dnf"
else
    PACKAGE_MANAGER="unknown"
fi

clear
echo -e "${BLUE}"
figlet -f slant "Bun"
echo -e "${RESET}"

if command -v bun &>/dev/null; then
    echo -e "${GREEN}✅ Bun is already installed!${RESET}"
    exit 0
fi

check_fzf

echo -e "${YELLOW}Installing Bun via curl...${RESET}"
if bash -c "$(curl -fsSL https://bun.sh/install)"; then
    echo -e "${GREEN}✅ Bun installed successfully!${RESET}"
    echo -e "${RED}If Bun doesn't appear on your system automatically, source your ~/.profile, .zshrc, or .bashrc.${RESET}"
    exit 0
else
    echo -e "${RED}❌ Curl installation failed! Trying npm as fallback...${RESET}"
fi

if ! command -v npm &>/dev/null; then
    echo -e "${RED}❌ npm is not installed! Cannot use fallback method.${RESET}"
    exit 1
fi

options=("Yes" "No")
continue_install=$(printf "%s\n" "${options[@]}" | fzf --prompt="⚠ npm is required to install Bun. Do you want to continue? " --height=10 --layout=reverse --border)
if [[ "$continue_install" != "Yes" ]]; then
    exit 0
fi

echo -e "${YELLOW}Installing Bun via npm...${RESET}"
if npm install -g bun; then
    echo -e "${GREEN}✅ Bun installed successfully!${RESET}"
    echo -e "${RED}If Bun doesn't appear on your system automatically, source your ~/.profile, .zshrc, or .bashrc.${RESET}"
else
    echo -e "${RED}❌ Bun installation failed.${RESET}"
    exit 1
fi
