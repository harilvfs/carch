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

installAlacritty() {
    if command -v alacritty &> /dev/null; then
        print_message "$GREEN" "Alacritty is already installed."
        return
    fi

    print_message "$YELLOW" "Alacritty is not installed. Installing now..."

    case "$DISTRO" in
        "Arch") sudo pacman -S alacritty --noconfirm ;;
        "Fedora") sudo dnf install alacritty -y ;;
        "openSUSE") sudo zypper install -y alacritty ;;
        *)
            exit 1
            ;;
    esac

    print_message "$GREEN" "Alacritty has been installed."
}

setupAlacrittyConfig() {
    local alacritty_config_dir="$HOME/.config/alacritty"
    local backup_dir="$HOME/.config/carch/backups"

    print_message "$CYAN" ":: Setting up Alacritty configuration..."

    if [ -d "$alacritty_config_dir" ]; then
        print_message "$YELLOW" ":: Existing Alacritty configuration detected."
        if confirm "Do you want to backup the existing configuration?"; then
            mkdir -p "$backup_dir"
            local backup_path="$backup_dir/alacritty.bak.$RANDOM"
            mv "$alacritty_config_dir" "$backup_path"
            print_message "$GREEN" ":: Existing Alacritty configuration backed up to $backup_path."
        else
            print_message "$CYAN" ":: Skipping backup. Your existing configuration will be overwritten."
        fi
    fi

    mkdir -p "$alacritty_config_dir"

    base_url="https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/alacritty"
    for file in alacritty.toml keybinds.toml nordic.toml catppuccin-mocha.toml; do
        curl -sSLo "$alacritty_config_dir/$file" "$base_url/$file"
    done

    print_message "$CYAN" ":: Running 'alacritty migrate' to update the config..."
    (cd "$alacritty_config_dir" && alacritty migrate)

    print_message "$GREEN" ":: Alacritty configuration files copied and migrated."
}

main() {
    installAlacritty
    setupAlacrittyConfig
    print_message "$GREEN" ":: Alacritty setup complete."
}

main
