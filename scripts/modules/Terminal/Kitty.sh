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

setup_kitty() {
    if ! command -v kitty &> /dev/null; then
        print_message "$CYAN" "Kitty is not installed. :: Installing..."

        case "$DISTRO" in
            "Arch") sudo pacman -S --needed --noconfirm kitty ;;
            "Fedora") sudo dnf install kitty -y ;;
            "openSUSE") sudo zypper install -y kitty ;;
            *)
                exit 1
                ;;
        esac
    else
        print_message "$GREEN" "Kitty is already installed."
    fi

    local CONFIG_DIR="$HOME/.config/kitty"
    local BACKUP_DIR_BASE="$HOME/.config/carch/backups"

    if [ -d "$CONFIG_DIR" ]; then
        print_message "$CYAN" ":: Existing Kitty configuration detected."
        if confirm "Do you want to backup the existing configuration?"; then
            mkdir -p "$BACKUP_DIR_BASE"
            local backup_path="$BACKUP_DIR_BASE/kitty.bak.$RANDOM"
            mv "$CONFIG_DIR" "$backup_path"
            print_message "$GREEN" ":: Existing Kitty configuration backed up to $backup_path."
        else
            print_message "$CYAN" ":: Skipping backup. Your existing configuration will be overwritten."
        fi
    fi

    mkdir -p "$CONFIG_DIR"

    print_message "$CYAN" ":: Downloading Kitty configuration files..."

    wget -q -P "$CONFIG_DIR" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/kitty/kitty.conf"
    wget -q -P "$CONFIG_DIR" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/kitty/theme.conf"
    wget -q -P "$CONFIG_DIR" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/kitty/userprefs.conf"
    wget -q -P "$CONFIG_DIR" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/kitty/tabs.conf"
    print_message "$GREEN" "Kitty setup completed!"
}

install_font() {
    if confirm "Do you want to install JetBrains Mono Nerd Font?"; then
        case "$DISTRO" in
            "Arch")
                print_message "$CYAN" "Installing JetBrains Mono Nerd Font on Arch-based systems..."
                sudo pacman -S --needed ttf-jetbrains-mono-nerd ttf-jetbrains-mono
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
        print_message "$CYAN" "Skipping font installation."
    fi
}

main() {
    setup_kitty
    install_font
}

main
