#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

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

print_banner() {
    echo -e "${GREEN}"
    cat << "EOF"
Catppuccin SDDM Theme
https://github.com/catppuccin/sddm
EOF
    echo -e "${ENDCOLOR}"
}

detect_os() {
    if command -v pacman &> /dev/null; then
        DISTRO="arch"
    elif command -v dnf &> /dev/null; then
        DISTRO="fedora"
    else
        echo -e "${RED}Unsupported distribution!${ENDCOLOR}"
        exit 1
    fi
}

disable_other_dms() {
    echo -e "${GREEN}:: Disabling any other active display manager...${ENDCOLOR}"
    local dms=("gdm" "lightdm" "lxdm" "xdm" "greetd")
    for dm in "${dms[@]}"; do
        if systemctl is-enabled "$dm" &> /dev/null; then
            echo -e "${RED}:: Disabling $dm...${ENDCOLOR}"
            sudo systemctl disable "$dm" --now || echo -e "${RED}Failed to disable $dm. Continuing...${ENDCOLOR}"
        fi
    done
}

enable_sddm() {
    echo -e "${GREEN}:: Enabling SDDM...${ENDCOLOR}"
    if ! sudo systemctl enable sddm --now; then
        echo -e "${RED}Failed to enable SDDM. Exiting...${ENDCOLOR}"
        exit 1
    fi
}

install_sddm() {
    if ! command -v sddm &> /dev/null; then
        echo -e "${GREEN}:: Installing SDDM...${ENDCOLOR}"

        if [[ $DISTRO == "arch" ]]; then
            sudo pacman -S --noconfirm sddm
        elif [[ $DISTRO == "fedora" ]]; then
            sudo dnf install -y sddm
        else
            echo -e "${RED}Unsupported distribution!${ENDCOLOR}"
            exit 1
        fi
    else
        echo -e "${GREEN}SDDM is already installed.${ENDCOLOR}"
    fi
}

install_theme() {
    local theme_dir="/usr/share/sddm/themes/"
    local theme_url="https://github.com/catppuccin/sddm/releases/download/v1.0.0/catppuccin-mocha.zip"

    if [ -d "$theme_dir/catppuccin-mocha" ]; then
        echo -e "${RED}:: Catppuccin theme already exists.${ENDCOLOR}"
        if fzf_confirm "Do you want to remove the existing theme and install a new one?"; then
            echo -e "${GREEN}:: Removing the existing theme...${ENDCOLOR}"
            sudo rm -rf "$theme_dir/catppuccin-mocha"
        else
            echo -e "${RED}:: Keeping the existing theme. Exiting...${ENDCOLOR}"
            exit 1
        fi
    fi
    echo -e "${GREEN}:: Downloading Catppuccin SDDM theme...${ENDCOLOR}"
    sudo mkdir -p "$theme_dir"
    if ! sudo wget -O /tmp/catppuccin-mocha.zip "$theme_url"; then
        echo -e "${RED}Failed to download the theme. Exiting...${ENDCOLOR}"
        exit 1
    fi
    if ! sudo unzip -o /tmp/catppuccin-mocha.zip -d "$theme_dir"; then
        echo -e "${RED}Failed to unzip the theme. Exiting...${ENDCOLOR}"
        exit 1
    fi
    sudo rm /tmp/catppuccin-mocha.zip
    echo -e "${GREEN}Catppuccin SDDM theme installed.${ENDCOLOR}"
}

set_theme() {
    echo -e "${GREEN}:: Setting Catppuccin as the SDDM theme...${ENDCOLOR}"
    sudo bash -c 'cat > /etc/sddm.conf <<EOF
[Theme]
Current=catppuccin-mocha
# [Autologin]
# User=username
# Session=dwm,hyprland or others
#
EOF'
}

if ! command -v fzf &> /dev/null; then
    echo -e "${RED}${BOLD}Error: fzf is not installed${NC}"
    echo -e "${YELLOW}Please install fzf before running this script:${NC}"
    echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install fzf"
    echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S fzf"
    exit 1
fi

print_banner
detect_os

echo -e "${GREEN}:: Proceeding with installation...${ENDCOLOR}"
install_sddm
install_theme
set_theme
disable_other_dms
enable_sddm

echo -e "${GREEN}:: Setup complete. Please reboot your system to see the changes.${ENDCOLOR}"
