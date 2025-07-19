#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../fzf.sh" > /dev/null 2>&1

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

check_fzf

echo -e "${CYAN}:: Wallpapers will be set up in the Pictures directory (${PICTURES_DIR}).${NC}"

if [ ! -d "$PICTURES_DIR" ]; then
    echo -e "${CYAN}:: Creating the Pictures directory...${NC}"
    mkdir -p "$PICTURES_DIR"
fi

setup_wallpapers() {
    if [ -d "$WALLPAPERS_DIR" ]; then
        echo -e "${YELLOW}:: The wallpapers directory already exists.${NC}"
        if fzf_confirm "Overwrite existing wallpapers directory?"; then
            echo -e "${CYAN}:: Removing existing wallpapers directory...${NC}"
            rm -rf "$WALLPAPERS_DIR"
        else
            echo -e "${YELLOW}Operation cancelled. Keeping existing wallpapers.${NC}"
            exit 0
        fi
    fi

    echo -e "${CYAN}:: Cloning the wallpapers repository...${NC}"
    git clone https://github.com/harilvfs/wallpapers "$WALLPAPERS_DIR"

    if [ -d "$WALLPAPERS_DIR" ]; then
        echo -e "${CYAN}:: Cleaning up unnecessary files from the repository...${NC}"
        cd "$WALLPAPERS_DIR" || exit
        rm -rf .git README.md docs/
        echo -e "${GREEN}:: Wallpapers have been successfully set up in your wallpapers directory.${NC}"
    else
        echo -e "${RED}:: Failed to clone the repository.${NC}"
    fi
}

setup_wallpapers
