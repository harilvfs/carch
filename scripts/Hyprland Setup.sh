#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'  
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
cat <<"EOF"
-----------------------------------------------------------------------------------------------------------------


██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗     ███████╗███████╗████████╗██╗   ██╗██████╗ 
██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗    ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║    ███████╗█████╗     ██║   ██║   ██║██████╔╝
██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║    ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ 
██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝    ███████║███████╗   ██║   ╚██████╔╝██║     
╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝     ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     
                                                                                                                 

-----------------------------------------------------------------------------------------------------------------
                                 For better results, consider using
                              Prasanth Rangan's Hyprland configuration
                             https://github.com/prasanthrangan/hyprdots
                        Note: I have tweaked some configs to suit my use cases
-----------------------------------------------------------------------------------------------------------------
EOF
echo -e "${ENDCOLOR}"

read -p "Do you want to continue with this script? (y/n): " choice

if [[ "$choice" != "yes" ]]; then
    echo -e "${RED}Exiting the script.${RESET}"
    exit 1
fi

echo -e "${GREEN}Proceeding with Hyperland setup...${RESET}"

install_if_missing() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${YELLOW}Installing $1...${RESET}"
        sudo pacman -S --noconfirm "$1"
    else
        echo -e "${GREEN}$1 is already installed.${RESET}"
    fi
}

if ! command -v paru &> /dev/null; then
    echo -e "${YELLOW}Installing paru for AUR package management...${RESET}"
    sudo pacman -S --needed base-devel git --noconfirm
    git clone https://aur.archlinux.org/paru.git
    cd paru || exit
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
else
    echo -e "${GREEN}Paru is already installed.${RESET}"
fi

dependencies=(
    "kvantum"
    "alacritty"
    "dunst"
    "fastfetch"
    "flameshot"
    "gtk3"
    "gtk4"
    "kitty"
    "nano"
    "vim"
    "neovim"
    "picom"
    "qt5-base"
    "qt6-base"
    "rofi"
    "wayland"
    "swappy"
    "swaklock"
    "waybar"
    "wlogout"
    "grim"
    "slurp"
    "swaybg"
    "wlr-randr"
    "xorg-xwayland"
    "wl-clipboard"
    "polkit"
    "sddm"
    "firefox"     
    "gimp"       
    "discord"   
    "telegram-desktop" 
)

for dep in "${dependencies[@]}"; do
    install_if_missing "$dep"
done

if ! paru -Q hyprland &> /dev/null; then
    echo -e "${YELLOW}Installing Hyprland and wlroots from AUR...${RESET}"
    paru -S --noconfirm hyprland wlroots
else
    echo -e "${GREEN}Hyprland and wlroots are already installed.${RESET}"
fi

echo -e "${YELLOW}Cloning Hyprland configuration...${RESET}"
git clone https://github.com/harilvfs/hyprland ~/.config/hyprland

echo -e "${YELLOW}Moving files to ~/.config...${RESET}"
cd ~/.config/hyprland || exit
mv * ~/.config/

echo -e "${GREEN}=================================${RESET}"
echo -e "${GREEN}    Hyperland installation is    ${RESET}"
echo -e "${GREEN}        successfully done!       ${RESET}"
echo -e "${GREEN}=================================${RESET}"

