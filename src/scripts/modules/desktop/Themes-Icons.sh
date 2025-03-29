#!/usr/bin/env bash

clear

GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RESET='\033[0m'

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

echo -e "${BLUE}"
if command -v figlet &>/dev/null; then
    figlet -f slant "Themes & Icons"
else
    echo "========== Theme & Icons Setup =========="
fi
echo -e "${RESET}"

echo -e "${CYAN}Theme and Icon Setup${RESET}"
echo -e "${YELLOW}----------------------${RESET}"

option=$(printf "Themes\nIcons\nBoth\nExit" | fzf --prompt="Choose an option: " --height=10 --layout=reverse --border)

check_and_create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo -e "${BLUE}:: Created directory: $1${RESET}"
    fi
}

check_existing_dir() {
    if [ -d "$1" ]; then
        echo -e "${YELLOW}:: $1 already exists. Do you want to overwrite?${RESET}"
        if ! fzf_confirm "Continue?"; then
            echo -e "${YELLOW}Operation canceled.${RESET}"
            return 1
        fi
    fi
    return 0
}

clone_repo() {
    local repo_url=$1
    local target_dir=$2

    if [ -d "$target_dir" ]; then
        echo -e "${YELLOW}:: $target_dir already exists. Skipping clone.${RESET}"
    else
        git clone "$repo_url" "$target_dir" || {
            echo -e "${RED}:: Failed to clone $repo_url. Exiting...${RESET}"
            exit 1
        }
    fi
}

cleanup_files() {
    local target_dir=$1
    rm -f "$target_dir/LICENSE" "$target_dir/README.md"
}

setup_themes() {
    echo -e "${CYAN}:: Setting up Themes...${RESET}"
    local tmp_dir="/tmp/themes"
    clone_repo "https://github.com/harilvfs/themes" "$tmp_dir"

    check_existing_dir "$HOME/.themes" || return
    check_and_create_dir "$HOME/.themes"
    
    mv "$tmp_dir"/* "$HOME/.themes/" 2>/dev/null
    cleanup_files "$HOME/.themes"

    rm -rf "$tmp_dir"

    echo -e "${GREEN}:: Themes have been set up successfully.${RESET}"
}

setup_icons() {
    echo -e "${CYAN}:: Setting up Icons...${RESET}"
    local tmp_dir="/tmp/icons"
    clone_repo "https://github.com/harilvfs/icons" "$tmp_dir"

    check_existing_dir "$HOME/.icons" || return
    check_and_create_dir "$HOME/.icons"
    
    mv "$tmp_dir"/* "$HOME/.icons/" 2>/dev/null
    cleanup_files "$HOME/.icons"

    rm -rf "$tmp_dir"

    echo -e "${GREEN}:: Icons have been set up successfully.${RESET}"
}

confirm_and_proceed() {
    echo -e "${YELLOW}:: This will install themes and icons, but you must select them manually using lxappearance (X11) or nwg-look (Wayland).${RESET}"

    if ! fzf_confirm "Do you want to continue?"; then
        echo -e "${YELLOW}Operation canceled.${RESET}"
        exit 0
    fi
}

case "$option" in
    "Themes")
        confirm_and_proceed
        setup_themes
        echo -e "${BLUE}:: Use lxappearance for X11 or nwg-look for Wayland to select the theme.${RESET}"
        ;;
    "Icons")
        confirm_and_proceed
        setup_icons
        echo -e "${BLUE}:: Use lxappearance for X11 or nwg-look for Wayland to select the icons.${RESET}"
        ;;
    "Both")
        confirm_and_proceed
        setup_themes
        setup_icons
        echo -e "${BLUE}:: Use lxappearance for X11 or nwg-look for Wayland to select the theme and icons.${RESET}"
        ;;
    "Exit")
        echo -e "${YELLOW}:: Exiting...${RESET}"
        exit 0
        ;;
    *)
        echo -e "${YELLOW}Invalid option. Exiting...${RESET}"
        exit 1
        ;;
esac

