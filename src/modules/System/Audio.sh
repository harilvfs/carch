#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" >/dev/null 2>&1

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

check_multilib() {
    echo -e "${TEAL}:: Checking multilib repository status...${ENDCOLOR}"

    if grep -q '^\[multilib\]' /etc/pacman.conf; then
        echo -e "${GREEN}:: 32-bit multilib repository is already enabled.${ENDCOLOR}"
        return 0
    elif grep -q '^\#\[multilib\]' /etc/pacman.conf; then
        echo -e "${YELLOW}:: Multilib repository found but is commented out.${ENDCOLOR}"

        if fzf_confirm "Do you want to enable the multilib repository?"; then
            sudo cp /etc/pacman.conf /etc/pacman.conf.bak

            sudo sed -i '/^\#\[multilib\]/,+1 s/^\#//' /etc/pacman.conf

            echo -e "${GREEN}:: Multilib repository has been enabled.${ENDCOLOR}"
            echo -e "${CYAN}:: Updating package databases...${ENDCOLOR}"
            sudo pacman -Sy
            return 0
        else
            echo -e "${YELLOW}:: Warning: Multilib repository is required for 32-bit applications.${ENDCOLOR}"
            echo -e "${YELLOW}:: Some functionality may be limited.${ENDCOLOR}"
            return 1
        fi
    else
        echo -e "${RED}:: Multilib repository not found in pacman.conf.${ENDCOLOR}"
        return 1
    fi
}

install_pipewire() {
    echo -e "${TEAL}:: Installing PipeWire and related packages...${ENDCOLOR}"
    if [ "$DISTRO" = "arch" ]; then
        echo -e "${CYAN}:: Installing PipeWire packages for Arch Linux...${ENDCOLOR}"

        local multilib_enabled=true
        if ! check_multilib; then
            multilib_enabled=false
            echo -e "${YELLOW}:: Installing without 32-bit support...${ENDCOLOR}"
        fi

        if [ "$multilib_enabled" = true ]; then
            sudo pacman -S --noconfirm pipewire pipewire-alsa pipewire-jack pipewire-pulse lib32-pipewire gst-plugin-pipewire wireplumber rtkit
        else
            sudo pacman -S --noconfirm pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire wireplumber rtkit
        fi

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
    echo -e "${TEAL}:: Configuring user permissions and services...${ENDCOLOR}"
    echo -e "${CYAN}:: Adding user to rtkit group for realtime audio processing...${ENDCOLOR}"
    sudo usermod -a -G rtkit "$USER"
    if [ $? -ne 0 ]; then
        echo -e "${RED}:: Failed to add user to rtkit group.${ENDCOLOR}"
        exit 1
    fi
    echo -e "${CYAN}:: Enabling PipeWire services...${ENDCOLOR}"
    systemctl --user enable pipewire pipewire-pulse wireplumber
    if [ $? -ne 0 ]; then
        echo -e "${RED}:: Failed to enable PipeWire services.${ENDCOLOR}"
        exit 1
    fi

    echo -e "${GREEN}:: User settings and services configured successfully.${ENDCOLOR}"
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
    if fzf_confirm "Do you want to install PipeWire audio system?"; then
        install_pipewire
        setup_user_and_services
        echo -e "${GREEN}:: PipeWire setup completed successfully!${ENDCOLOR}"
        if fzf_confirm "Do you want to log out to apply changes? (Recommended)"; then
            echo -e "${TEAL}:: Logging out to apply audio system changes...${ENDCOLOR}"
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
        echo -e "${TEAL}:: PipeWire installation cancelled.${ENDCOLOR}"
    fi
}

main
