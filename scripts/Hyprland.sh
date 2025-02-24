#!/bin/bash

clear

BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'  

echo -e "${BLUE}"
figlet -f slant "Hyprland"
echo -e "${RESET}"

type figlet &>/dev/null || { echo "figlet is not installed. Install it first."; exit 1; }
type gum &>/dev/null || { echo "gum is not installed. Install it first."; exit 1; }

source /etc/os-release
case "$ID" in
    arch)
        distro="arch"
        ;;
    fedora)
        distro="fedora"
        ;;
    *)
        echo -e "${RED}Unsupported distro. Exiting...${RESET}"
        exit 1
        ;;
esac

echo -e "${BLUE}Distro: ${distro^} Linux${RESET}"

if [[ "$distro" == "arch" ]]; then
    options=("prasanthrangan/hyprdots" "mylinuxforwork/dotfiles" "end-4/dots-hyprland" "jakoolit/Arch-Hyprland" "Exit")
elif [[ "$distro" == "fedora" ]]; then
    options=("mylinuxforwork/dotfiles" "jakoolit/Fedora-Hyprland" "Exit")
fi

echo -e "${YELLOW}Note: These are not my personal dotfiles; I am sourcing them from their respective users.${RESET}"
echo -e "${YELLOW}Backup your configurations before proceeding. I am not responsible for any data loss.${RESET}"

if ! gum confirm "Continue with Hyprland setup?"; then
    echo -e "${RED}Setup aborted by the user.${RESET}"
    exit 1
fi

choice=$(printf "%s\n" "${options[@]}" | gum choose)

if [[ "$choice" == "Exit" ]]; then
    echo -e "${RED}Exiting...${RESET}"
    exit 0
fi

echo "You selected: $choice"

declare -A repos
repos["prasanthrangan/hyprdots"]="https://github.com/prasanthrangan/hyprdots"
repos["mylinuxforwork/dotfiles"]="https://github.com/mylinuxforwork/dotfiles"
repos["end-4/dots-hyprland"]="https://github.com/end-4/dots-hyprland"
repos["jakoolit/Arch-Hyprland"]="https://github.com/JaKooLit/Arch-Hyprland"
repos["jakoolit/Fedora-Hyprland"]="https://github.com/JaKooLit/Fedora-Hyprland"

echo "Sourcing from: ${repos[$choice]}"
if ! gum confirm "Do you want to continue?"; then
    echo "Aborted."
    exit 1
fi

if [[ "$choice" == "prasanthrangan/hyprdots" ]]; then
    pacman -S --needed git base-devel
    git clone --depth 1 https://github.com/HyDE-Project/HyDE ~/HyDE
    cd ~/HyDE/Scripts || exit
    ./install.sh

elif [[ "$choice" == "mylinuxforwork/dotfiles" ]]; then
    if [[ "$distro" == "arch" ]]; then
        bash <(curl -s https://raw.githubusercontent.com/mylinuxforwork/dotfiles/main/setup-arch.sh)
    else
        bash <(curl -s https://raw.githubusercontent.com/mylinuxforwork/dotfiles/main/setup-fedora.sh)
    fi

elif [[ "$choice" == "end-4/dots-hyprland" ]]; then
    bash <(curl -s "https://end-4.github.io/dots-hyprland-wiki/setup.sh")

elif [[ "$choice" == "jakoolit/Arch-Hyprland" ]]; then
    git clone --depth=1 https://github.com/JaKooLit/Arch-Hyprland.git ~/Arch-Hyprland
    cd ~/Arch-Hyprland || exit
    chmod +x install.sh
    ./install.sh

elif [[ "$choice" == "jakoolit/Fedora-Hyprland" ]]; then
    git clone --depth=1 https://github.com/JaKooLit/Fedora-Hyprland.git ~/Fedora-Hyprland
    cd ~/Fedora-Hyprland || exit
    chmod +x install.sh
    ./install.sh
fi

display_message() {
    gum style --border "normal" --width 50 --padding 1 --foreground "white" --background "blue" --align "center" "Hyprland setup completed"
}

display_message
