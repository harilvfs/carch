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

check_essential_dependencies() {
    local dependencies=("wget" "curl" "zellij")
    local missing=()

    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -ne 0 ]]; then
        print_message "$YELLOW" "Please wait, installing required dependencies..."

        case "$DISTRO" in
            "Arch") sudo pacman -S --noconfirm "${missing[@]}" > /dev/null 2>&1 ;;
            "Fedora") sudo dnf install -y "${missing[@]}" > /dev/null 2>&1 ;;
            "openSUSE") sudo zypper install -y "${missing[@]}" > /dev/null 2>&1 ;;
            *)
                exit 1
                ;;
        esac
    fi
}

backup_zellij_config() {
    local config_dir="$HOME/.config/zellij"
    local backup_dir_base="$HOME/.config/carch/backups"

    if [[ -d "$config_dir" ]]; then
        print_message "$YELLOW" "Existing zellij configuration detected."
        if confirm "Do you want to backup the existing configuration?"; then
            mkdir -p "$backup_dir_base"
            local backup_path="$backup_dir_base/zellij.bak.$RANDOM"
            mv "$config_dir" "$backup_path"
            print_message "$GREEN" "Backup created: $backup_path"
        else
            print_message "$RED" "Exiting to avoid overwriting existing config."
            exit 0
        fi
    fi
}

setup_zellij_config() {
    local config_dir="$HOME/.config/zellij"
    local base_url="https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/zellij"

    mkdir -p "$config_dir/layouts"

    print_message "$GREEN" "Downloading zellij configuration..."
    wget -O "$config_dir/config.kdl" "$base_url/config.kdl"
    wget -O "$config_dir/layouts/top-bar.kdl" "$base_url/layouts/top-bar.kdl"
}

main() {
    check_essential_dependencies
    backup_zellij_config
    setup_zellij_config
    print_message "$GREEN" "Zellij setup complete!"
}

main
