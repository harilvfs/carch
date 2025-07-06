#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

if ! command -v fzf &> /dev/null; then
    echo -e "${RED}${BOLD}Error: fzf is not installed${NC}"
    echo -e "${YELLOW}Please install fzf before running this script:${NC}"
    echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install fzf"
    echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S fzf"
    exit 1
fi

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

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

fzf_choose() {
    local options=("$@")
    printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                     --height=50% \
                                     --prompt="Select an option: " \
                                     --header="Hyprland Configuration Options" \
                                     --pointer="➤" \
                                     --color='fg:white,fg+:blue,bg+:black,pointer:blue'
}

main_menu() {
    clear

    if command -v pacman &> /dev/null; then
        distro="arch"
    elif command -v dnf &> /dev/null; then
        distro="fedora"
    else
        echo -e "\e[31mUnsupported distro. Exiting...\e[0m"
        exit 1
    fi
    echo -e "${TEAL}Distro: ${distro^} Linux${NC}"

    if [[ "$distro" == "arch" ]]; then
        options=("prasanthrangan/hyprdots" "mylinuxforwork/dotfiles" "end-4/dots-hyprland" "jakoolit/Arch-Hyprland" "Exit")
    elif [[ "$distro" == "fedora" ]]; then
        options=("mylinuxforwork/dotfiles" "jakoolit/Fedora-Hyprland" "Exit")
    fi

    echo -e "${YELLOW}Note: These are not my personal dotfiles; I am sourcing them from their respective users.${NC}"
    echo -e "${YELLOW}Backup your configurations before proceeding. I am not responsible for any data loss.${NC}"

    choice=$(fzf_choose "${options[@]}")

    if [[ "$choice" == "Exit" ]]; then
        echo -e "${RED}Exiting...${NC}"
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

    if ! fzf_confirm "Do you want to continue?"; then
        echo "Returning to menu..."
        main_menu
        return
    fi

    install_config "$choice" "$distro"
}

install_config() {
    local choice="$1"
    local distro="$2"

    if [[ "$choice" == "prasanthrangan/hyprdots" ]]; then
        pacman -S --needed git base-devel
        git clone --depth 1 https://github.com/HyDE-Project/HyDE ~/HyDE
        cd ~/HyDE/Scripts || exit
        ./install.sh
    elif [[ "$choice" == "mylinuxforwork/dotfiles" ]]; then
        if [[ "$distro" == "arch" ]]; then
            bash -c "$(curl -s https://raw.githubusercontent.com/mylinuxforwork/dotfiles/main/setup-arch.sh)"
        else
            bash -c "$(curl -s https://raw.githubusercontent.com/mylinuxforwork/dotfiles/main/setup-fedora.sh)"
        fi
    elif [[ "$choice" == "end-4/dots-hyprland" ]]; then
        bash -c "$(curl -s https://end-4.github.io/dots-hyprland-wiki/setup.sh)"
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
}

main_menu
