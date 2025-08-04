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

install_ghostty() {
    if ! command -v ghostty &> /dev/null; then
        print_message "$CYAN" "Ghostty is not installed. :: Installing..."

        case "$DISTRO" in
            "Arch") sudo pacman -S --needed ghostty ;;
            "Fedora")
                sudo dnf copr enable pgdev/ghostty -y
                sudo dnf install ghostty -y
                ;;
            "openSUSE") sudo zypper install -y ghostty ;;
            *)
                exit 1
                ;;
        esac
    else
        print_message "$GREEN" "Ghostty is already installed."
    fi
}

install_fonts() {
    if confirm "Do you want to install JetBrains Mono Nerd Font?"; then
        case "$DISTRO" in
            "Arch")
                sudo pacman -S --needed ttf-jetbrains-mono-nerd
                ;;
            "Fedora")
                sudo dnf install -y jetbrains-mono-fonts-all
                ;;
            "openSUSE")
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
    local CONFIG_DIR="$HOME/.config/ghostty"
    local BACKUP_DIR_BASE="$HOME/.config/carch/backups"
    local backup_path=""

    if [ -d "$CONFIG_DIR" ]; then
        print_message "$CYAN" ":: Existing Ghostty configuration detected."

        if confirm "Do you want to backup the existing configuration?"; then
            mkdir -p "$BACKUP_DIR_BASE"
            backup_path="$BACKUP_DIR_BASE/ghostty.bak.$RANDOM"
            mv "$CONFIG_DIR" "$backup_path"
            mkdir -p "$CONFIG_DIR"
        else
            print_message "$RED" "Exiting to avoid overwriting existing config."
            exit 0
        fi
    else
        print_message "$GREEN" "No existing Ghostty configuration found. Creating directory..."
        mkdir -p "$CONFIG_DIR"
    fi

    print_message "$CYAN" ":: Downloading Ghostty configuration..."

    wget -q -O "$CONFIG_DIR/config" "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/ghostty/config"

    print_message "$GREEN" "Ghostty configuration downloaded successfully!"
    print_message "$CYAN" "Note: The default theme is set to 'catppuccin-mocha'. You can change this in the config file."
    print_message "$GREEN" "Ghostty setup completed!"
    if [ -n "$backup_path" ]; then
        print_message "$GREEN" "Check your backup directory for previous configs at $backup_path."
    fi
}

main() {
    print_message "$YELLOW" "NOTE: This Ghostty configuration uses JetBrains Mono Nerd Font by default."
    print_message "$YELLOW" "You can change themes and other settings in ~/.config/ghostty/config"
    print_message "$YELLOW" "For more configuration options, check the Ghostty docs at: https://ghostty.org/docs"
    echo

    install_ghostty
    install_fonts
    setup_config
}

main
