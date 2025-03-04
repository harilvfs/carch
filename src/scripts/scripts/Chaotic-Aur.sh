#!/bin/bash

clear

BLUE="\e[34m"
ENDCOLOR="\e[0m"

if ! command -v gum &>/dev/null; then
    echo "gum is not installed. Please install it first using: sudo pacman -S gum"
    exit 1
fi

info() { gum style --foreground 212 "$1"; }
success() { gum style --foreground 46 "$1"; }
error() { gum style --foreground 196 "$1"; }

if [[ $EUID -eq 0 ]]; then
    error "Please run this script as a normal user, not as root."
    exit 1
fi

if command -v dnf &>/dev/null; then
    error "You are using Fedora (dnf detected). This script is only for Arch-based systems."
    exit 1
elif ! command -v pacman &>/dev/null; then
    error "This script is for Arch-based distros only. Exiting."
    exit 1
fi

echo -e "${BLUE}"
figlet -f slant "Chaotic AUR"
echo -e "${ENDCOLOR}"

gum style --border normal --border-foreground 212 --margin "1 2" --padding "1 2" \
    "🌟 Installing Chaotic AUR on Arch Linux 🌟"


if ! gum confirm "Do you want to continue with the installation?"; then
    error "Installation aborted."
    exit 1
fi

if grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    success "Chaotic AUR is already configured in /etc/pacman.conf."
else
    info "Adding Chaotic AUR to pacman.conf..."
    echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
fi

info "Initializing pacman keys..."
sudo pacman-key --init
info "Fetching Chaotic AUR key..."
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
info "Signing the key..."
sudo pacman-key --lsign-key 3056513887B78AEB

info "Installing Chaotic AUR keyring and mirrorlist..."
sudo pacman -U --noconfirm "https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst"
sudo pacman -U --noconfirm "https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst"

info "Refreshing Pacman database..."
sudo pacman -Sy

success "✅ Chaotic AUR has been installed successfully!"

