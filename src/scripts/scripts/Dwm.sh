#!/bin/bash

clear

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

detect_distro() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        case "$ID" in
            arch)
                distro="arch"
                print_message "$GREEN" "Detected distribution: Arch Linux"
                ;;
            fedora)
                distro="fedora"
                print_message "$YELLOW" "Detected distribution: Fedora"
                ;;
            *)
                if [[ "$ID_LIKE" == *"arch"* ]]; then
                    distro="arch"
                    print_message "$GREEN" "Detected Arch-based distribution"
                elif [[ "$ID_LIKE" == *"fedora"* ]]; then
                    distro="fedora"
                    print_message "$YELLOW" "Detected Fedora-based distribution"
                else
                    print_message "$RED" "Unsupported distribution. Exiting..."
                    exit 1
                fi
                ;;
        esac
    else
        print_message "$RED" "Cannot determine OS. Exiting..."
        exit 1
    fi
}

confirm_setup() {
    print_message "$CYAN" "Welcome to the DWM setup script."
    print_message "$CYAN" "This script will install and configure DWM along with necessary dependencies."

    if ! gum confirm "Do you want to continue with this setup?"; then
        print_message "$RED" "Setup aborted by the user. Exiting..."
        exit 1
    fi
}

install_packages() {
    if [ "$distro" == "arch" ]; then
        print_message "$CYAN" ":: Installing required packages using pacman..."
        sudo pacman -S --needed git base-devel libx11 libxinerama libxft ttf-cascadia-mono-nerd ttf-cascadia-code-nerd ttf-jetbrains-mono-nerd ttf-jetbrains-mono imlib2 libxcb git unzip lxappearance feh mate-polkit meson ninja xorg-xinit xorg-server network-manager-applet blueman pasystray bluez-utils thunar flameshot trash-cli tumbler gvfs-mtp || {
            print_message "$RED" "Failed to install some packages."
            exit 1
        }
    elif [ "$distro" == "fedora" ]; then
        print_message "$CYAN" ":: Installing required packages using dnf..."
        sudo dnf install -y git libX11-devel libXinerama-devel libXft-devel imlib2-devel libxcb-devel unzip lxappearance feh mate-polkit meson ninja-build gnome-keyring jetbrains-mono-fonts-all google-noto-color-emoji-fonts network-manager-applet blueman pasystray google-noto-emoji-fonts thunar flameshot trash-cli tumbler gvfs-mtp || {
            print_message "$RED" "Failed to install some packages."
            exit 1
        }
    fi
}

install_dwm() {
    if [ -d "$HOME/dwm" ]; then
        if gum confirm "DWM directory already exists. Do you want to overwrite it?"; then
            rm -rf "$HOME/dwm"
        else
            print_message "$YELLOW" "Skipping DWM installation."
            return
        fi
    fi
    
    print_message "$CYAN" "Cloning DWM repository..."
    git clone https://github.com/harilvfs/dwm.git "$HOME/dwm" || exit 1
    cd "$HOME/dwm" || exit 1
    sudo make clean install || exit 1
    print_message "$GREEN" "DWM installed successfully!"
}

install_slstatus() {
    print_message "$CYAN" ":: Installing slstatus..."
    if gum confirm "Do you want to install slstatus (recommended)?"; then
        cd "$HOME/dwm/slstatus" || exit 1
        sudo make clean install || exit 1
        print_message "$GREEN" "slstatus installed successfully!"
    else
        print_message "$CYAN" "Skipping slstatus installation."
    fi
}

