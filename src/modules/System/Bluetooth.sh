#!/usr/bin/env bash

set -euo pipefail

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../fzf.sh" > /dev/null 2>&1

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
    echo -e "${TEAL}:: Detecting distribution...${ENDCOLOR}"
    if command -v pacman &> /dev/null; then
        echo -e "${GREEN}:: Arch Linux detected.${ENDCOLOR}"
        DISTRO="arch"
    elif command -v dnf &> /dev/null; then
        echo -e "${GREEN}:: Fedora detected.${ENDCOLOR}"
        DISTRO="fedora"
    elif command -v zypper &> /dev/null; then
        echo -e "${GREEN}:: openSUSE detected.${ENDCOLOR}"
        DISTRO="opensuse"
    else
        echo -e "${RED}:: Unsupported distribution.${ENDCOLOR}"
        exit 1
    fi
}

install_bluetooth() {
    echo -e "${TEAL}:: Installing Bluetooth packages...${ENDCOLOR}"

    if [ "$DISTRO" = "arch" ]; then
        echo -e "${CYAN}:: Installing Bluetooth packages for Arch Linux...${ENDCOLOR}"
        sudo pacman -S --noconfirm bluez bluez-utils blueman
        if [ $? -ne 0 ]; then
            echo -e "${RED}:: Failed to install Bluetooth packages on Arch.${ENDCOLOR}"
            exit 1
        fi

    elif [ "$DISTRO" = "fedora" ]; then
        echo -e "${CYAN}:: Installing Bluetooth packages for Fedora...${ENDCOLOR}"
        sudo dnf install -y bluez bluez-tools blueman
        if [ $? -ne 0 ]; then
            echo -e "${RED}:: Failed to install Bluetooth packages on Fedora.${ENDCOLOR}"
            exit 1
        fi

    elif [ "$DISTRO" = "opensuse" ]; then
        echo -e "${CYAN}:: Installing Bluetooth packages for openSUSE...${ENDCOLOR}"
        sudo zypper install -y bluez blueman
        if [ $? -ne 0 ]; then
            echo -e "${RED}:: Failed to install Bluetooth packages on openSUSE.${ENDCOLOR}"
            exit 1
        fi
    fi

    echo -e "${GREEN}:: Bluetooth packages installed successfully.${ENDCOLOR}"
}

enable_bluetooth() {
    echo -e "${TEAL}:: Enabling Bluetooth service...${ENDCOLOR}"

    sudo systemctl enable --now bluetooth.service
    if [ $? -ne 0 ]; then
        echo -e "${RED}:: Failed to enable Bluetooth service.${ENDCOLOR}"
        exit 1
    fi

    echo -e "${GREEN}:: Bluetooth service enabled successfully.${ENDCOLOR}"
}

provide_additional_info() {
    echo -e "${TEAL}:: Additional Information:${ENDCOLOR}"
    echo -e "${CYAN}:: • To pair a device: Use the Blueman applet or 'bluetoothctl' in terminal${ENDCOLOR}"
    echo -e "${CYAN}:: • To access Bluetooth settings: Use the Blueman application${ENDCOLOR}"
    echo -e "${CYAN}:: • To pair via terminal: Run 'bluetoothctl', then 'power on', 'scan on', 'pair MAC_ADDRESS'${ENDCOLOR}"
}

main() {
    check_fzf
    detect_distro

    if fzf_confirm "Do you want to install the Bluetooth system?"; then
        install_bluetooth
        enable_bluetooth
        echo -e "${GREEN}:: Bluetooth setup completed successfully!${ENDCOLOR}"
        provide_additional_info

        if fzf_confirm "Do you want to restart the Bluetooth service now?"; then
            echo -e "${TEAL}:: Restarting Bluetooth service...${ENDCOLOR}"
            sudo systemctl restart bluetooth.service
            echo -e "${GREEN}:: Bluetooth service restarted.${ENDCOLOR}"
        fi
    else
        echo -e "${TEAL}:: Bluetooth installation cancelled.${ENDCOLOR}"
    fi
}

main
