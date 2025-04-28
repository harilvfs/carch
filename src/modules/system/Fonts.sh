#!/usr/bin/env bash

# Downloads and installs a variety of Nerd Fonts for improved readability and aesthetics in terminal applications.

clear

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BLUE="\e[34m"
NC='\033[0m'

FONTS_DIR="$HOME/.fonts"

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

get_latest_release() {
    curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" | 
    grep '"tag_name":' | 
    sed -E 's/.*"v([^"]+)".*/\1/'
}

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

fzf_select_fonts() {
    local options=("$@")
    printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                     --height=50% \
                                     --prompt="Select fonts (TAB to mark, ENTER to confirm): " \
                                     --header="Font Selection" \
                                     --pointer="➤" \
                                     --multi \
                                     --color='fg:white,fg+:blue,bg+:black,pointer:blue'
}

check_dependencies() {
    if ! command -v unzip &>/dev/null; then
        echo -e "${RED}Error: 'unzip' is not installed. Please install it first.${NC}"
        exit 1
    fi

    if ! command -v fzf &>/dev/null; then
        echo -e "${RED}Error: 'fzf' is not installed. Please install it first.${NC}"
        exit 1
    fi

    if ! command -v curl &>/dev/null; then
        echo -e "${RED}Error: 'curl' is not installed. Please install it first.${NC}"
        exit 1
    fi
}

install_font_arch() {
    local font_pkg="$@"
    echo -e "${CYAN}:: Installing $font_pkg via pacman...${NC}"
    sudo pacman -S --noconfirm $font_pkg
    echo -e "${GREEN}$font_pkg installed successfully!${NC}"
}

install_font_fedora() {
    local font_name="$1"
    local latest_version=$(get_latest_release)
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${latest_version}/${font_name}.zip"

    echo -e "${CYAN}:: Downloading $font_name version ${latest_version} to /tmp...${NC}"
    curl -L "$font_url" -o "/tmp/${font_name}.zip"

    echo -e "${CYAN}:: Extracting $font_name...${NC}"
    mkdir -p "$FONTS_DIR"
    unzip -q "/tmp/${font_name}.zip" -d "$FONTS_DIR"

    echo -e "${CYAN}:: Refreshing font cache...${NC}"
    fc-cache -vf

    echo -e "${GREEN}$font_name installed successfully in $FONTS_DIR!${NC}"
}

install_fedora_system_fonts() {
    local font_pkg="$@"
    echo -e "${CYAN}:: Installing $font_pkg via dnf...${NC}"
    sudo dnf install -y $font_pkg
    echo -e "${GREEN}$font_pkg installed successfully!${NC}"
}

choose_fonts() {
    local return_to_menu=true

    while $return_to_menu; do
        clear

        FONT_SELECTION=$(fzf_select_fonts "FiraCode" "Meslo" "JetBrainsMono" "Hack" "CascadiaMono" "Terminus" "Noto" "DejaVu" "Exit")

        if [[ "$FONT_SELECTION" == *"Exit"* ]]; then
            echo -e "${GREEN}Exiting font installation.${NC}"
            return
        fi

        for font in $FONT_SELECTION; do
            case "$font" in
                "FiraCode")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "ttf-firacode-nerd"
                    else
                        install_font_fedora "FiraCode"
                    fi
                    ;;
                "Meslo")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "ttf-meslo-nerd"
                    else
                        install_font_fedora "Meslo"
                    fi
                    ;;
                "JetBrainsMono")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch ttf-jetbrains-mono-nerd ttf-jetbrains-mono
                    else
                        install_font_fedora "JetBrainsMono"
                    fi
                    ;;
                "Hack")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "ttf-hack-nerd"
                    else
                        install_font_fedora "Hack"
                    fi
                    ;;
                "CascadiaMono")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch ttf-cascadia-mono-nerd ttf-cascadia-code-nerd
                    else
                        install_font_fedora "CascadiaMono"
                    fi
                    ;;
                "Terminus")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "terminus-font"
                    else
                        echo -e "${RED}Terminus font is not available as a Nerd Font.${NC}"
                    fi
                    ;;
                "Noto")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch noto-fonts noto-fonts-emoji noto-fonts-cjk noto-fonts-extra
                    else
                        install_fedora_system_fonts google-noto-fonts google-noto-emoji-fonts
                    fi
                    ;;
                "DejaVu")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch ttf-dejavu
                    else
                        install_fedora_system_fonts dejavu-sans-fonts
                    fi
                    ;;
            esac
        done

        echo -e "${GREEN}All selected fonts installed successfully!${NC}"
        read -rp "Press Enter to return to menu..."
    done
}

detect_os() {
    if command -v pacman &>/dev/null; then
        OS_TYPE="arch"
    elif command -v dnf &>/dev/null; then
        OS_TYPE="fedora"
    else
        echo -e "${RED}Unsupported OS. Please install fonts manually.${NC}"
        exit 1
    fi
}

main() {
    check_dependencies
    detect_os
    choose_fonts
    
}

main
