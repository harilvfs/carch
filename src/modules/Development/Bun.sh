#!/usr/bin/env bash

# Installs Bun, a JavaScript runtime, bundler, transpiler, and package manager optimized for performance.

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

check_fzf() {
    if ! command -v fzf &>/dev/null; then
        echo -e "${YELLOW}Installing fzf...${RESET}"
        if command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm fzf
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y fzf
        fi
    fi
}

install_bun() {
    echo -e "${GREEN}Installing Bun...${RESET}"
    curl -fsSL https://bun.sh/install | bash

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Bun has been installed successfully!${RESET}"
    else
        echo -e "${RED}Failed to install Bun.${RESET}"
        echo -e "${YELLOW}Trying alternative installation method...${RESET}"
        npm install -g bun
    fi
}

check_fzf

if ! command -v curl &>/dev/null; then
    echo -e "${YELLOW}Installing curl...${RESET}"
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm curl
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y curl
    fi
fi

if ! command -v npm &>/dev/null; then
    echo -e "${YELLOW}Warning: npm is required for Bun installation${RESET}"
    options=("Yes" "No")
    continue_install=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                       --height=40% \
                                                       --prompt="npm is required to install Bun. Do you want to continue? " \
                                                       --header="Confirm" \
                                                       --pointer="➤" \
                                                       --color='fg:white,fg+:green,bg+:black,pointer:green')

    if [ "$continue_install" != "Yes" ]; then
        echo -e "${RED}Aborting Bun installation. Please install npm first.${RESET}"
        exit 1
    fi
fi

install_bun