install_nerd_font() {
    local FONT_DIR="$HOME/.fonts"
    local FONT_NAME="MesloLGS NF Regular"
    mkdir -p "$FONT_DIR"
    
    if fc-list | grep -q "$FONT_NAME"; then
        print_message "$GREEN" "Meslo Nerd Font is already installed. Skipping..."
        return
    fi

    print_message "$CYAN" "Installing Meslo Nerd Font..."
    if grep -q Fedora /etc/os-release; then
        wget -P /tmp https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip || exit 1
        unzip /tmp/Meslo.zip -d /tmp/Meslo || exit 1
        mv /tmp/Meslo/* "$FONT_DIR" || exit 1
    else
        sudo pacman -S --needed ttf-meslo-nerd || exit 1
    fi
    
    fc-cache -vf || exit 1
    print_message "$GREEN" "Nerd Fonts installed successfully!"
}

install_picom() {
    if [ "$distro" == "arch" ]; then
        if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
            print_message "$CYAN" ":: Installing yay as AUR helper..."
            
            sudo pacman -S --needed --noconfirm git base-devel

            if git clone https://aur.archlinux.org/yay.git; then
                cd yay || exit 1
                makepkg -si --noconfirm || { print_message "$RED" "Failed to install yay."; exit 1; }
                cd ..
                rm -rf yay
            else
                print_message "$RED" "Failed to clone yay repository. Exiting..."
                exit 1
            fi
        fi

        if command -v yay &>/dev/null; then
            aur_helper="yay"
        elif command -v paru &>/dev/null; then
            aur_helper="paru"
        else
            print_message "$RED" "Failed to install an AUR helper (yay/paru). Exiting..."
            exit 1
        fi

        print_message "$CYAN" ":: Installing Picom with $aur_helper..."
        $aur_helper -S --noconfirm picom-ftlabs-git || { print_message "$RED" "Failed to install Picom."; exit 1; }

    elif [ "$distro" == "fedora" ]; then
        print_message "$CYAN" ":: Installing Picom manually on Fedora..."
        sudo dnf install -y dbus-devel gcc git libconfig-devel libdrm-devel libev-devel libX11-devel libX11-xcb libXext-devel libxcb-devel libGL-devel libEGL-devel libepoxy-devel meson pcre2-devel pixman-devel uthash-devel xcb-util-image-devel xcb-util-renderutil-devel xorg-x11-proto-devel xcb-util-devel
        git clone https://github.com/FT-Labs/picom.git "$HOME/picom"
        cd "$HOME/picom" || exit 1
        meson setup --buildtype=release build
        ninja -C build
        sudo cp build/src/picom /usr/bin/
    fi
    
    configure_picom
}

configure_picom() {
    local CONFIG_DIR="$HOME/.config"
    local DESTINATION="$CONFIG_DIR/picom.conf"
    local URL="https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/picom/picom.conf"
    
    mkdir -p "$CONFIG_DIR"
    if [ -f "$DESTINATION" ]; then
        if gum confirm "Existing picom.conf detected. Do you want to replace it?"; then
            mv "$DESTINATION" "$DESTINATION.bak"
        else
            return
        fi
    fi
    
    wget -q -O "$DESTINATION" "$URL" || exit 1
    print_message "$GREEN" "Picom configuration updated."
}

configure_wallpapers() {
    local BG_DIR="$HOME/Pictures/wallpapers"
    mkdir -p "$HOME/Pictures"
    
    if [ -d "$BG_DIR" ]; then
        if gum confirm "Wallpapers directory already exists. Do you want to overwrite?"; then
            rm -rf "$BG_DIR"
        else
            return
        fi
    fi
    
    git clone https://github.com/harilvfs/wallpapers "$BG_DIR" || exit 1
    print_message "$GREEN" "Wallpapers downloaded."
}

detect_distro
confirm_setup
install_packages
install_dwm
install_slstatus
install_nerd_font
install_picom
configure_wallpapers
print_message "$GREEN" "DWM setup completed successfully!"
print_message "$YELLOW" "Notice: I am not including dotfiles in this script to avoid conflicts and potential data loss. If you need dotfiles, check out my repo:"
print_message "$CYAN" "https://github.com/harilvfs/dwm/blob/main/config"

