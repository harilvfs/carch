#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

GRUB_THEME_DIR="$HOME/.local/share/Top-5-Bootloader-Themes"

confirm() {
    while true; do
        read -p "$(echo -e "${CYAN}:: $1 [y/N]: ${ENDCOLOR}")" answer
        case ${answer,,} in
            y | yes) return 0 ;;
            n | no | "") return 1 ;;
            *) echo -e "${YELLOW}:: Please answer with y/yes or n/no.${ENDCOLOR}" ;;
        esac
    done
}

print_message() {
    echo -e "${TEAL}:: This Grub Theme Script is from Chris Titus Tech.${ENDCOLOR}"
    echo -e "${TEAL}:: Check out the source code here: ${GREEN}httpshttps://github.com/harilvfs/Top-5-Bootloader-Themes${ENDCOLOR}"
}

check_existing_dir() {
    if [[ -d "$GRUB_THEME_DIR" ]]; then
        echo -e "${RED}:: Directory $GRUB_THEME_DIR already exists.${ENDCOLOR}"
        if confirm "Do you want to overwrite it?"; then
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

print_message
check_existing_dir
clone_repo
install_theme
