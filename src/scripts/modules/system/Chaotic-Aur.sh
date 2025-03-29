#!/usr/bin/env bash

clear

BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
MAGENTA="\e[35m"
ENDCOLOR="\e[0m"

if ! command -v fzf &>/dev/null; then
    echo -e "${MAGENTA}fzf is not installed. Installing it now...${ENDCOLOR}"
    sudo pacman -S --noconfirm fzf || {
        echo -e "${RED}Failed to install fzf. Please install it manually with: sudo pacman -S fzf${ENDCOLOR}"
        exit 1
    }
fi

if ! command -v figlet &>/dev/null; then
    echo -e "${MAGENTA}figlet is not installed. Installing it now...${ENDCOLOR}"
    sudo pacman -S --noconfirm figlet || {
        echo -e "${RED}Failed to install figlet. Please install it manually with: sudo pacman -S figlet${ENDCOLOR}"
        exit 1
    }
fi

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

echo -e "${BLUE}"
if command -v figlet &>/dev/null; then
    figlet -f slant "Chaotic AUR"
else
    echo "========== Chaotic AUR Setup =========="
fi

echo -e "${RESET}"
echo -e "${MAGENTA}╭───────────────────────────────────────────────╮"
echo -e "│  🌟 Installing Chaotic AUR on Arch Linux 🌟   │"
echo -e "╰───────────────────────────────────────────────╯${ENDCOLOR}"

echo -e "Do you want to continue with the installation?"
options=("Yes" "No")
selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Select an option: " --height=10 --layout=reverse --border)

if [[ "$selected" != "Yes" ]]; then
    error "Installation aborted."
    exit 1
fi

if grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    success "Chaotic AUR is already configured in /etc/pacman.conf."
else
    info "Adding Chaotic AUR to pacman.conf..."
    echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf || {
        error "Failed to modify pacman.conf. Please try again with sudo permissions."
        exit 1
    }
fi

info "Initializing pacman keys..."
sudo pacman-key --init || {
    error "Failed to initialize pacman keys. Please check your system."
    exit 1 
}

info "Fetching Chaotic AUR key..."
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com || {
    info "Trying alternate keyserver..."
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver hkps://keys.openpgp.org || {
        error "Failed to fetch the Chaotic AUR key. Please check your internet connection."
        exit 1
    }
}

info "Signing the key..."
sudo pacman-key --lsign-key 3056513887B78AEB || {
    error "Failed to sign the key. Please try again."
    exit 1
}

info "Installing Chaotic AUR keyring and mirrorlist..."
sudo pacman -U --noconfirm "https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst" || {
    error "Failed to install chaotic-keyring. Please check your internet connection."
    exit 1
}

sudo pacman -U --noconfirm "https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst" || {
    error "Failed to install chaotic-mirrorlist. Please check your internet connection."
    exit 1
}

info "Refreshing Pacman database..."
sudo pacman -Sy || {
    error "Failed to refresh pacman database. Please try again."
    exit 1
}

success "✅ Chaotic AUR has been installed successfully!"
echo -e "${GREEN}You can now install packages from Chaotic AUR using pacman.${ENDCOLOR}"
