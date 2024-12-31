#!/bin/bash

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
CYAN='\033[36m'
GREEN='\033[32m'
BLUE='\033[34m'

print_message() {
    local color="$1"
    local message="$2"
    printf "%b%s%b\n" "$color" "$message" "$RC"
}

echo -e "${BLUE}"
figlet -f slant "DWM"

print_message "$CYAN" "Welcome to the DWM setup script."
print_message "$CYAN" "This script will install and configure a tiling window manager (DWM) along with related tools."

install_arch() {
    print_message "$CYAN" ":: Installing required packages using pacman..."
    sudo pacman -S --needed base-devel libx11 libxinerama libxft imlib2 libxcb git unzip flameshot lxappearance feh mate-polkit meson libev uthash libconfig ninja xorg-xinit xorg-server noto-fonts-emoji ttf-joypixels || {
        print_message "$RED" "Failed to install some packages."
        exit 1
    }
}

install_dwm() {
    print_message "$CYAN" ":: Cloning and installing DWM..."
    cd "$HOME" || { print_message "$RED" "Failed to navigate to home directory."; exit 1; }
    git clone https://github.com/harilvfs/dwm.git || { print_message "$RED" "Failed to clone DWM repository."; exit 1; }
    cd dwm || { print_message "$RED" "Failed to navigate to DWM directory."; exit 1; }
    sudo make clean install || { print_message "$RED" "Failed to install DWM."; exit 1; }
    print_message "$GREEN" "DWM installed successfully!"
}

install_nerd_font() {
    local FONT_DIR="$HOME/.local/share/fonts"
    local FONT_ZIP="$FONT_DIR/Meslo.zip"
    local FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"

    if fc-list | grep -qi "Meslo"; then
        print_message "$GREEN" "Meslo Nerd Fonts are already installed."
        return
    fi

    print_message "$CYAN" ":: Installing Meslo Nerd Fonts..."
    mkdir -p "$FONT_DIR"
    wget -P "$FONT_DIR" "$FONT_URL" || { print_message "$RED" "Failed to download Meslo Nerd Fonts."; exit 1; }
    unzip "$FONT_ZIP" -d "$FONT_DIR" && rm "$FONT_ZIP" || { print_message "$RED" "Failed to extract Meslo Nerd Fonts."; exit 1; }
    fc-cache -fv || { print_message "$RED" "Failed to rebuild font cache."; exit 1; }
    print_message "$GREEN" "Meslo Nerd Fonts installed successfully!"
}

install_picom_animations() {
    print_message "$CYAN" ":: Installing Picom with animations..."
    local PICOM_DIR="$HOME/.local/share/ftlabs-picom"

    if [ -d "$PICOM_DIR" ]; then
        print_message "$GREEN" "Picom repository already exists. Skipping clone."
    else
        git clone https://github.com/FT-Labs/picom.git "$PICOM_DIR" || { print_message "$RED" "Failed to clone Picom repository."; exit 1; }
    fi

    cd "$PICOM_DIR" || { print_message "$RED" "Failed to navigate to Picom directory."; exit 1; }
    meson setup --buildtype=release build || { print_message "$RED" "Meson setup failed."; exit 1; }
    ninja -C build || { print_message "$RED" "Ninja build failed."; exit 1; }
    sudo ninja -C build install || { print_message "$RED" "Failed to install Picom."; exit 1; }
    print_message "$GREEN" "Picom animations installed successfully!"
}

configure_picom() {
    print_message "$CYAN" ":: Configuring Picom..."
    local CONFIG_DIR="$HOME/.config"
    local DESTINATION="$CONFIG_DIR/picom.conf"
    local URL="https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/picom/picom.conf"

    mkdir -p "$CONFIG_DIR"
    wget -q -O "$DESTINATION" "$URL" || { print_message "$RED" "Failed to download Picom configuration."; exit 1; }
    print_message "$GREEN" "Picom configuration downloaded to $DESTINATION."
}

clone_config_folders() {
    print_message "$CYAN" ":: Cloning configuration folders..."
    mkdir -p "$HOME/.config"
    for dir in config/*/; do
        cp -r "$dir" "$HOME/.config/" || { print_message "$RED" "Failed to clone $dir."; }
        print_message "$GREEN" "Cloned $dir to ~/.config/"
    done
}

configure_wallpapers() {
    local BG_DIR="$HOME/Pictures/wallpapers"

    mkdir -p "$HOME/Pictures"
    if [ ! -d "$BG_DIR" ]; then
        git clone https://github.com/harilvfs/wallpapers "$BG_DIR" || { print_message "$RED" "Failed to clone wallpapers repository."; exit 1; }
        print_message "$GREEN" ":: Wallpapers downloaded to $BG_DIR."
    else
        print_message "$GREEN" "Wallpapers directory already exists. Skipping download."
    fi
}

install_slstatus() {
    print_message "$CYAN" ":: Installing slstatus..."
    read -p "Do you want to install slstatus? (y/N): " response
    if [[ "$response" =~ ^[yY]$ ]]; then
        cd "$HOME/dwm/slstatus" || { print_message "$RED" "Failed to navigate to slstatus directory."; exit 1; }
        sudo make clean install || { print_message "$RED" "Failed to install slstatus."; exit 1; }
        print_message "$GREEN" "slstatus installed successfully!"
    else
        print_message "$CYAN" "Skipping slstatus installation."
    fi
}

install_arch
install_dwm
install_nerd_font
install_picom_animations
configure_picom
clone_config_folders
configure_wallpapers
install_slstatus
