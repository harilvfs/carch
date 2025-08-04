#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

print_message() {
    local color="$1"
    shift
    echo -e "${color}$*${NC}"
}

install_dunst() {
    if ! command -v dunst &> /dev/null; then
        print_message "${TEAL}" "Dunst not found. Installing..."
        case "$DISTRO" in
            "Arch") sudo pacman -Sy --noconfirm dunst ;;
            "Fedora") sudo dnf install -y dunst ;;
            "openSUSE") sudo zypper install -y dunst ;;
            *)
                exit 1
                ;;
        esac
    else
        print_message "$GREEN" "Dunst is already installed."
    fi
}

install_papirus_icon_theme() {
    print_message "${TEAL}" "Installing papirus-icon-theme..."
    case "$DISTRO" in
        "Arch") sudo pacman -Sy --noconfirm papirus-icon-theme ;;
        "Fedora") sudo dnf install -y papirus-icon-theme ;;
        "openSUSE") sudo zypper install -y papirus-icon-theme ;;
    esac
}

backup_dunst_config() {
    local dunst_dir="$HOME/.config/dunst"
    local backup_dir="$HOME/.config/carch/backups"

    if [[ -d "$dunst_dir" ]]; then
        print_message "${TEAL}" "Backing up existing Dunst directory..."
        mkdir -p "$backup_dir"
        mv "$dunst_dir" "$backup_dir/dunst.bak"
        print_message "$GREEN" "Backup created: $backup_dir/dunst.bak"
    fi
}

download_dunst_config() {
    local dunst_dir="$HOME/.config/dunst"
    local dunst_file="$dunst_dir/dunstrc"
    local dunst_url="https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/dunst/dunstrc"

    mkdir -p "$dunst_dir"
    print_message "$GREEN" "Created ~/.config/dunst directory."

    print_message "${TEAL}" "Downloading Dunstrc..."

    local spin='-\|/'
    local i=0

    (while true; do
        printf "\r[%c] Downloading..." "${spin:i++%${#spin}}"
        sleep 0.1
    done) &
    local spin_pid=$!

    if curl -fsSL "$dunst_url" -o "$dunst_file"; then
        kill $spin_pid
        printf "\r[done] Download complete!      \n"
        print_message "$GREEN" "Dunstrc successfully downloaded to $dunst_file"
    else
        kill $spin_pid
        printf "\r[fail] Download failed!      \n"
        print_message "$RED" "Failed to download Dunstrc. Exiting..."
        exit 1
    fi
}

main() {
    clear
    install_dunst
    install_papirus_icon_theme
    backup_dunst_config
    download_dunst_config
    print_message "$GREEN" "Dunst setup completed successfully!"
}

main
