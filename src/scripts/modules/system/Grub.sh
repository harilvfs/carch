#!/usr/bin/env bash

# Customizes the GRUB bootloader with improved aesthetics and settings for a more polished boot experience.

clear

GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
if command -v figlet &>/dev/null; then
    figlet -f slant "Grub"
else
    echo "========== Grub Setup =========="
fi
echo -e "${RESET}"

GRUB_THEME_DIR="$HOME/.local/share/Top-5-Bootloader-Themes"

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
    echo -e "${BLUE}:: This bootloader setup script is from Chris Titus Tech.${ENDCOLOR}"
    echo -e "${BLUE}:: Check out his GitHub for more: ${GREEN}https://github.com/christitustech${ENDCOLOR}"
}

check_existing_dir() {
    if [[ -d "$GRUB_THEME_DIR" ]]; then
        echo -e "${RED}:: Directory $GRUB_THEME_DIR already exists.${ENDCOLOR}"
        if fzf_confirm "Do you want to overwrite it?"; then
            echo -e "${BLUE}:: Removing existing directory...${ENDCOLOR}"
            rm -rf "$GRUB_THEME_DIR"
        else
            echo -e "${RED}:: Aborting installation.${ENDCOLOR}"
            exit 1
        fi
    fi
}

clone_repo() {
    echo -e "${BLUE}:: Cloning GRUB themes repository...${ENDCOLOR}"
    git clone https://github.com/harilvfs/Top-5-Bootloader-Themes "$GRUB_THEME_DIR"
}

install_theme() {
    echo -e "${BLUE}:: Running the installation script...${ENDCOLOR}"
    cd "$GRUB_THEME_DIR" || exit
    sudo ./install.sh
}

print_message
echo -e "${RED}:: WARNING: Ensure you have backed up your GRUB configuration before proceeding.${ENDCOLOR}"
if ! fzf_confirm "Continue with Grub setup?"; then
    echo -e "${RED}:: Setup aborted by the user.${ENDCOLOR}"
    exit 1
fi

check_existing_dir
clone_repo
install_theme
echo -e "${GREEN}:: GRUB setup completed.${ENDCOLOR}"

if fzf_confirm "Do you want to reboot now?"; then
    echo -e "${BLUE}:: Rebooting system...${ENDCOLOR}"
    sudo reboot
fi
