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
        read -rp "$(printf "%b:: %s%b" "$CYAN" "$1 [y/N]: " "$NC")" answer
        case "${answer,,}" in
            y | yes) return 0 ;;
            n | no | "") return 1 ;;
            *) print_message "$YELLOW" "Please answer with y/yes or n/no." ;;
        esac
    done
}

install_helix() {
    print_message "$CYAN" "Installing Helix editor..."
    case "$DISTRO" in
        "Arch") sudo pacman -S --noconfirm helix noto-fonts-emoji git ;;
        "Fedora") sudo dnf install -y helix google-noto-color-emoji-fonts google-noto-emoji-fonts git ;;
        "openSUSE") sudo zypper install -y helix google-noto-fonts noto-coloremoji-fonts git ;;
        *)
            exit 1
            ;;
    esac
}

setup_config() {
    HELIX_CONFIG="$HOME/.config/helix"
    if [[ -d "$HELIX_CONFIG" ]]; then
        if confirm "Existing Helix config found. Do you want to back it up?"; then
            BACKUP_DIR="$HOME/.config/carch/backups"
            mkdir -p "$BACKUP_DIR"
            BACKUP_PATH="$BACKUP_DIR/helix.bak"
            mv "$HELIX_CONFIG" "$BACKUP_PATH"
            print_message "$GREEN" "Backup created at $BACKUP_PATH"
        fi
    fi

    if [[ -d "$HOME/dwm" ]]; then
        print_message "$YELLOW" "Removing existing dwm directory..."
        rm -rf "$HOME/dwm"
    fi

    print_message "$CYAN" "Cloning Helix configuration..."
    git clone --depth=1 https://github.com/harilvfs/dwm "$HOME/dwm"

    if [[ -d "$HOME/dwm/config/helix" ]]; then
        print_message "$CYAN" "Applying Helix configuration..."
        mkdir -p "$HELIX_CONFIG"
        cp -r "$HOME/dwm/config/helix/"* "$HELIX_CONFIG/"
        print_message "$GREEN" "Helix configuration applied!"
        rm -rf "$HOME/dwm"
    else
        print_message "$RED" "Failed to apply Helix configuration!"
        rm -rf "$HOME/dwm"
        exit 1
    fi
}

main() {
    install_helix
    setup_config
    print_message "$CYAN" "Helix setup complete! Restart your editor to apply changes."
}

main
