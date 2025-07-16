#!/usr/bin/env bash

check_fzf() {
    if ! command -v fzf &> /dev/null; then
        echo -e "${RED}${BOLD}Error:${NC} fzf is not installed"
        echo -e "${YELLOW}Please install fzf before running this script:${NC}"
        echo -e "${CYAN}  • Fedora:${NC} sudo dnf install fzf"
        echo -e "${CYAN}  • Arch Linux:${NC} sudo pacman -S fzf"
        echo -e "${CYAN}  • openSUSE:${NC} sudo zypper install fzf"
        exit 1
    fi
}
