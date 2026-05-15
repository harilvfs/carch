#!/usr/bin/env bash

# Author: Srinath10X (https://github.com/Srinath10X/termux-setup)

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

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

check_termux() {
    if [ -z "$TERMUX_VERSION" ] && [ ! -d "/data/data/com.termux" ] && [ "$(uname -o 2> /dev/null)" != "Android" ]; then
        print_message "$RED" "This script is for Termux only."
        exit 1
    fi
}

setup_storage() {
    print_message "$CYAN" "Setting up Termux storage access..."
    termux-setup-storage
}

install_packages() {
    print_message "$CYAN" "Updating packages and installing dependencies..."
    pkg update -y && pkg install -y git zsh curl eza gh neovim
}

setup_termux_config() {
    print_message "$CYAN" "Cloning Termux configuration..."
    git clone https://github.com/harilvfs/termux-setup.git "$HOME/termux-setup" --depth 1

    if [ -d "$HOME/.termux" ]; then
        print_message "$YELLOW" "Existing .termux found, backing up to .termux.backup..."
        mv "$HOME/.termux" "$HOME/.termux.backup"
    fi

    cp -R "$HOME/termux-setup/.termux" "$HOME/.termux"
    print_message "$GREEN" "Termux configuration applied."
}

setup_oh_my_zsh() {
    print_message "$CYAN" "Installing oh-my-zsh..."
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" --depth 1

    if [ -f "$HOME/.zshrc" ]; then
        print_message "$YELLOW" "Existing .zshrc found, backing up to .zshrc.backup..."
        mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
    fi

    print_message "$CYAN" "Downloading .zshrc..."
    curl -fsSL "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/termux/.zshrc" -o "$HOME/.zshrc"

    print_message "$CYAN" "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh-syntax-highlighting" --depth 1

    print_message "$CYAN" "Changing default shell to zsh..."
    chsh -s zsh
    print_message "$GREEN" "oh-my-zsh setup complete."
}

remove_login_message() {
    echo -n > "$PREFIX/etc/motd"
    print_message "$GREEN" "Removed login screen message."
}

install_pfetch() {
    print_message "$CYAN" "Installing pfetch..."
    curl -sSL https://github.com/dylanaraps/pfetch/raw/master/pfetch -o "$PREFIX/bin/pfetch" && chmod +x "$PREFIX/bin/pfetch"
    print_message "$GREEN" "pfetch installed."
}

main() {
    clear
    check_termux
    print_message "$CYAN" "Starting Termux setup..."
    setup_storage
    install_packages
    setup_termux_config
    setup_oh_my_zsh
    termux-reload-settings
    remove_login_message
    install_pfetch
    print_message "$TEAL" "Setup completed! Please restart Termux to apply all changes."
}

main
