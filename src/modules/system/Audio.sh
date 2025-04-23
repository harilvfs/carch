#!/usr/bin/env bash

# Install & Sets up PipeWire audio system.

clear

GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
CYAN="\e[36m"
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
if command -v figlet &>/dev/null; then
    figlet -f slant "PipeWire"
else
    echo "========== PipeWire Audio Setup =========="
fi
echo -e "${ENDCOLOR}"

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

install_pipewire() {
    echo -e "${BLUE}:: Installing PipeWire and related packages...${ENDCOLOR}"
    
    if [ "$DISTRO" = "arch" ]; then
        echo -e "${CYAN}:: Installing PipeWire packages for Arch Linux...${ENDCOLOR}"
        sudo pacman -S --noconfirm lib32-pipewire pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire wireplumber rtkit
        if [ $? -ne 0 ]; then
            echo -e "${RED}:: Failed to install PipeWire packages on Arch.${ENDCOLOR}"
            exit 1
        fi
    else
        echo -e "${CYAN}:: Installing PipeWire packages for Fedora...${ENDCOLOR}"
        sudo dnf install -y pipewire
        if [ $? -ne 0 ]; then
            echo -e "${RED}:: Failed to install PipeWire packages on Fedora.${ENDCOLOR}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}:: PipeWire packages installed successfully.${ENDCOLOR}"
}

setup_user_and_services() {
    echo -e "${BLUE}:: Configuring user permissions and services...${ENDCOLOR}"
    
    echo -e "${CYAN}:: Adding user to rtkit group for realtime audio processing...${ENDCOLOR}"
    sudo usermod -a -G rtkit "$USER"
    if [ $? -ne 0 ]; then
        echo -e "${RED}:: Failed to add user to rtkit group.${ENDCOLOR}"
        exit 1
    fi
    
    echo -e "${CYAN}:: Enabling PipeWire services for user session...${ENDCOLOR}"
    systemctl --user enable pipewire pipewire-pulse wireplumber
    if [ $? -ne 0 ]; then
        echo -e "${RED}:: Failed to enable PipeWire services.${ENDCOLOR}"
        exit 1
    fi
    
    echo -e "${GREEN}:: User settings and services configured successfully.${ENDCOLOR}"
}

main() {
    detect_distro
    
    if fzf_confirm "Do you want to install PipeWire audio system?"; then
        install_pipewire
        setup_user_and_services
        echo -e "${GREEN}:: PipeWire setup completed successfully!${ENDCOLOR}"
        
        if fzf_confirm "Do you want to log out to apply changes? (Recommended)"; then
            echo -e "${BLUE}:: Logging out to apply audio system changes...${ENDCOLOR}"
            sleep 2
            if command -v loginctl &>/dev/null; then
                loginctl terminate-user "$USER"
            else
                echo -e "${CYAN}:: Please log out manually to apply changes.${ENDCOLOR}"
            fi
        else
            echo -e "${CYAN}:: Please log out or reboot your system later to apply changes.${ENDCOLOR}"
        fi
    else
        echo -e "${BLUE}:: PipeWire installation cancelled.${ENDCOLOR}"
    fi
}

main 
