#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

if ! command -v fzf &> /dev/null; then
    echo -e "${RED}${BOLD}Error: fzf is not installed${NC}"
    echo -e "${YELLOW}Please install fzf before running this script:${NC}"
    echo -e "${CYAN}  • Fedora:     ${NC}sudo dnf install fzf"
    echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S fzf"
    echo -e "${CYAN}  • openSUSE:   ${NC}sudo zypper install fzf"
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
    [[ "$selected" == "Yes" ]]
}

print_message() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

if command -v npm &> /dev/null; then
    NODE_VERSION=$(node -v)
    NPM_VERSION=$(npm -v)
    print_message "$GREEN" "npm is already installed."
    print_message "$TEAL" "Node.js version: $NODE_VERSION"
    print_message "$TEAL" "npm version: $NPM_VERSION"
    exit 0
fi

print_message "$YELLOW" "npm is not installed on your system."

if ! fzf_confirm "Do you want to install Node.js (includes npm) using your package manager?"; then
    print_message "$RED" "Installation aborted."
    exit 1
fi

if command -v pacman &> /dev/null; then
    sudo pacman -S --noconfirm nodejs npm
elif command -v dnf &> /dev/null; then
    sudo dnf install -y nodejs npm
elif command -v zypper &> /dev/null; then
    sudo zypper install -y nodejs
else
    print_message "$RED" "No supported package manager found."
    exit 1
fi

if command -v npm &> /dev/null; then
    NODE_VERSION=$(node -v)
    NPM_VERSION=$(npm -v)
    print_message "$GREEN" "Node.js and npm installed successfully."
    print_message "$TEAL" "Node.js version: $NODE_VERSION"
    print_message "$TEAL" "npm version: $NPM_VERSION"
else
    print_message "$RED" "npm installation failed."
    exit 1
fi
