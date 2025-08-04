#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

print_message() {
    local color="$1"
    shift
    echo -e "${color}$*${NC}"
}

confirm() {
    while true; do
        read -p "$(printf "%b%s%b" "$CYAN" "$1 [y/N]: " "$NC")" answer
        case ${answer,,} in
            y | yes) return 0 ;;
            n | no | "") return 1 ;;
            *) print_message "$YELLOW" "Please answer with y/yes or n/no." ;;
        esac
    done
}

install_foot() {
    if ! command -v foot &> /dev/null; then
        print_message "$CYAN" "Foot is not installed. :: Installing..."

        case "$DISTRO" in
            "Arch") sudo pacman -S --needed foot ;;
            "Fedora")
                print_message "$CYAN" "Installing Foot on Fedora..."
                sudo dnf install foot -y
                ;;
            "openSUSE")
                print_message "$CYAN" "Installing Foot on openSuse..."
                sudo zypper install -y foot
                ;;
            *)
                exit 1
                ;;
        esac
    else
        print_message "$GREEN" "Foot is already installed."
    fi
}

install_fonts() {
    if confirm "Do you want to install JetBrains Mono Nerd Font?"; then
        case "$DISTRO" in
            "Arch")
                print_message "$CYAN" "Installing JetBrains Mono Nerd Font on Arch-based systems..."
                sudo pacman -S --needed ttf-jetbrains-mono-nerd
                ;;
            "Fedora")
                print_message "$CYAN" "Installing JetBrains Mono Nerd Font on Fedora..."
                sudo dnf install -y jetbrains-mono-fonts-all
                ;;
            "openSUSE")
                print_message "$CYAN" "Installing JetBrains Mono Font on openSUSE..."
                sudo zypper install -y jetbrains-mono-fonts
                ;;
            *)
                exit 1
                ;;
        esac
    else
        print_message "$CYAN" "Skipping font installation. Make sure to install JetBrains Mono Nerd Font manually for proper rendering."
    fi
}

setup_config() {
    local CONFIG_DIR="$HOME/.config/foot"
    local BACKUP_DIR_BASE="$HOME/.config/carch/backups"
    local backup_path=""

    if [ -d "$CONFIG_DIR" ]; then
        print_message "$CYAN" ":: Existing Foot configuration detected."

        if confirm "Do you want to backup the existing configuration?"; then
            mkdir -p "$BACKUP_DIR_BASE"
            backup_path="$BACKUP_DIR_BASE/foot.bak.$RANDOM"
            mv "$CONFIG_DIR" "$backup_path"
            mkdir -p "$CONFIG_DIR"
        else
            print_message "$RED" "Exiting to avoid overwriting existing config."
            exit 0
        fi
    else
        print_message "$GREEN" "No existing Foot configuration found. Creating directory..."
        mkdir -p "$CONFIG_DIR"
    fi

    print_message "$CYAN" ":: Downloading Foot configuration..."

    wget -q -O "$CONFIG_DIR/foot.ini" "https://raw.githubusercontent.com/harilvfs/swaydotfiles/refs/heads/main/foot/foot.ini"

    print_message "$GREEN" "Foot configuration downloaded successfully!"
    print_message "$GREEN" "Foot setup completed!"
    if [ -n "$backup_path" ]; then
        print_message "$GREEN" "Check your backup directory for previous configs at $backup_path."
    fi
}

main() {
    print_message "$YELLOW" "NOTE: This foot configuration uses Fish shell by default."
    print_message "$YELLOW" "If you're using Bash or Zsh, make sure to change it in ~/.config/foot/foot.ini"
    print_message "$YELLOW" "Also, JetBrains Mono Nerd Font is required for this configuration."
    echo

    install_foot
    install_fonts
    setup_config
}

main
