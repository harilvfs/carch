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

package_manager=""
if command -v npm &>/dev/null; then
    echo -e "${GREEN}✔ npm is already installed.${RESET}"

    if pacman -Q npm &>/dev/null; then
        package_manager="pacman"
        remove_cmd="sudo pacman -Rsn npm"
    elif dnf list installed nodejs &>/dev/null; then
        package_manager="dnf"
        remove_cmd="sudo dnf remove nodejs"
    fi

    if [[ -n "$package_manager" ]]; then
        gum style --foreground 202 "⚠ npm is installed via $package_manager, which may cause conflicts with nvm."
        if gum confirm "Do you want to remove the package manager version and use nvm instead? (Recommended)"; then
            gum style --foreground 214 "🗑 Removing npm and Node.js via $package_manager..."
            if eval "$remove_cmd"; then
                echo -e "${GREEN}✔ Successfully removed npm and Node.js.${RESET}"
            else
                echo -e "${RED}✖ Failed to remove npm and Node.js.${RESET}"
                exit 1
            fi
        else
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
fi

if [[ "$SHELL" == */bash ]]; then
    source ~/.bashrc &>/dev/null
elif [[ "$SHELL" == */zsh ]]; then
    source ~/.zshrc &>/dev/null
elif [[ "$SHELL" == */fish ]]; then
    source ~/.config/fish/config.fish &>/dev/null
else
    echo -e "${YELLOW}⚠ Unknown shell detected. Please restart your terminal or source your shell config manually.${RESET}"
fi

gum style --foreground 33 "📦 Installing npm via nvm..."
nvm install --lts

echo -e "${GREEN}✔ npm installation completed via nvm.${RESET}"

