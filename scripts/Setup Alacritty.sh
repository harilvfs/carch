#!/bin/bash

clear

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BLUE="\e[34m"
ENDCOLOR="\e[0m"
RESET='\033[0m'

echo -e "${BLUE}"
cat <<"EOF"
--------------------------------------------------------------------------------------------------------------------

 
 █████╗ ██╗      █████╗  ██████╗██████╗ ██╗████████╗████████╗██╗   ██╗    ███████╗███████╗████████╗██╗   ██╗██████╗ 
██╔══██╗██║     ██╔══██╗██╔════╝██╔══██╗██║╚══██╔══╝╚══██╔══╝╚██╗ ██╔╝    ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
███████║██║     ███████║██║     ██████╔╝██║   ██║      ██║    ╚████╔╝     ███████╗█████╗     ██║   ██║   ██║██████╔╝
██╔══██║██║     ██╔══██║██║     ██╔══██╗██║   ██║      ██║     ╚██╔╝      ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ 
██║  ██║███████╗██║  ██║╚██████╗██║  ██║██║   ██║      ██║      ██║       ███████║███████╗   ██║   ╚██████╔╝██║     
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝   ╚═╝      ╚═╝      ╚═╝       ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     
                                                                                                                    
                                                                             
---------------------------------------------------------------------------------------------------------------------
EOF
echo -e "${ENDCOLOR}"

confirm_continue() {
    while true; do
        printf "${YELLOW}Warning: If you already have an Alacritty configuration, make sure to back it up before proceeding.${RESET}\n"
        read -p "Do you want to continue with the setup? (y/n): " confirm
        case $confirm in
            [yY]) return 0 ;;  
            [nN]) 
                printf "${RED}Setup aborted by the user.${RESET}\n"
                exit 1 
                ;;
            *) printf "${RED}Invalid choice. Please enter y or n.${RESET}\n" ;;
        esac
    done
}

checkAlacritty() {
    if command -v alacritty &> /dev/null; then
        printf "${GREEN}Alacritty is already installed.${RESET}\n"
    else
        printf "${YELLOW}Alacritty is not installed. Installing now...${RESET}\n"
        if [ -x "$(command -v pacman)" ]; then
            sudo pacman -S alacritty --noconfirm
        elif [ -x "$(command -v apt)" ]; then
            sudo apt install alacritty -y
        else
            printf "${RED}Unsupported package manager! Please install Alacritty manually.${RESET}\n"
            exit 1
        fi
        printf "${GREEN}Alacritty has been installed.${RESET}\n"
    fi
}

setupAlacrittyConfig() {
    printf "${CYAN}Copying Alacritty config files...${RESET}\n"
    if [ -d "${HOME}/.config/alacritty" ] && [ ! -d "${HOME}/.config/alacritty-bak" ]; then
        cp -r "${HOME}/.config/alacritty" "${HOME}/.config/alacritty-bak"
        printf "${YELLOW}Existing Alacritty configuration backed up to alacritty-bak.${RESET}\n"
    fi
    mkdir -p "${HOME}/.config/alacritty/"
    curl -sSLo "${HOME}/.config/alacritty/alacritty.toml" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/alacritty/alacritty.toml"
    curl -sSLo "${HOME}/.config/alacritty/keybinds.toml" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/alacritty/keybinds.toml"
    curl -sSLo "${HOME}/.config/alacritty/nordic.toml" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/alacritty/nordic.toml"
    printf "${GREEN}Alacritty configuration files copied.${RESET}\n"
}

confirm_continue

checkAlacritty
setupAlacrittyConfig

printf "${GREEN}Alacritty setup complete.${RESET}\n"

