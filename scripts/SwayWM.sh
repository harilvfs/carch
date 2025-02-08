#!/bin/bash

clear

GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m"

print_message() {
    echo -e "${1}${2}${NC}"
}

command_exists() {
    command -v "$1" &>/dev/null
}

install_aur_helper() {
    if ! command_exists yay && ! command_exists paru; then
        print_message $GREEN "Installing yay as AUR helper..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay || exit
        makepkg -si --noconfirm
        cd ..
        rm -rf /tmp/yay
    else
        print_message $YELLOW "AUR helper (yay or paru) already installed."
    fi
}

install_packages() {
    local packages=("$@")
    local missing_pkgs=()

    for pkg in "${packages[@]}"; do
        if ! pacman -Qq "$pkg" &>/dev/null; then
            missing_pkgs+=("$pkg")
        fi
    done

    if [ ${#missing_pkgs[@]} -ne 0 ]; then
        print_message $GREEN "Installing missing packages: ${missing_pkgs[*]}"
        sudo pacman -S "${missing_pkgs[@]}"
    else
        print_message $YELLOW "All required packages are already installed."
    fi
}

install_aur_packages() {
    local packages=("$@")
    local missing_pkgs=()

    for pkg in "${packages[@]}"; do
        if ! yay -Qq "$pkg" &>/dev/null; then
            missing_pkgs+=("$pkg")
        fi
    done

    if [ ${#missing_pkgs[@]} -ne 0 ]; then
        print_message $GREEN "Installing missing AUR packages: ${missing_pkgs[*]}"
        yay -S "${missing_pkgs[@]}"
    else
        print_message $YELLOW "All required AUR packages are already installed."
    fi
}

manage_dotfiles() {
    local repo_url="$1"
    local repo_dir="$2"
    local backup_dir="$3"

    if [ -d "$repo_dir" ]; then
        if gum confirm "Existing dotfiles detected. Overwrite?"; then
            rm -rf "$repo_dir"
        else
            print_message $YELLOW "Skipping dotfiles cloning."
            return
        fi
    fi

    git clone "$repo_url" "$repo_dir"

    mkdir -p "$backup_dir"

    for config in "$repo_dir"/*; do
        local config_name=$(basename "$config")
        if [ -e "$HOME/.config/$config_name" ]; then
            if gum confirm "Existing config $config_name detected. Backup?"; then
                mv "$HOME/.config/$config_name" "$backup_dir/"
            fi
        fi
        cp -r "$config" "$HOME/.config/"
    done

    cp -r "$repo_dir"/.azotebg "$HOME/"
    cp -r "$repo_dir"/.gtkrc-2.0 "$HOME/"
    cp -r "$repo_dir"/.profile "$HOME/"

    if [ -d "$repo_dir/usr/share" ]; then
        print_message $GREEN "Copying system-wide files..."
        sudo cp -r "$repo_dir/usr/share" /usr/
    fi
}

manage_themes_icons() {
    local repo_url="$1"
    local target_dir="$2"
    local repo_name=$(basename "$repo_url" .git)

    if [ -d "$target_dir/$repo_name" ]; then
        if gum confirm "Existing $repo_name detected. Overwrite?"; then
            rm -rf "$target_dir/$repo_name"
        else
            print_message $YELLOW "Skipping $repo_name cloning."
            return
        fi
    fi

    git clone "$repo_url" "$target_dir/$repo_name"
}

print_message $BLUE "$(figlet -f slant "SwayWM")"

print_message $BLUE "If the setup fails, please manually use the dotfiles from:
https://github.com/harilvfs/swaydotfiles"

if ! gum confirm "Continue with Sway setup?"; then
    print_message $RED "Setup aborted by the user."
    exit 1
fi

if [ -f /etc/fedora-release ]; then
    print_message $RED "Sway setup for Fedora is not finalized due to missing dependencies and runtime errors. Exiting."
    exit 1
elif [ -f /etc/arch-release ]; then
    print_message $GREEN "Arch Linux detected. Proceeding with setup..."
else
    print_message $RED "Unsupported distribution. Exiting."
    exit 1
fi

REQUIRED_PKGS=(git base-devel make less)
install_packages "${REQUIRED_PKGS[@]}"

install_aur_helper

PACMAN_PKGS=(fastfetch fish foot nwg-drawer swappy swaylock waybar pango cairo gdk-pixbuf2 json-c scdoc meson ninja pcre2 gtk-layer-shell jsoncpp libsigc++ libdbusmenu-gtk3 libxkbcommon fmt spdlog glibmm gtkmm3 alsa-utils pulseaudio libnl iw wob swaybg swayidle fuzzel otf-font-awesome ttf-jetbrains-mono ttf-nerd-fonts-symbols ttf-ubuntu-font-family wl-clipboard grim slurp mako blueberry pamixer pavucontrol gnome-keyring polkit-gnome cliphist wl-clipboard autotiling gtklock swayidle xdg-desktop-portal xdg-desktop-portal-wlr xorg-xhost sddm kvantum qt5-wayland qt6-wayland dex wf-recorder nwg-hello blueman bluez bluez-libs bluez-qt bluez-qt5 bluez-tools bluez-utils alacritty kitty)
install_packages "${PACMAN_PKGS[@]}"

YAY_PKGS=(swayfx waybar-module-pacman-updates-git wlroots-git)
install_aur_packages "${YAY_PKGS[@]}"

DOTFILES_REPO="https://github.com/harilvfs/swaydotfiles"
DOTFILES_DIR="$HOME/swaydotfiles"
BACKUP_DIR="$HOME/.swaydotfiles/backup"
manage_dotfiles "$DOTFILES_REPO" "$DOTFILES_DIR" "$BACKUP_DIR"

THEME_REPO="https://github.com/harilvfs/themes"
ICON_REPO="https://github.com/harilvfs/icons"
THEME_DIR="$HOME/.themes"
ICON_DIR="$HOME/.icons"
manage_themes_icons "$THEME_REPO" "$THEME_DIR"
manage_themes_icons "$ICON_REPO" "$ICON_DIR"

if gum confirm "Do you want additional wallpapers?"; then
    WALLPAPER_REPO="https://github.com/harilvfs/wallpapers"
    WALLPAPER_DIR="$HOME/Pictures/wallpapers"
    manage_themes_icons "$WALLPAPER_REPO" "$WALLPAPER_DIR"
    print_message $GREEN "Wallpapers are located in $WALLPAPER_DIR. Apply them using azote."
fi

is_sddm_installed() {
    if command -v sddm &> /dev/null; then
        return 0 
    else
        return 1
    fi
}

install_sddm() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case $ID in
            arch*)
                sudo pacman -S --noconfirm sddm
                ;;
            fedora*)
                sudo dnf install -y sddm
                ;;
            *)
                echo "Unsupported distribution."
                exit 1
                ;;
        esac
    fi
}

apply_sddm_theme() {
    theme_dir="/usr/share/sddm/themes/catppuccin-mocha"

if [ -d "$theme_dir" ]; then
    print_message "$YELLOW" "$theme_dir already exists."
    if gum confirm "Do you want to remove the existing theme and continue?"; then
        sudo rm -rf "$theme_dir"
        print_message "$GREEN" "$theme_dir removed."
    else
        print_message "$RED" "$theme_dir not removed, exiting."
        exit 1
    fi
fi

    temp_dir=$(mktemp -d)
    echo "Downloading Catppuccin Mocha theme..."
    wget https://github.com/catppuccin/sddm/releases/download/v1.0.0/catppuccin-mocha.zip -O "$temp_dir/catppuccin-mocha.zip"
    
    unzip "$temp_dir/catppuccin-mocha.zip" -d "$temp_dir"
    
    cd "$temp_dir/catppuccin-mocha" || exit 
    
    echo "Copying the theme to /usr/share/sddm/themes..."
    sudo cp -r "$temp_dir/catppuccin-mocha" /usr/share/sddm/themes/
    
    rm -rf "$temp_dir"
}

configure_sddm_theme() {
    echo "Configuring sddm.conf to use the Catppuccin Mocha theme..."
    
    if [ ! -f /etc/sddm.conf ]; then
        sudo touch /etc/sddm.conf
    fi

    if ! grep -q "\[Theme\]" /etc/sddm.conf; then
        echo "[Theme]" | sudo tee -a /etc/sddm.conf > /dev/null
    fi
    
    sudo sed -i '/\[Theme\]/a Current=catppuccin-mocha' /etc/sddm.conf
}

enable_start_sddm() {
    echo "Checking for existing display managers..."

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
    fi

    if command -v gdm &> /dev/null; then
        echo "GDM detected. Removing GDM..."
        sudo systemctl stop gdm
        sudo systemctl disable gdm --now
        if [[ "$ID" == "arch" || "$ID_LIKE" == *"arch"* ]]; then
            sudo pacman -Rns --noconfirm gdm
        elif [[ "$ID" == "fedora" ]]; then
            sudo dnf remove -y gdm
        fi
    fi

    if command -v lightdm &> /dev/null; then
        echo "LightDM detected. Removing LightDM..."
        sudo systemctl stop lightdm
        sudo systemctl disable lightdm --now
        if [[ "$ID" == "arch" || "$ID_LIKE" == *"arch"* ]]; then
            sudo pacman -Rns --noconfirm lightdm
        elif [[ "$ID" == "fedora" ]]; then
            sudo dnf remove -y lightdm
        fi
    fi

    echo "Enabling and starting the sddm service..."
    sudo systemctl enable sddm --now
}

if ! is_sddm_installed; then
    install_sddm
else
    echo "Sddm is already installed, skipping installation."
fi

apply_sddm_theme

configure_sddm_theme

enable_start_sddm

echo "Sddm theme applied, service started, and configuration updated successfully!"

print_message $BLUE "Default keybindings: Super+Enter (Terminal), Super+D (App Launcher)"
print_message $GREEN "SwayWM setup complete!"

