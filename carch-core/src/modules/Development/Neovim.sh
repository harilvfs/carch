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

install_dependencies() {
    print_message "$GREEN" "Installing required dependencies..."

    case "$DISTRO" in
        "Arch")
            sudo pacman -S --needed --noconfirm ripgrep neovim fzf python-virtualenv luarocks go npm shellcheck \
                xclip wl-clipboard lua-language-server shfmt python3 meson ninja \
                make gcc ttf-jetbrains-mono ttf-jetbrains-mono-nerd git tree-sitter-cli
            ;;
        "Fedora")
            sudo dnf install -y ripgrep neovim fzf python3-virtualenv luarocks go nodejs shellcheck xclip \
                wl-clipboard lua-language-server shfmt python3 meson ninja-build tree-sitter-cli \
                make gcc jetbrains-mono-fonts-all jetbrains-mono-fonts jetbrains-mono-nl-fonts git
            ;;
        "openSUSE")
            sudo zypper install -y ripgrep neovim fzf python313-virtualenv lua53-luarocks go nodejs ShellCheck xclip \
                wl-clipboard lua-language-server shfmt python313 meson ninja \
                make gcc jetbrains-mono-fonts git tree-sitter
            ;;
        *)
            print_message "$RED" "Unsupported distribution."
            exit 1
            ;;
    esac

    print_message "$GREEN" "Dependencies installed successfully!"
}

handle_existing_config() {
    local nvim_config_dir="$HOME/.config/nvim"
    local backup_dir="$HOME/.config/carch/backups"

    if [ ! -d "$nvim_config_dir" ]; then
        print_message "$GREEN" "Creating Neovim configuration directory..."
        mkdir -p "$nvim_config_dir"
        return
    fi

    print_message "$YELLOW" "Existing Neovim configuration found."

    if confirm "Backup existing config?"; then
        print_message "$RED" "Backing up existing config..."
        mkdir -p "$backup_dir"
        mv "$nvim_config_dir" "$backup_dir/nvim.bak"
        mkdir -p "$nvim_config_dir"
        print_message "$GREEN" "Backup created at $backup_dir/nvim.bak"
    else
        print_message "$YELLOW" "Removing existing Neovim configuration..."
        rm -rf "$nvim_config_dir"
        mkdir -p "$nvim_config_dir"
    fi
}

setup_nvchad() {
    local nvchad_dir="/tmp/chadnvim"
    local nvim_config_dir="$HOME/.config/nvim"

    handle_existing_config

    print_message "$GREEN" "Cloning NvChad configuration from GitHub..."
    if ! git clone https://github.com/harilvfs/chadnvim "$nvchad_dir"; then
        print_message "$RED" "Failed to clone the NvChad repository."
        exit 1
    fi

    print_message "$GREEN" "Applying NvChad configuration..."
    cp -r "$nvchad_dir/nvim/"* "$nvim_config_dir/"

    print_message "$GREEN" "Cleaning up..."
    rm -rf "$nvchad_dir"
    rm -rf "$nvim_config_dir/LICENSE" "$nvim_config_dir/README.md"

    print_message "$GREEN" "NvChad setup completed successfully!"
}

main() {
    install_dependencies
    setup_nvchad
    print_message "$GREEN" "Setup completed!"
}

main
