#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

print_message() {
    local color="$1"
    local message="$2"
    printf "%b%s%b\n" "$color" "$message" "$ENDCOLOR"
}

confirm() {
    while true; do
        read -p "$(printf "%b%s%b" "$CYAN" "$1 [y/N]: " "$RC")" answer
        case ${answer,,} in
            y | yes) return 0 ;;
            n | no | "") return 1 ;;
            *) print_message "$YELLOW" "Please answer with y/yes or n/no." ;;
        esac
    done
}

print_message "$YELLOW" ":: Note: JetBrains Mono Nerd Font is required for proper Rofi display. Please install it before continuing."

install_rofi_arch() {
    if ! command -v rofi &> /dev/null; then
        print_message "$CYAN" "Rofi is not installed. :: Installing Rofi for Arch..."
        sudo pacman -S --needed --noconfirm rofi
    else
        print_message "$GREEN" ":: Rofi is already installed on Arch."
    fi
}

install_rofi_fedora() {
    if ! command -v rofi &> /dev/null; then
        print_message "$CYAN" "Rofi is not installed. :: Installing Rofi for Fedora..."
        sudo dnf install --assumeyes rofi
    else
        print_message "$GREEN" ":: Rofi is already installed on Fedora."
    fi
}

install_rofi_opensuse() {
    if ! command -v rofi &> /dev/null; then
        print_message "$CYAN" "Rofi is not installed. :: Installing Rofi for openSUSE..."
        sudo zypper install -y rofi
    else
        print_message "$GREEN" ":: Rofi is already installed on openSUSE."
    fi
}

setup_rofi() {
    if command -v pacman &> /dev/null; then
        install_rofi_arch
    elif command -v dnf &> /dev/null; then
        install_rofi_fedora
    elif command -v zypper &> /dev/null; then
        install_rofi_opensuse
    else
        print_message "$RED" "Unsupported distribution. Please install Rofi manually."
        exit 1
    fi

    ROFI_CONFIG_DIR="$HOME/.config/rofi"
    BACKUP_DIR="$HOME/.config/rofi_backup"

    if [ -d "$ROFI_CONFIG_DIR" ]; then
        print_message "$CYAN" ":: Rofi configuration directory exists. Backing up the current configuration..."

        if [ -d "$BACKUP_DIR" ]; then
            print_message "$YELLOW" ":: Backup already exists."
            if confirm "Overwrite the existing backup?"; then
                rm -rf "$BACKUP_DIR"
                mkdir -p "$BACKUP_DIR"
                mv "$ROFI_CONFIG_DIR"/* "$BACKUP_DIR"/
                print_message "$GREEN" ":: Existing Rofi configuration has been backed up to ~/.config/rofi_backup."
            else
                print_message "$GREEN" ":: Keeping the existing backup. Skipping backup process."
            fi
        else
            mkdir -p "$BACKUP_DIR"
            mv "$ROFI_CONFIG_DIR"/* "$BACKUP_DIR"/
            print_message "$GREEN" ":: Existing Rofi configuration backed up to ~/.config/rofi_backup."
        fi
    else
        mkdir -p "$ROFI_CONFIG_DIR"
    fi

    print_message "$CYAN" ":: Applying new Rofi configuration..."

    wget -q https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/rofi/config.rasi -O "$ROFI_CONFIG_DIR/config.rasi"

    mkdir -p "$ROFI_CONFIG_DIR/themes"
    wget -q https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/rofi/themes/nord.rasi -O "$ROFI_CONFIG_DIR/themes/nord.rasi"

    print_message "$GREEN" ":: Rofi configuration applied successfully!"
}

setup_rofi
