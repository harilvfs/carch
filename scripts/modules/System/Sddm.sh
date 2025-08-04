#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

print_message() {
    local color="$1"
    local message="$2"
    printf "%b:: %s%b\n" "$color" "$message" "$NC"
}

confirm() {
    while true; do
        read -p "$(printf "%b:: %s%b" "$CYAN" "$1 [y/N]: " "$NC")" answer
        case ${answer,,} in
            y | yes) return 0 ;;
            n | no | "") return 1 ;;
            *) print_message "$YELLOW" "Please answer with y/yes or n/no." ;;
        esac
    done
}

print_banner() {
    print_message "$GREEN" "Catppuccin SDDM Theme"
    print_message "$GREEN" "https://github.com/catppuccin/sddm"
}

disable_other_dms() {
    print_message "$GREEN" "Disabling any other active display manager..."
    local dms=("gdm" "lightdm" "lxdm" "xdm" "greetd")
    for dm in "${dms[@]}"; do
        if systemctl is-enabled "$dm" &> /dev/null; then
            print_message "$RED" "Disabling $dm..."
            sudo systemctl disable "$dm" --now || print_message "$RED" "Failed to disable $dm. Continuing..."
        fi
    done
}

enable_sddm() {
    print_message "$GREEN" "Enabling SDDM..."
    if ! sudo systemctl enable sddm --now; then
        print_message "$RED" "Failed to enable SDDM. Exiting..."
        exit 1
    fi
}

install_sddm() {
    if ! command -v sddm &> /dev/null; then
        print_message "$GREEN" "Installing SDDM..."

        case "$DISTRO" in
            "Arch") sudo pacman -S --noconfirm sddm ;;
            "Fedora") sudo dnf install -y sddm ;;
            "openSUSE") sudo zypper install -y sddm ;;
            *)
                exit 1
                ;;
        esac
    else
        print_message "$GREEN" "SDDM is already installed."
    fi
}

install_theme() {
    local theme_dir="/usr/share/sddm/themes/"
    local theme_url="https://github.com/catppuccin/sddm/releases/download/v1.0.0/catppuccin-mocha.zip"

    if [ -d "$theme_dir/catppuccin-mocha" ]; then
        print_message "$RED" "Catppuccin theme already exists."
        if confirm "Do you want to remove the existing theme and install a new one?"; then
            print_message "$GREEN" "Removing the existing theme..."
            sudo rm -rf "$theme_dir/catppuccin-mocha"
        else
            print_message "$RED" "Keeping the existing theme. Exiting..."
            exit 1
        fi
    fi
    print_message "$GREEN" "Downloading Catppuccin SDDM theme..."
    sudo mkdir -p "$theme_dir"
    if ! sudo wget -O /tmp/catppuccin-mocha.zip "$theme_url"; then
        print_message "$RED" "Failed to download the theme. Exiting..."
        exit 1
    fi
    if ! sudo unzip -o /tmp/catppuccin-mocha.zip -d "$theme_dir"; then
        print_message "$RED" "Failed to unzip the theme. Exiting..."
        exit 1
    fi
    sudo rm /tmp/catppuccin-mocha.zip
    print_message "$GREEN" "Catppuccin SDDM theme installed."
}

set_theme() {
    print_message "$GREEN" "Setting Catppuccin as the SDDM theme..."
    sudo bash -c 'cat > /etc/sddm.conf <<EOF
[Theme]
Current=catppuccin-mocha
# [Autologin]
# User=username
# Session=dwm,hyprland or others
#
EOF'
}

main() {
    print_banner
    print_message "$GREEN" "Proceeding with installation..."
    install_sddm
    install_theme
    set_theme
    disable_other_dms
    enable_sddm

    print_message "$GREEN" "Setup complete. Please reboot your system to see the changes."
}

main
