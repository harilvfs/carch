#!/usr/bin/env bash

clear

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

echo -e "${BLUE}"
if command -v figlet &>/dev/null; then
    figlet -f slant "Npm"
else
    echo "========== Npm Setup =========="
fi
echo -e "${RESET}"

if ! command -v fzf &>/dev/null; then
    echo -e "${RED}Error: 'fzf' is required for this script.${RESET}"
    echo -e "${YELLOW}Please install 'fzf' before running this script.${RESET}"
    exit 1
fi

fzf_confirm() {
    local prompt="$1"
    local options=("Yes" "No")
    local selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="$prompt " --height=10 --layout=reverse --border)
    if [[ "$selected" == "Yes" ]]; then
        return 0
    else
        return 1
    fi
}

print_message() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${RESET}"
}

package_manager=""
if command -v npm &>/dev/null; then
    print_message "$GREEN" "✔ npm is already installed."
    if pacman -Q npm &>/dev/null; then
        package_manager="pacman"
        remove_cmd="sudo pacman -Rsn npm"
    elif dnf list installed nodejs &>/dev/null; then
        package_manager="dnf"
        remove_cmd="sudo dnf remove nodejs"
    fi
    
    if [[ -n "$package_manager" ]]; then
        print_message "$YELLOW" "⚠ npm is installed via $package_manager, which may cause conflicts with nvm."
        if fzf_confirm "Do you want to remove the package manager version and use nvm instead? (Recommended)"; then
            print_message "$YELLOW" "🗑 Removing npm and Node.js via $package_manager..."
            if eval "$remove_cmd"; then
                print_message "$GREEN" "✔ Successfully removed npm and Node.js."
            else
                print_message "$RED" "✖ Failed to remove npm and Node.js."
                exit 1
            fi
        else
            print_message "$GREEN" "✔ Keeping existing npm installation."
            exit 0
        fi
    else
        print_message "$GREEN" "✔ npm is installed via nvm or manually."
        exit 0
    fi
else
    print_message "$YELLOW" "⚠ npm is not installed on your system."
    if ! fzf_confirm "Do you want to install npm using nvm? (Recommended)"; then
        print_message "$RED" "✖ npm installation aborted."
        exit 1
    fi
fi

if [[ ! -d "$HOME/.nvm" ]]; then
    print_message "$YELLOW" "🔧 Installing nvm..."
    
    if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash; then
        print_message "$GREEN" "✔ nvm installed successfully."
    elif wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash; then
        print_message "$GREEN" "✔ nvm installed successfully (via wget)."
    else
        print_message "$RED" "✖ Failed to install nvm."
        exit 1
    fi
else
    print_message "$GREEN" "✔ nvm is already installed."
fi

export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
    print_message "$GREEN" "✔ nvm loaded successfully."
else
    print_message "$RED" "✖ Failed to load nvm. The installation may be incomplete."
    exit 1
fi

if command -v nvm &>/dev/null; then
    print_message "$BLUE" "📦 Installing Node.js LTS via nvm..."
    nvm install --lts
    nvm use --lts
    print_message "$GREEN" "✔ Node.js LTS installation completed via nvm."
    print_message "$GREEN" "✔ npm is now available."
    
    NODE_VERSION=$(node -v)
    NPM_VERSION=$(npm -v)
    print_message "$BLUE" "Node.js version: ${NODE_VERSION}"
    print_message "$BLUE" "npm version: ${NPM_VERSION}"
    
    print_message "$YELLOW" "⚠ Note: For nvm to work in new terminal sessions, make sure your shell's config file (e.g., ~/.bashrc) has been updated correctly."
    print_message "$YELLOW" "⚠ You may need to restart your terminal or run 'source ~/.bashrc' (or equivalent) for permanent effects."
else
    print_message "$RED" "✖ nvm command is still not available after installation."
    print_message "$YELLOW" "Please try the following steps manually:"
    echo -e "1. Close this terminal and open a new one"
    echo -e "2. Run 'nvm install --lts'"
    exit 1
fi
