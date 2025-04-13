#!/usr/bin/env bash

VERSION="4.3.2"
CACHE_DIR="$HOME/.cache/carch-install"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'
RESET="\033[0m"

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

if ! command -v pacman &>/dev/null; then
    echo -e "${RED}Error: This script requires an Arch-based distribution.${NC}"
    exit 1
fi

mkdir -p "$CACHE_DIR"

spinner() {
    local pid=$1
    local spin="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r%s" "${spin:i++%${#spin}:1}"
        sleep 0.1
    done
    printf "\r✔\n"
}

package_installed() {
    pacman -Qi "$1" &>/dev/null
}

install_dependencies() {
    local dependencies=("figlet" "ttf-jetbrains-mono-nerd" "ttf-jetbrains-mono" "fzf" "git")
    
    for dep in "${dependencies[@]}"; do
        if ! package_installed "$dep"; then
            sudo pacman -Sy --noconfirm "$dep" > /dev/null 2>&1
        fi
    done
}

fzf_confirm() {
    local prompt="$1"
    local options=("Yes" "No")
    local selected=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                     --height=30% \
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

cleanup() {
    rm -rf "$CACHE_DIR" > /dev/null 2>&1
}

main() {
    echo "Installing Carch v${VERSION}..."
    
    echo "Checking dependencies..."
    install_dependencies &
    PID=$!
    spinner $PID
    
    echo -e "${YELLOW}Select installation type:${NC}"
    local options=("Stable Release [Recommended]" "Carch-git [GitHub Latest Commit]" "Cancel")
    CHOICE=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                   --height=40% \
                                                   --prompt="Select package version: " \
                                                   --header="Installation Options" \
                                                   --pointer="➤" \
                                                   --color='fg:white,fg+:blue,bg+:black,pointer:blue')
    
    if [[ $CHOICE == "Cancel" ]]; then
        echo -e "${RED}Installation canceled.${NC}"
        exit 0
    fi
    
    fzf_confirm "Install $CHOICE?" || {
        echo -e "${RED}Installation canceled.${NC}"
        exit 0
    }
    
    echo -e "${YELLOW}Preparing installation environment...${RESET}"
    cd "$CACHE_DIR" || exit 1
    
    if [ -d "pkgs" ]; then
        echo -e "${YELLOW}Updating existing repository...${RESET}"
        git -C pkgs pull > /dev/null 2>&1 &
        PID=$!
        spinner $PID
    else
        echo -e "${YELLOW}Cloning repository...${RESET}"
        git clone https://github.com/carch-org/pkgs > /dev/null 2>&1 &
        PID=$!
        spinner $PID
    fi
    
    cd pkgs || {
        echo -e "${RED}Failed to access repository.${RESET}"
        exit 1
    }
    
    case "$CHOICE" in
        "Carch-git [GitHub Latest Commit]")
            echo -e "${YELLOW}Installing Git Version (Latest Commit)...${RESET}"
            cd carch-git || exit 1
            ;;
        "Stable Release [Recommended]")
            echo -e "${YELLOW}Installing Stable Release...${RESET}"
            cd carch || exit 1
            ;;
    esac
    
    echo -e "${CYAN}Building and installing package...${RESET}"
    makepkg -si --noconfirm
    
    if command -v carch &>/dev/null; then
        echo -e "${GREEN}INSTALLATION COMPLETE${RESET}"
        cleanup
    else
        echo -e "${RED}Failed to build or install package.${RESET}"
        exit 1
    fi
}

main
