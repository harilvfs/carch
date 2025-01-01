#!/bin/bash

clear

BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

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

install_terminal() {
    case $1 in
        "Alacritty")
            gum spin --spinner dot --title "Installing Alacritty..." -- sudo pacman -S alacritty --noconfirm && \
            clear
            gum format "🎉 **Alacritty installed successfully!**"
            ;;
        "Kitty")
            gum spin --spinner dot --title "Installing Kitty..." -- sudo pacman -S kitty --noconfirm && \
            clear
            gum format "🎉 **Kitty installed successfully!**"
            ;;
        "GNOME Terminal")
            gum spin --spinner dot --title "Installing GNOME Terminal..." -- sudo pacman -S gnome-terminal --noconfirm && \
            clear
            gum format "🎉 **GNOME Terminal installed successfully!**"
            ;;
        "Konsole")
            gum spin --spinner dot --title "Installing Konsole..." -- sudo pacman -S konsole --noconfirm && \
            clear
            gum format "🎉 **Konsole installed successfully!**"
            ;;
        "Xfce Terminal")
            gum spin --spinner dot --title "Installing Xfce Terminal..." -- sudo pacman -S xfce4-terminal --noconfirm && \
            clear
            gum format "🎉 **Xfce Terminal installed successfully!**"
            ;;
        "LXTerminal")
            gum spin --spinner dot --title "Installing LXTerminal..." -- sudo pacman -S lxterminal --noconfirm && \
            clear
            gum format "🎉 **LXTerminal installed successfully!**"
            ;;
        "MATE Terminal")
            gum spin --spinner dot --title "Installing MATE Terminal..." -- sudo pacman -S mate-terminal --noconfirm && \
            clear
            gum format "🎉 **MATE Terminal installed successfully!**"
            ;;
        "xterm")
            gum spin --spinner dot --title "Installing xterm..." -- sudo pacman -S xterm --noconfirm && \
            clear
            gum format "🎉 **xterm installed successfully!**"
            ;;
        "urxvt (rxvt-unicode)")
            gum spin --spinner dot --title "Installing urxvt (rxvt-unicode)..." -- sudo pacman -S rxvt-unicode --noconfirm && \
            clear
            gum format "🎉 **urxvt (rxvt-unicode) installed successfully!**"
            ;;
        "Tilix")
            gum spin --spinner dot --title "Installing Tilix..." -- sudo pacman -S tilix --noconfirm && \
            clear
            gum format "🎉 **Tilix installed successfully!**"
            ;;
        "Terminator")
            gum spin --spinner dot --title "Installing Terminator..." -- sudo pacman -S terminator --noconfirm && \
            clear
            gum format "🎉 **Terminator installed successfully!**"
            ;;
        "Guake")
            gum spin --spinner dot --title "Installing Guake..." -- sudo pacman -S guake --noconfirm && \
            clear
            gum format "🎉 **Guake installed successfully!**"
            ;;
        "Yakuake")
            gum spin --spinner dot --title "Installing Yakuake..." -- sudo pacman -S yakuake --noconfirm && \
            clear
            gum format "🎉 **Yakuake installed successfully!**"
            ;;
        "Tilda")
            gum spin --spinner dot --title "Installing Tilda..." -- sudo pacman -S tilda --noconfirm && \
            clear
            gum format "🎉 **Tilda installed successfully!**"
            ;;
        "Cool Retro Term")
            gum spin --spinner dot --title "Installing Cool Retro Term..." -- sudo pacman -S cool-retro-term --noconfirm && \
            clear
            gum format "🎉 **Cool Retro Term installed successfully!**"
            ;;
        "Sakura")
            gum spin --spinner dot --title "Installing Sakura..." -- sudo pacman -S sakura --noconfirm && \
            clear
            gum format "🎉 **Sakura installed successfully!**"
            ;;
        "st (Simple Terminal)")
            gum spin --spinner dot --title "Installing st (Simple Terminal)..." -- paru -S st --noconfirm && \
            clear
            gum format "🎉 **st (Simple Terminal) installed successfully!**"
            ;;
        "Eterm")
            gum spin --spinner dot --title "Installing Eterm..." -- paru -S eterm --noconfirm && \
            clear
            gum format "🎉 **Eterm installed successfully!**"
            ;;
        "WezTerm")
            gum spin --spinner dot --title "Installing WezTerm..." -- sudo pacman -S wezterm --noconfirm && \
            clear
            gum format "🎉 **WezTerm installed successfully!**"
            ;;
        "Deepin Terminal")
            gum spin --spinner dot --title "Installing Deepin Terminal..." -- sudo pacman -S deepin-terminal --noconfirm && \
            clear
            gum format "🎉 **Deepin Terminal installed successfully!**"
            ;;
        "Zellij")
            gum spin --spinner dot --title "Installing Zellij..." -- sudo pacman -S zellij --noconfirm && \
            clear
            gum format "🎉 **Zellij installed successfully!**"
            ;;
        "Termite")
            gum spin --spinner dot --title "Installing Termite..." -- paru -S termite --noconfirm && \
            clear
            gum format "🎉 **Termite installed successfully!**"
            ;;
        "fbterm")
            gum spin --spinner dot --title "Installing fbterm..." -- paru -S fbterm --noconfirm && \
            clear
            gum format "🎉 **fbterm installed successfully!**"
            ;;
        *)
            gum format "❌ **Invalid choice. Please try again.**"
            ;;
    esac
}

