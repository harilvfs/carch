#!/bin/bash

clear

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

echo -e "${BLUE}"
figlet -f slant "Npm"
echo -e "${RESET}"

if ! command -v gum &>/dev/null; then
    echo -e "${RED}Error: 'gum' is required for this script.${RESET}"
    echo -e "${YELLOW}Please install 'gum' before running this script.${RESET}"
    exit 1
fi

if command -v npm &>/dev/null; then
    echo -e "${GREEN}✔ npm is already installed.${RESET}"

    if pacman -Q npm &>/dev/null; then
        package_manager="pacman"
    elif dnf list installed nodejs &>/dev/null; then
        package_manager="dnf"
    else
        package_manager=""
    fi

    if [[ -n "$package_manager" ]]; then
        gum style --foreground 202 "⚠ npm is installed via $package_manager, which may cause conflicts."
        if ! gum confirm "Do you want to use nvm instead? (Recommended)"; then
            echo -e "${GREEN}✔ Keeping existing npm installation.${RESET}"
            exit 0
        fi
    else
        echo -e "${GREEN}✔ npm is installed via nvm or manually.${RESET}"
        exit 0
    fi
else
    gum style --foreground 208 "⚠ npm is not installed on your system."
    if ! gum confirm "Do you want to install npm using nvm? (Recommended)"; then
        echo -e "${RED}✖ npm installation aborted.${RESET}"
        exit 1
    fi
fi

if ! command -v nvm &>/dev/null; then
    gum style --foreground 214 "🔧 Installing nvm..."
    
    if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash; then
        echo -e "${GREEN}✔ nvm installed successfully.${RESET}"
    elif wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash; then
        echo -e "${GREEN}✔ nvm installed successfully (via wget).${RESET}"
    else
        echo -e "${RED}✖ Failed to install nvm.${RESET}"
        exit 1
    fi

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

gum style --foreground 33 "📦 Installing npm via nvm..."
nvm install npm

echo -e "${GREEN}✔ npm installation completed via nvm.${RESET}"

