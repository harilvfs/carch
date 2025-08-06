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

install_rofi() {
    if ! command -v rofi &> /dev/null; then
        print_message "$CYAN" "Rofi is not installed. Installing Rofi..."
        case "$DISTRO" in
            "Arch") sudo pacman -S --needed --noconfirm rofi ;;
            "Fedora") sudo dnf install -y rofi ;;
            "openSUSE") sudo zypper install -y rofi ;;
            *)
                exit 1
                ;;
        esac
    else
        print_message "$GREEN" "Rofi is already installed."
    fi
}

setup_rofi_config() {
    ROFI_CONFIG_DIR="$HOME/.config/rofi"
    BACKUP_DIR="$HOME/.config/carch/backups"

    if [ -d "$ROFI_CONFIG_DIR" ]; then
        print_message "$CYAN" "Rofi configuration directory exists. Backing up the current configuration..."
        mkdir -p "$BACKUP_DIR"
        local backup_path="$BACKUP_DIR/rofi.bak.$RANDOM"
        mv "$ROFI_CONFIG_DIR" "$backup_path"
        print_message "$GREEN" "Existing Rofi configuration backed up to $backup_path."
    fi
    mkdir -p "$ROFI_CONFIG_DIR"

    print_message "$CYAN" "Applying new Rofi configuration..."

    wget -q https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/rofi/config.rasi -O "$ROFI_CONFIG_DIR/config.rasi"

    mkdir -p "$ROFI_CONFIG_DIR/themes"
    wget -q https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/rofi/themes/nord.rasi -O "$ROFI_CONFIG_DIR/themes/nord.rasi"

    print_message "$GREEN" "Rofi configuration applied successfully!"
}

main() {
    print_message "$YELLOW" "Note: JetBrains Mono Nerd Font is required for proper Rofi display. Please install it before continuing."
    install_rofi
    setup_rofi_config
}

main