install_terminals() {
    while true; do
    echo -e "${BLUE}"
    figlet -f slant "Terminal"
    echo -e "${RESET}"

    echo -e "${BLUE}Select a terminal to install:${RESET}"
    echo -e "1) Alacritty"
    echo -e "2) Kitty"
    echo -e "3) GNOME Terminal"
    echo -e "4) Konsole"
    echo -e "5) Xfce Terminal"
    echo -e "6) LXTerminal"
    echo -e "7) MATE Terminal"
    echo -e "8) xterm"
    echo -e "9) urxvt (rxvt-unicode)"
    echo -e "10) Tilix"
    echo -e "11) Terminator"
    echo -e "12) Guake"
    echo -e "13) Yakuake"
    echo -e "14) Tilda"
    echo -e "15) Cool Retro Term"
    echo -e "16) Sakura"
    echo -e "17) st (Simple Terminal)"
    echo -e "18) Eterm"
    echo -e "19) WezTerm"
    echo -e "20) Deepin Terminal"
    echo -e "21) Zellij"
    echo -e "22) Termite"
    echo -e "23) fbterm"
    echo -e "24) Exit"

    read -p "Enter your choice (1-24): " choice
    case $choice in
        1) install_terminal "Alacritty" ;;
        2) install_terminal "Kitty" ;;
        3) install_terminal "GNOME Terminal" ;;
        4) install_terminal "Konsole" ;;
        5) install_terminal "Xfce Terminal" ;;
        6) install_terminal "LXTerminal" ;;
        7) install_terminal "MATE Terminal" ;;
        8) install_terminal "xterm" ;;
        9) install_terminal "urxvt (rxvt-unicode)" ;;
        10) install_terminal "Tilix" ;;
        11) install_terminal "Terminator" ;;
        12) install_terminal "Guake" ;;
        13) install_terminal "Yakuake" ;;
        14) install_terminal "Tilda" ;;
        15) install_terminal "Cool Retro Term" ;;
        16) install_terminal "Sakura" ;;
        17) install_terminal "st (Simple Terminal)" ;;
        18) install_terminal "Eterm" ;;
        19) install_terminal "WezTerm" ;;
        20) install_terminal "Deepin Terminal" ;;
        21) install_terminal "Zellij" ;;
        22) install_terminal "Termite" ;;
        23) install_terminal "fbterm" ;;
        24) echo "Exiting..."; exit 0 ;;
        *) gum format "❌ **Invalid choice. Please try again.**" ;;
        esac
    done 
}

install_terminals

