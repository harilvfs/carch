#!/usr/bin/env bash

# Install and configure Pacman to add the Chaotic AUR on Arch

clear

BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
MAGENTA="\e[35m"
ENDCOLOR="\e[0m"

info() { echo -e "${MAGENTA}$1${ENDCOLOR}"; }
success() { echo -e "${GREEN}$1${ENDCOLOR}"; }
error() { echo -e "${RED}$1${ENDCOLOR}"; }

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

if grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    success "Chaotic AUR is already configured in /etc/pacman.conf."
    exit 0
fi

if [ ! -d "/etc/pacman.d/gnupg" ]; then
    info "Initializing pacman keys..."
    sudo pacman-key --init || {
        error "Failed to initialize pacman keys. Please check your system."
        exit 1
    }
fi

info "Fetching Chaotic AUR key..."
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com || {
    error "Failed to fetch the Chaotic AUR key. Please check your internet connection."
    exit 1
}

info "Signing the key..."
sudo pacman-key --lsign-key 3056513887B78AEB || {
    error "Failed to sign the key. Please try again."
    exit 1
}

info "Installing Chaotic AUR keyring..."
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' || {
    error "Failed to install chaotic-keyring. Please check your internet connection."
    exit 1
}

info "Installing Chaotic AUR mirrorlist..."
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' || {
    error "Failed to install chaotic-mirrorlist. Please check your internet connection."
    exit 1
}

info "Adding Chaotic AUR to pacman.conf..."
echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf || {
    error "Failed to modify pacman.conf. Please try again with sudo permissions."
    exit 1
}

info "Syncing Pacman database..."
sudo pacman -Syy || {
    error "Failed to sync pacman database. Please try again."
    exit 1
}

success "Chaotic AUR has been installed successfully!"
echo -e "${GREEN}You can now install packages from Chaotic AUR using pacman.${ENDCOLOR}"
