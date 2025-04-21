#!/usr/bin/env bash

# Quickly sets up the Dwm window manager with a single-click script, using my customized configuration.

clear

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
CYAN='\033[36m'
GREEN='\033[32m'
BLUE='\033[34m'
RESET="\033[0m"

print_message() {
    local color="$1"
    local message="$2"
    printf "%b%s%b\n" "$color" "$message" "$RC"
}

echo -e "${BLUE}"
if command -v figlet &>/dev/null; then
    figlet -f slant "Dwm"
else
    echo "========== Dwm Setup =========="
fi
echo -e "${RESET}"

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
    if command -v pacman &>/dev/null; then
        distro="arch"
        print_message "$GREEN" "Detected distribution: Arch Linux"
    elif command -v dnf &>/dev/null; then
        distro="fedora"
        print_message "$YELLOW" "Detected distribution: Fedora"
    else
        print_message "$RED" "Unsupported distribution. Exiting..."
        exit 1
    fi
}

install_packages() {
    if [ "$distro" == "arch" ]; then
        print_message "$CYAN" ":: Installing required packages using pacman..."
        sudo pacman -S --needed git base-devel libx11 libxinerama libxft ttf-cascadia-mono-nerd ttf-cascadia-code-nerd ttf-jetbrains-mono-nerd ttf-jetbrains-mono imlib2 libxcb git unzip lxappearance feh mate-polkit meson ninja xorg-xinit xorg-server network-manager-applet blueman pasystray bluez-utils thunar flameshot trash-cli tumbler gvfs-mtp fzf vim neovim slock || {
            print_message "$RED" "Failed to install some packages."
            exit 1
        }
    elif [ "$distro" == "fedora" ]; then
        print_message "$CYAN" ":: Installing required packages using dnf..."
        sudo dnf install -y git libX11-devel libXinerama-devel libXft-devel imlib2-devel libxcb-devel unzip lxappearance feh mate-polkit meson ninja-build gnome-keyring jetbrains-mono-fonts-all google-noto-color-emoji-fonts network-manager-applet blueman pasystray google-noto-emoji-fonts thunar flameshot trash-cli tumbler gvfs-mtp fzf vim neovim slock || {
            print_message "$RED" "Failed to install some packages."
            exit 1
        }
    fi
}

check_aur_helper() {
    if command -v paru &>/dev/null; then
        print_message "$GREEN" "AUR helper paru is already installed."
        aur_helper="paru"
        return 0
    elif command -v yay &>/dev/null; then
        print_message "$GREEN" "AUR helper yay is already installed."
        aur_helper="yay"
        return 0
    fi
    
    print_message "$CYAN" ":: No AUR helper found. Installing yay..."
    
    sudo pacman -S --needed --noconfirm git base-devel
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir" || exit 1
    
    if git clone https://aur.archlinux.org/yay.git; then
        cd yay || exit 1
        makepkg -si --noconfirm || { 
            print_message "$RED" "Failed to install yay."
            cd "$HOME" || exit
            rm -rf "$temp_dir"
            exit 1
        }
        cd "$HOME" || exit
        rm -rf "$temp_dir"
        aur_helper="yay"
        print_message "$GREEN" "Successfully installed yay as AUR helper."
        return 0
    else
        print_message "$RED" "Failed to clone yay repository."
        cd "$HOME" || exit
        rm -rf "$temp_dir"
        exit 1
    fi
}

install_dwm() {
    if [ -d "$HOME/dwm" ]; then
        if fzf_confirm "DWM directory already exists. Do you want to overwrite it?"; then
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
    if fzf_confirm "Do you want to install slstatus (recommended)?"; then
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
    if command -v dnf &>/dev/null; then
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
        check_aur_helper
        
        print_message "$CYAN" ":: Installing Picom with $aur_helper..."
        $aur_helper -S --noconfirm picom-ftlabs-git || { 
            print_message "$RED" "Failed to install Picom."
            print_message "$YELLOW" "Trying alternative installation method..."
            
            local temp_dir=$(mktemp -d)
            cd "$temp_dir" || exit 1
            git clone https://github.com/FT-Labs/picom.git
            cd picom || exit 1
            meson setup --buildtype=release build
            ninja -C build
            sudo ninja -C build install
            cd "$HOME" || exit
            rm -rf "$temp_dir"
        }
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
        if fzf_confirm "Existing picom.conf detected. Do you want to replace it?"; then
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
        if fzf_confirm "Wallpapers directory already exists. Do you want to overwrite?"; then
            rm -rf "$BG_DIR"
        else
            return
        fi
    fi
    
    git clone https://github.com/harilvfs/wallpapers "$BG_DIR" || exit 1
    print_message "$GREEN" "Wallpapers downloaded."
}

setup_xinitrc() {
    local XINITRC="$HOME/.xinitrc"
    
    if [ -f "$XINITRC" ]; then
        if fzf_confirm "Existing .xinitrc detected. Do you want to replace it?"; then
            mv "$XINITRC" "$XINITRC.bak"
        else
            return
        fi
    fi
    
    print_message "$CYAN" ":: Creating .xinitrc file for DWM..."
    cat > "$XINITRC" << 'EOF'
#!/bin/sh
exec dwm
EOF
    
    chmod +x "$XINITRC"
    print_message "$GREEN" ".xinitrc configured successfully!"
}

setup_tty_login() {
    if fzf_confirm "Do you want to use DWM from TTY using startx?"; then
        setup_xinitrc
        
        if fzf_confirm "Do you want to enable automatic login to TTY? (Not recommended for security reasons)"; then
            local username=$(whoami)
            print_message "$CYAN" ":: Setting up autologin for user: $username"
            
            sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
            
            sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf > /dev/null << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $username --noclear %I 38400 linux
EOF
            
            sudo systemctl daemon-reexec
            print_message "$GREEN" "Autologin configured for TTY1."
        fi
    fi
}

check_display_manager() {
    local dm_found=false
    local dm_name=""
    
    for dm in sddm gdm lightdm lxdm xdm slim; do
        if systemctl is-enabled $dm.service &>/dev/null; then
            dm_found=true
            dm_name=$dm
            break
        fi
    done
    
    if $dm_found; then
        print_message "$YELLOW" "Display manager $dm_name is detected."
        if fzf_confirm "When using DWM from TTY, a display manager is not needed. Do you want to remove $dm_name?"; then
            if [ "$distro" == "arch" ]; then
                sudo systemctl disable $dm_name.service
                sudo systemctl stop $dm_name.service
                sudo pacman -Rns $dm_name
            elif [ "$distro" == "fedora" ]; then
                sudo systemctl disable $dm_name.service
                sudo systemctl stop $dm_name.service
                sudo dnf remove -y $dm_name
            fi
            print_message "$GREEN" "Display manager $dm_name has been removed."
        fi
    else
        print_message "$GREEN" "No display manager detected. You can start DWM using 'startx' from TTY."
    fi
}

detect_distro
install_packages
install_dwm
install_slstatus
install_nerd_font
install_picom
configure_wallpapers
setup_tty_login
check_display_manager
print_message "$GREEN" "DWM setup completed successfully!"
print_message "$YELLOW" "Notice: I am not including dotfiles in this script to avoid conflicts and potential data loss. If you need dotfiles, check out my repo:"
print_message "$CYAN" "https://github.com/harilvfs/dwm/blob/main/config"
