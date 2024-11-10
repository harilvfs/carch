#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE="\e[34m"
ENDCOLOR="\e[0m"
RESET='\033[0m'

install_paru() {
    if ! command -v paru &> /dev/null; then
        echo -e "${RED}Paru not found. Installing...${RESET}"
        sudo pacman -S --needed base-devel

        temp_dir=$(mktemp -d)
        cd "$temp_dir" || { echo -e "${RED}Failed to create temp directory${RESET}"; exit 1; }

        git clone https://aur.archlinux.org/paru.git
        cd paru || { echo -e "${RED}Failed to enter paru directory${RESET}"; exit 1; }
        makepkg -si
        
        cd ..
        rm -rf "$temp_dir"
        echo -e "${GREEN}Paru installed successfully.${RESET}"
    else
        echo -e "${GREEN}Paru is already installed.${RESET}"
    fi
}

install_communication() {
    while true; do
        echo -e "${CYAN}Communication Menu:${RESET}"
        echo "1) Discord"
        echo "2) Signal"
        echo "3) Telegram"
        echo "4) Keybase"
        echo "5) Exit"
        read -p "Choose an option: " comm_choice

        case $comm_choice in
            1) paru -S discord ;;
            2) paru -S signal-desktop ;;
            3) paru -S telegram-desktop ;;
            4) paru -s keybase-bin ;;
            5) break ;;  
            *) echo -e "${RED}Invalid option${RESET}" ;;
        esac
    done
}

install_streaming() {
    while true; do
        echo -e "${CYAN}Live Streaming/Recording Menu:${RESET}"
        echo "1) OBS Studio"
        echo "2) Exit"
        read -p "Choose an option: " stream_choice

        case $stream_choice in
            1) sudo pacman -S obs-studio ;;
            2) break ;;  
            *) echo -e "${RED}Invalid option${RESET}" ;;
        esac
    done
}

install_editing() {
    while true; do
        echo -e "${CYAN}Editing Menu:${RESET}"
        echo "1) GIMP (Image)"
        echo "2) Kdenlive (Videos)"
        echo "3) Exit"
        read -p "Choose an option: " edit_choice

        case $edit_choice in
            1) sudo pacman -S gimp ;;
            2) sudo pacman -S kdenlive ;;
            3) break ;;  
            *) echo -e "${RED}Invalid option${RESET}" ;;
        esac
    done
}

install_browsers() {
    install_paru
    while true; do
        echo -e "${CYAN}Browsers Menu:${RESET}"
        echo "1) Brave"
        echo "2) Firefox"
        echo "3) Google Chrome"
        echo "4) Chromium"
        echo "5) Qutebrowser"
        echo "6) Zen Browser"
        echo "7) Thorium Broswer"
        echo "8) Exit"
        read -p "Choose a browser to install: " browser_choice

        case $browser_choice in
            1) paru -S brave-bin ;;
            2) sudo pacman -S firefox ;;
            3) paru -S google-chrome ;;
            4) sudo pacman -S chromium ;;
            5) sudo pacman -S qutebrowser ;;
            6) paru -S zen-browser-bin ;;
            7) paru -S thorium-browser-bin ;;
            8) break ;;  
            *) echo -e "${RED}Invalid option${RESET}" ;;
        esac
    done
}

install_filemanagers() {
    while true; do
        echo -e "${CYAN}File Manager Menu:${RESET}"
        echo "1) Nemo"
        echo "2) Thunar"
        echo "3) Dolphin"
        echo "4) LF (Terminal File Manager)"
        echo "5) Ranger"
        echo "6) Nautilus"
        echo "7) Exit"
        read -p "Choose a file manager: " fm_choice

        case $fm_choice in
            1) sudo pacman -S nemo ;;
            2) sudo pacman -S thunar ;;
            3) sudo pacman -S dolphin ;;
            4) sudo pacman -S lf ;;
            5) sudo pacman -S ranger ;;
            6) sudo pacman -S nautilus ;;
            7) break ;;  
            *) echo -e "${RED}Invalid option${RESET}" ;;
        esac
    done
}

install_music() {
    while true; do
        echo -e "${CYAN}Music Packages Menu:${RESET}"
        echo -e "${YELLOW}--------------------------------------------------------${RESET}"
        echo -e "${CYAN}Youtube Music - https://github.com/th-ch/youtube-music${RESET}"
        echo -e "${CYAN}Spotube - https://github.com/KRTirtho/spotube${RESET}"
        echo -e "${CYAN}Spotify - https://github.com/spotify${RESET}"
        echo -e "${YELLOW}--------------------------------------------------------${RESET}"
        echo "1) Youtube-Music"
        echo "2) Spotube"
        echo "3) Spotify"
        echo "4) Exit"
        read -p "Choose a Music Package: " music_choice

        case $music_choice in
            1) paru -S youtube-music-bin ;;
            2) paru -S spotube ;;
            3) paru -S spotify ;;
            4) break ;;  
            *) echo -e "${RED}Invalid option${RESET}" ;;
        esac
    done
}

while true; do
    clear 
    echo -e "${BLUE}"
    cat <<"EOF"
----------------------------------------------------------------------------------------------------------------------------
 
██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗         ██████╗  █████╗  ██████╗██╗  ██╗ █████╗  ██████╗ ███████╗███████╗
██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║         ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔════╝ ██╔════╝██╔════╝
██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║         ██████╔╝███████║██║     █████╔╝ ███████║██║  ███╗█████╗  ███████╗
██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║         ██╔═══╝ ██╔══██║██║     ██╔═██╗ ██╔══██║██║   ██║██╔══╝  ╚════██║
██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗    ██║     ██║  ██║╚██████╗██║  ██╗██║  ██║╚██████╔╝███████╗███████║
╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝
                                                                                                                           
-------------------------------------------------------------------------------------------------------------------------------
EOF
echo -e "${ENDCOLOR}"
    echo -e "${CYAN}Install Packages:${RESET}"
    echo -e "${YELLOW}---------------------------${RESET}"
    echo -e "${GREEN}1) Communication & Chatting${RESET}"
    echo -e "${GREEN}2) Live Streaming/Recording${RESET}"
    echo -e "${GREEN}3) Editing${RESET}"
    echo -e "${GREEN}4) Browsers${RESET}"
    echo -e "${GREEN}5) File Managers${RESET}"
    echo -e "${GREEN}6) Music${RESET}"
    echo -e "${GREEN}7) Exit${RESET}"
    read -p "Choose an option: " main_choice

    case $main_choice in
        1) install_communication ;;
        2) install_streaming ;;
        3) install_editing ;;
        4) install_browsers ;;
        5) install_filemanagers ;;
        6) install_music ;;
        7) exit ;;  
        *) echo -e "${RED}Invalid option${RESET}" ;;
    esac
done

