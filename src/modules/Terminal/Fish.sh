#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

distro=""

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

detect_distro() {
    if command -v pacman &> /dev/null; then
        distro="arch"
    elif command -v dnf &> /dev/null; then
        distro="fedora"
    elif command -v zypper &> /dev/null; then
        distro="opensuse"
    else
        print_message "$RED" "Unsupported distribution!"
        exit 1
    fi
}

install_eza_manually() {
    print_message "$CYAN" "Installing eza manually for Fedora..."
    local tmp_dir
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir" || exit 1

    print_message "$CYAN" "Fetching latest eza release..."
    local latest_url
    latest_url=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep -o "https://github.com/eza-community/eza/releases/download/.*/eza_x86_64-unknown-linux-gnu.zip" | head -1)

    if [ -z "$latest_url" ]; then
        print_message "$YELLOW" "Could not determine latest version, using fallback..."
        latest_url="https://github.com/eza-community/eza/releases/download/v0.21.1/eza_x86_64-unknown-linux-gnu.zip"
    fi

    print_message "$CYAN" "Downloading eza from: $latest_url"
    if ! curl -L -o eza.zip "$latest_url"; then
        print_message "$RED" "Failed to download eza. Exiting..."
        cd "$HOME" || exit
        rm -rf "$tmp_dir"
        exit 1
    fi

    print_message "$CYAN" "Extracting eza..."
    unzip -q eza.zip
    print_message "$CYAN" "Installing eza to /usr/bin..."
    sudo cp eza /usr/bin/
    sudo chmod +x /usr/bin/eza

    cd "$HOME" || exit
    rm -rf "$tmp_dir"
    print_message "$GREEN" "eza installed successfully!"
}

install_fish_packages() {
    print_message "$CYAN" "Installing dependencies..."
    case "$distro" in
        arch)
            sudo pacman -S --noconfirm fish noto-fonts-emoji git eza trash-cli
            ;;
        fedora)
            sudo dnf install -y fish google-noto-color-emoji-fonts google-noto-emoji-fonts git trash-cli
            if ! command -v eza &> /dev/null; then
                install_eza_manually
            else
                print_message "$GREEN" "eza is already installed."
            fi
            ;;
        opensuse)
            sudo zypper install -y fish google-noto-fonts noto-coloremoji-fonts git eza trash-cli
            ;;
        *)
            print_message "$RED" "Unsupported distro: $distro"
            exit 1
            ;;
    esac
}

install_zoxide() {
    if command -v zoxide &> /dev/null; then
        print_message "$GREEN" "zoxide is already installed."
        return
    fi
    print_message "$CYAN" "Installing zoxide..."
    case "$distro" in
        arch)
            sudo pacman -S --noconfirm zoxide
            ;;
        fedora)
            sudo dnf install -y zoxide
            ;;
        opensuse)
            sudo zypper install -y zoxide
            ;;
        *)
            print_message "$RED" "Unsupported distro for zoxide: $distro"
            ;;
    esac
}

main() {
    detect_distro
    install_fish_packages

    local FISH_CONFIG="$HOME/.config/fish"
    local backup_dir="$HOME/.config/carch/backups"
    if [[ -d "$FISH_CONFIG" ]]; then
        if confirm "Existing Fish config found. Do you want to back it up?"; then
            mkdir -p "$backup_dir"
            local BACKUP_PATH="$backup_dir/fish.bak"
            if [ -d "$BACKUP_PATH" ]; then
                rm -rf "$BACKUP_PATH"
            fi
            mv "$FISH_CONFIG" "$BACKUP_PATH"
            print_message "$GREEN" "Backup created at $BACKUP_PATH"
        fi
    fi

    print_message "$CYAN" "Cloning Fish configuration..."
    git clone --depth=1 https://github.com/harilvfs/dwm "$HOME/dwm"
    if [[ -d "$HOME/dwm/config/fish" ]]; then
        print_message "$CYAN" "Applying Fish configuration..."
        mkdir -p "$FISH_CONFIG"
        cp -r "$HOME/dwm/config/fish/"* "$FISH_CONFIG/"
        print_message "$GREEN" "Fish configuration applied!"
        rm -rf "$HOME/dwm"
    else
        print_message "$RED" "Failed to apply Fish configuration!"
        rm -rf "$HOME/dwm"
        exit 1
    fi

    local CURRENT_SHELL
    CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
    local FISH_PATH
    FISH_PATH=$(command -v fish)

    if [[ "$CURRENT_SHELL" == "$FISH_PATH" ]]; then
        print_message "$GREEN" "Fish is already your default shell."
    else
        if confirm "Fish is not your default shell. Set it as default?"; then
            print_message "$CYAN" "Setting Fish as your default shell..."
            chsh -s "$FISH_PATH"
            print_message "$GREEN" "Fish is now set as your default shell!"
        fi
    fi

    install_zoxide
    print_message "$GREEN" "Zoxide initialized in Fish!"
    print_message "$CYAN" "Fish setup complete! Restart your shell to apply changes."
}

main
