#!/bin/bash

set -e  
set -o pipefail 

# Colors
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m" # No color

clear

echo -e "${BLUE}"
figlet -f slant "SwayWM"

echo -e "${BLUE}

${NC}${YELLOW}:: If the setup fails, please manually use the dotfiles from:
https://github.com/harilvfs/swaydotfiles${NC}
"

if ! gum confirm "Continue with Sway setup?"; then
    echo -e "${RED}Setup aborted by the user.${NC}"
    exit 1
fi

echo -e "${GREEN}:: Installing dependencies...${NC}"
if ! sudo pacman -S --noconfirm sway wlroots fastfetch fish foot nwg-drawer swappy swaylock swayr waybar wayland pango cairo gdk-pixbuf2 json-c scdoc meson ninja pcre2 gtk-layer-shell jsoncpp libsigc++ libdbusmenu-gtk3 libxkbcommon fmt spdlog glibmm gtkmm3 alsa-utils pulseaudio libnl iw wob swaybg swayidle swaylock alacritty wofi wl-clipboard grim slurp mako ttf-nerd-fonts-symbols-mono; then
    echo -e "${RED}Failed to install dependencies.${NC}"
    exit 1
fi

echo -e "${GREEN}:: Cloning Sway dotfiles...${NC}"
if ! git clone https://github.com/harilvfs/swaydotfiles /tmp/swaydotfiles; then
    echo -e "${RED}Failed to clone Sway dotfiles repository.${NC}"
    exit 1
fi

cd /tmp/swaydotfiles
echo -e "${GREEN}:: Moving Sway dotfiles to ~/.config...${NC}"
if ! mv * ~/.config/; then
    echo -e "${RED}Failed to move Sway dotfiles to ~/.config.${NC}"
    exit 1
fi

echo -e "${GREEN}:: Cloning CyberEXS GRUB theme repository...${NC}"
if ! git clone https://github.com/HenriqueLopes42/themeGrub.CyberEXS; then
    echo -e "${RED}Failed to clone GRUB theme repository.${NC}"
    exit 1
fi
cd themeGrub.CyberEXS

echo -e "${GREEN}:: Installing CyberEXS GRUB theme...${NC}"
sudo mkdir -p /usr/share/grub/themes/CyberEXS
sudo mv * /usr/share/grub/themes/CyberEXS/

echo -e "${GREEN}:: Setting GRUB theme...${NC}"
if ! echo 'GRUB_THEME="/usr/share/grub/themes/CyberEXS/theme.txt"' | sudo tee -a /etc/default/grub; then
    echo -e "${RED}Failed to set GRUB theme.${NC}"
    exit 1
fi

if [ -f /etc/debian_version ]; then
    echo -e "${GREEN}:: Updating GRUB for Debian-based systems...${NC}"
    if ! sudo update-grub; then
        echo -e "${RED}Failed to update GRUB for Debian-based systems.${NC}"
        exit 1
    fi
elif [ -f /etc/arch-release ]; then
    echo -e "${GREEN}:: Updating GRUB for Arch-based systems...${NC}"
    if ! sudo grub-mkconfig -o /boot/grub/grub.cfg; then
        echo -e "${RED}Failed to update GRUB for Arch-based systems.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}Unknown system type. Skipping GRUB update.${NC}"
fi

echo -e "${BLUE}:: Sway Dotfiles setup and CyberEXS GRUB theme applied successfully!${NC}"
