#!/usr/bin/env bash

# Install Bluetooth Needed Packages & Sets up Bluetooth.

clear

GREEN="\e[32m"
YELLOW='\033[33m'
BLUE="\e[34m"
RED="\e[31m"
CYAN="\e[36m"
ENDCOLOR="\e[0m"

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

detect_distro() {
    echo -e "${BLUE}:: Detecting distribution...${ENDCOLOR}"
    if command -v pacman &>/dev/null; then
        echo -e "${GREEN}:: Arch Linux detected.${ENDCOLOR}"
        DISTRO="arch"
    elif command -v dnf &>/dev/null; then
        echo -e "${GREEN}:: Fedora detected.${ENDCOLOR}"
        DISTRO="fedora"
    else
        echo -e "${RED}:: Unsupported distribution. This script only supports Arch and Fedora.${ENDCOLOR}"
        exit 1
    fi
}

install_bluetooth() {
    echo -e "${BLUE}:: Installing Bluetooth packages...${ENDCOLOR}"

    if [ "$DISTRO" = "arch" ]; then
        echo -e "${CYAN}:: Installing Bluetooth packages for Arch Linux...${ENDCOLOR}"
        sudo pacman -S --noconfirm bluez bluez-utils blueman
        if [ $? -ne 0 ]; then
            echo -e "${RED}:: Failed to install Bluetooth packages on Arch.${ENDCOLOR}"
            exit 1
        fi
    else
        echo -e "${CYAN}:: Installing Bluetooth packages for Fedora...${ENDCOLOR}"
        sudo dnf install -y bluez bluez-tools blueman
        if [ $? -ne 0 ]; then
            echo -e "${RED}:: Failed to install Bluetooth packages on Fedora.${ENDCOLOR}"
            exit 1
        fi
    fi

    echo -e "${GREEN}:: Bluetooth packages installed successfully.${ENDCOLOR}"
}

enable_bluetooth() {
    echo -e "${BLUE}:: Enabling Bluetooth service...${ENDCOLOR}"

    sudo systemctl enable --now bluetooth.service
    if [ $? -ne 0 ]; then
        echo -e "${RED}:: Failed to enable Bluetooth service.${ENDCOLOR}"
        exit 1
    fi

    echo -e "${GREEN}:: Bluetooth service enabled successfully.${ENDCOLOR}"
}

provide_additional_info() {
    echo -e "${BLUE}:: Additional Information:${ENDCOLOR}"
    echo -e "${CYAN}:: • To pair a device: Use the Blueman applet or 'bluetoothctl' in terminal${ENDCOLOR}"
    echo -e "${CYAN}:: • To access Bluetooth settings: Use the Blueman application${ENDCOLOR}"
    echo -e "${CYAN}:: • To pair via terminal: Run 'bluetoothctl', then 'power on', 'scan on', 'pair MAC_ADDRESS'${ENDCOLOR}"
}

main() {

    if ! command -v fzf &> /dev/null; then
        echo -e "${RED}${BOLD}Error: fzf is not installed${NC}"
        echo -e "${YELLOW}Please install fzf before running this script:${NC}"
        echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install fzf"
        echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S fzf"
        exit 1
    fi

    detect_distro

    if fzf_confirm "Do you want to install Bluetooth system?"; then
        install_bluetooth
        enable_bluetooth
        echo -e "${GREEN}:: Bluetooth setup completed successfully!${ENDCOLOR}"
        provide_additional_info

        if fzf_confirm "Do you want to restart the Bluetooth service now?"; then
            echo -e "${BLUE}:: Restarting Bluetooth service...${ENDCOLOR}"
            sudo systemctl restart bluetooth.service
            echo -e "${GREEN}:: Bluetooth service restarted.${ENDCOLOR}"
        fi
    else
        echo -e "${BLUE}:: Bluetooth installation cancelled.${ENDCOLOR}"
    fi
}

main
