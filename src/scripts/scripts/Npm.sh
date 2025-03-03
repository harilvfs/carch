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

if [[ ! -d "$HOME/.nvm" ]]; then
    gum style --foreground 214 "🔧 Installing nvm..."
    
    if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash; then
        echo -e "${GREEN}✔ nvm installed successfully.${RESET}"
    elif wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash; then
        echo -e "${GREEN}✔ nvm installed successfully (via wget).${RESET}"
    else
        echo -e "${RED}✖ Failed to install nvm.${RESET}"
        exit 1
    fi
else
    echo -e "${GREEN}✔ nvm is already installed.${RESET}"
fi

export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
    echo -e "${GREEN}✔ nvm loaded successfully.${RESET}"
else
    echo -e "${RED}✖ Failed to load nvm. The installation may be incomplete.${RESET}"
    exit 1
fi

if command -v nvm &>/dev/null; then
    gum style --foreground 33 "📦 Installing Node.js LTS via nvm..."
    nvm install --lts
    nvm use --lts
    echo -e "${GREEN}✔ Node.js LTS installation completed via nvm.${RESET}"
    echo -e "${GREEN}✔ npm is now available.${RESET}"
    
    NODE_VERSION=$(node -v)
    NPM_VERSION=$(npm -v)
    echo -e "${BLUE}Node.js version: ${NODE_VERSION}${RESET}"
    echo -e "${BLUE}npm version: ${NPM_VERSION}${RESET}"
    
    echo -e "${YELLOW}⚠ Note: For nvm to work in new terminal sessions, make sure your shell's config file (e.g., ~/.bashrc) has been updated correctly.${RESET}"
    echo -e "${YELLOW}⚠ You may need to restart your terminal or run 'source ~/.bashrc' (or equivalent) for permanent effects.${RESET}"
else
    echo -e "${RED}✖ nvm command is still not available after installation.${RESET}"
    echo -e "${YELLOW}Please try the following steps manually:${RESET}"
    echo -e "1. Close this terminal and open a new one"
    echo -e "2. Run 'nvm install --lts'"
    exit 1
fi
