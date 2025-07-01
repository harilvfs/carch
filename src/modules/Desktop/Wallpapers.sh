#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

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

PICTURES_DIR="$HOME/Pictures"
WALLPAPERS_DIR="$PICTURES_DIR/wallpapers"

if ! command -v fzf &> /dev/null; then
    echo -e "${RED}${BOLD}Error: fzf is not installed${NC}"
    echo -e "${YELLOW}Please install fzf before running this script:${NC}"
    echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install fzf"
    echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S fzf"
    exit 1
fi

echo -e "${CYAN}:: Wallpapers will be set up in the Pictures directory (${PICTURES_DIR}).${NC}"

if [ ! -d "$PICTURES_DIR" ]; then
    echo -e "${CYAN}:: Creating the Pictures directory...${NC}"
    mkdir -p "$PICTURES_DIR"
fi

setup_wallpapers() {
    echo -e "${CYAN}:: Cloning the wallpapers repository...${NC}"
    git clone https://github.com/harilvfs/wallpapers "$WALLPAPERS_DIR"

    if [ -d "$WALLPAPERS_DIR" ]; then
        echo -e "${CYAN}:: Cleaning up unnecessary files from the repository...${NC}"
        cd "$WALLPAPERS_DIR" || exit
        rm -rf .git README.md docs/
        echo -e "${GREEN}Wallpapers have been successfully set up in your wallpapers directory.${NC}"
    else
        echo -e "${CYAN}Failed to clone the repository.${NC}"
    fi
}

setup_wallpapers
