#!/usr/bin/env bash

set -euo pipefail

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

check_curl() {
    if ! command -v curl &> /dev/null; then
        echo -e "${YELLOW}Installing curl...${NC}"
        if command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm curl
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y curl
        elif command -v zypper &> /dev/null; then
            sudo zypper install -y curl
        else
            echo -e "${RED}Unsupported package manager. Please install curl manually.${NC}"
            exit 1
        fi
    fi
}

install_bun() {
    echo -e "${GREEN}Installing Bun...${NC}"
    curl -fsSL https://bun.sh/install | bash

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Bun has been installed successfully!${NC}"
    else
        echo -e "${RED}Failed to install Bun.${NC}"
        exit 1
    fi
}

check_curl
install_bun
