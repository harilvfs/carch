#!/bin/bash

tput init
tput clear
echo "========================================"
echo "     Hyperland Setup Script Notice      "
echo "========================================"
echo "For better results, consider using"
echo "Prasanth Rangan's Hyprland configuration:"
echo "https://github.com/prasanthrangan/hyprdots"
echo "Note: I have tweaked some configs to suit my use cases."
echo

read -p "Do you want to continue with this script? (yes/no): " choice

if [[ "$choice" != "yes" ]]; then
    echo "Exiting the script."
    exit 1
fi

echo "Proceeding with Hyperland setup..."

install_if_missing() {
    if ! command -v "$1" &> /dev/null; then
        echo "Installing $1..."
        sudo pacman -S --noconfirm "$1"
    else
        echo "$1 is already installed."
    fi
}

if ! command -v paru &> /dev/null; then
    echo "Installing paru for AUR package management..."
    sudo pacman -S --needed base-devel git --noconfirm
    git clone https://aur.archlinux.org/paru.git
    cd paru || exit
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
else
    echo "Paru is already installed."
fi

dependencies=(
    "kvantum"
    "alacritty"
    "dunst"
    "fastfetch"
    "flameshot"
    "gtk3"
    "gtk4"
    "kitty"
    "nano"
    "vim"
    "neovim"
    "picom"
    "qt5-base"
    "qt6-base"
    "rofi"
    "wayland"
    "swappy"
    "swaklock"
    "waybar"
    "wlogout"
    "grim"
    "slurp"
    "swaybg"
    "wlr-randr"
    "xorg-xwayland"
    "wl-clipboard"
    "polkit"
    "sddm"
    "firefox"     
    "gimp"       
    "discord"   
    "telegram-desktop" 
)

for dep in "${dependencies[@]}"; do
    install_if_missing "$dep"
done

if ! paru -Q hyprland &> /dev/null; then
    echo "Installing Hyprland and wlroots from AUR..."
    paru -S --noconfirm hyprland wlroots
else
    echo "Hyprland and wlroots are already installed."
fi

echo "Cloning Hyprland configuration..."
git clone https://github.com/harilvfs/hyprland ~/.config/hyprland

echo "Moving files to ~/.config..."
cd ~/.config/hyprland || exit
mv * ~/.config/

echo "================================="
echo "    Hyperland installation is    "
echo "        successfully done!       "
echo "================================="

