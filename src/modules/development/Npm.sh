#!/usr/bin/env bash

# Ensures npm is installed correctly, offering an alternative setup if needed.

clear

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

if ! command -v fzf &>/dev/null; then
    echo -e "${RED}Error: 'fzf' is required for this script.${RESET}"
    echo -e "${YELLOW}Please install 'fzf' before running this script.${RESET}"
    exit 1
fi

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

fzf_confirm() {
    local prompt="$1"
    local options=("Yes" "No")
    local selected=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                     --height=40% \
                                                     --prompt="$prompt " \
                                                     --header="Confirm" \
                                                     --pointer="➤" \
                                                     --color='fg:white,fg+:green,bg+:black,pointer:green')

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

if command -v npm &>/dev/null; then
    NODE_VERSION=$(node -v)
    NPM_VERSION=$(npm -v)
    print_message "$GREEN" "✔ npm is already installed."
    print_message "$BLUE" "Node.js version: ${NODE_VERSION}"
    print_message "$BLUE" "npm version: ${NPM_VERSION}"
    exit 0
fi

print_message "$YELLOW" "⚠ npm is not installed on your system."
if ! fzf_confirm "Do you want to install npm using nvm? (Recommended)"; then
    print_message "$RED" "✖ npm installation aborted."
    exit 1
fi

if [[ ! -d "$HOME/.nvm" ]]; then
    print_message "$YELLOW" "🔧 Installing nvm..."

    if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash; then
        print_message "$GREEN" "✔ nvm installed successfully."
    elif wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash; then
        print_message "$GREEN" "✔ nvm installed successfully (via wget)."
    else
        print_message "$RED" "✖ Failed to install nvm."

        print_message "$YELLOW" "Falling back to package manager installation..."
        if command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm npm || {
                print_message "$RED" "✖ Failed to install npm via pacman."
                exit 1
            }
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y nodejs npm || {
                print_message "$RED" "✖ Failed to install npm via dnf."
                exit 1
            }
        else
            print_message "$RED" "✖ No supported package manager found."
            exit 1
        fi
        print_message "$GREEN" "✔ npm installed via package manager."
        NODE_VERSION=$(node -v)
        NPM_VERSION=$(npm -v)
        print_message "$BLUE" "Node.js version: ${NODE_VERSION}"
        print_message "$BLUE" "npm version: ${NPM_VERSION}"
        exit 0
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
