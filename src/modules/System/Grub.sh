#!/usr/bin/env bash

set -euo pipefail

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../fzf.sh" > /dev/null 2>&1

GRUB_THEME_DIR="$HOME/.local/share/Top-5-Bootloader-Themes"

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
    echo -e "${TEAL}:: This Grub Theme Script is from Chris Titus Tech.${ENDCOLOR}"
    echo -e "${TEAL}:: Check out the source code here: ${GREEN}https://github.com/harilvfs/Top-5-Bootloader-Themes${ENDCOLOR}"
}

check_existing_dir() {
    if [[ -d "$GRUB_THEME_DIR" ]]; then
        echo -e "${RED}:: Directory $GRUB_THEME_DIR already exists.${ENDCOLOR}"
        if fzf_confirm "Do you want to overwrite it?"; then
            echo -e "${TEAL}:: Removing existing directory...${ENDCOLOR}"
            rm -rf "$GRUB_THEME_DIR"
        else
            echo -e "${RED}:: Aborting installation.${ENDCOLOR}"
            exit 1
        fi
    fi
}

clone_repo() {
    echo -e "${TEAL}:: Cloning GRUB themes repository...${ENDCOLOR}"
    git clone https://github.com/harilvfs/Top-5-Bootloader-Themes "$GRUB_THEME_DIR"
}

install_theme() {
    echo -e "${TEAL}:: Running the installation script...${ENDCOLOR}"
    cd "$GRUB_THEME_DIR" || exit
    sudo ./install.sh
}

check_fzf
print_message
check_existing_dir
clone_repo
install_theme
