#!/bin/bash

clear

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE="\e[34m"
ENDCOLOR="\e[0m"
RESET='\033[0m'

install_paru() {
    if ! command -v paru &> /dev/null; then
        echo -e "${RED}Paru not found. :: Installing...${RESET}"
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
        echo -e "${GREEN}:: Paru is already installed.${RESET}"
    fi
}

install_browsers() {
    install_paru
    while true; do
    echo -e "${BLUE}"
    figlet -f slant "Browsers"
    echo -e "${ENDCOLOR}"

        echo -e "${BLUE}Select a browser to install:${RESET}"
        echo "1) Brave"
        echo "2) Firefox"
        echo "3) Libre Wolf"
        echo "4) Google Chrome"
        echo "5) Chromium"
        echo "6) Vivaldi"
        echo "7) Qute Browser"
        echo "8) Zen Browser"
        echo "9) Thorium Browser"
        echo "10) Tor Browser"
        echo "11) Exit"
        read -p "Enter your choice [1-11]: " browser_choice

        case $browser_choice in
            1)
                gum spin --spinner dot --title "Installing Brave Browser..." -- paru -S --noconfirm brave-bin && \
                version=$(pacman -Qi brave-bin | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **Brave Browser installed successfully! Version: $version**"
                ;;
            2)
                gum spin --spinner dot --title "Installing Firefox..." -- sudo pacman -S --noconfirm firefox && \
                version=$(pacman -Qi firefox | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **Firefox installed successfully! Version: $version**"
                ;;
            3)
                gum spin --spinner dot --title "Installing Libre Wolf..." -- paru -S --noconfirm librewolf-bin && \
                version=$(pacman -Qi librewolf-bin | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **Libre Wolf installed successfully! Version: $version**"
                ;;
            4)
                gum spin --spinner dot --title "Installing Google Chrome..." -- paru -S --noconfirm google-chrome && \
                version=$(pacman -Qi google-chrome | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **Google Chrome installed successfully! Version: $version**"
                ;;
            5)
                gum spin --spinner dot --title "Installing Chromium..." -- sudo pacman -S --noconfirm chromium && \
                version=$(pacman -Qi chromium | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **Chromium installed successfully! Version: $version**"
                ;;
            6)
                gum spin --spinner dot --title "Installing Vivaldi..." -- sudo pacman -S --noconfirm vivaldi && \
                version=$(pacman -Qi vivaldi | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **Vivaldi installed successfully! Version: $version**"
                ;;
            7)
                gum spin --spinner dot --title "Installing Qute Browser..." -- sudo pacman -S --noconfirm qutebrowser && \
                version=$(pacman -Qi qutebrowser | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **Qute Browser installed successfully! Version: $version**"
                ;;
            8)
                gum spin --spinner dot --title "Installing Zen Browser..." -- paru -S --noconfirm zen-browser-bin && \
                version=$(pacman -Qi zen-browser-bin | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **Zen Browser installed successfully! Version: $version**"
                ;;
            9)
                gum spin --spinner dot --title "Installing Thorium Browser..." -- paru -S --noconfirm thorium-browser-bin && \
                version=$(pacman -Qi thorium-browser-bin | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **Thorium Browser installed successfully! Version: $version**"
                ;;
            10)
                gum spin --spinner dot --title "Installing Tor Browser..." -- paru -S --noconfirm tor-browser-bin && \
                version=$(pacman -Qi tor-browser-bin | grep Version | awk '{print $3}') && \
                clear
                gum format "🎉 **Tor Browser installed successfully! Version: $version**"
                ;;
            11)
                break
                ;;
        esac
    done
}

install_browsers
