#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

print_message() {
    local color="$1"
    local message="$2"
    printf "%b%s%b\n" "$color" "$message" "$NC"
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

show_menu() {
    local title="$1"
    shift
    local options=("$@")

    echo
    print_message "$CYAN" "=== $title ==="
    echo

    for i in "${!options[@]}"; do
        printf "%b[%d]%b %s\n" "$GREEN" "$((i + 1))" "$NC" "${options[$i]}"
    done
    echo
}

get_choice() {
    local max_option="$1"
    local choice

    while true; do
        read -p "$(printf "%b%s%b" "$YELLOW" "Enter your choice (1-$max_option): " "$NC")" choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$max_option" ]; then
            return "$choice"
        else
            print_message "$RED" "Invalid choice. Please enter a number between 1 and $max_option."
        fi
    done
}

echo -e "${TEAL}"
cat << "EOF"

This script helps you set up Neovim or NvChad.

:: 'Neovim' will install and configure the standard Neovim setup.
:: 'NvChad' will install and configure the NvChad setup.
:: 'Exit' to exit the script at any time.

For either option:
- 'Yes': Will check for an existing Neovim configuration and back it up before applying the new configuration.
- 'No': Will create a new Neovim configuration directory.

-------------------------------------------------------------------------------------------------
EOF
echo -e "${NC}"

install_dependencies() {
    print_message "$GREEN" "Installing required dependencies..."

    case "$DISTRO" in
        "Arch")
            sudo pacman -S --needed --noconfirm ripgrep neovim vim fzf python-virtualenv luarocks go npm shellcheck \
                xclip wl-clipboard lua-language-server shfmt python3 yaml-language-server meson ninja \
                make gcc ttf-jetbrains-mono ttf-jetbrains-mono-nerd git
            ;;
        "Fedora")
            sudo dnf install -y ripgrep neovim vim fzf python3-virtualenv luarocks go nodejs shellcheck xclip \
                wl-clipboard lua-language-server shfmt python3 meson ninja-build \
                make gcc jetbrains-mono-fonts-all jetbrains-mono-fonts jetbrains-mono-nl-fonts git
            ;;
        "openSUSE")
            sudo zypper install -y ripgrep neovim vim fzf python313-virtualenv lua53-luarocks go nodejs ShellCheck xclip \
                wl-clipboard lua-language-server shfmt python313 meson ninja \
                make gcc jetbrains-mono-fonts git
            ;;
        *)
            exit 1
            ;;
    esac

    print_message "$GREEN" "Dependencies installed successfully!"
}

handle_existing_config() {
    local nvim_config_dir="$HOME/.config/nvim"
    local backup_dir="$HOME/.config/carch/backups"

    if [ ! -d "$nvim_config_dir" ]; then
        print_message "$GREEN" ":: Creating Neovim configuration directory..."
        mkdir -p "$nvim_config_dir"
        return
    fi

    print_message "$YELLOW" "Existing Neovim configuration found."

    if confirm "Backup existing config?"; then
        print_message "$RED" ":: Backing up existing config..."
        mkdir -p "$backup_dir"
        local backup_path="$backup_dir/nvim.bak"
        mv "$nvim_config_dir" "$backup_path"
        mkdir -p "$nvim_config_dir"
        print_message "$GREEN" ":: Backup created at $backup_path."
    else
        print_message "$YELLOW" ":: Removing existing Neovim configuration..."
        rm -rf "$nvim_config_dir"
        mkdir -p "$nvim_config_dir"
    fi
}

setup_neovim() {
    local nvim_config_dir="$HOME/.config/nvim"

    handle_existing_config

    print_message "$GREEN" ":: Cloning Neovim configuration from GitHub..."
    if ! git clone https://github.com/harilvfs/nvim "$nvim_config_dir"; then
        print_message "$RED" "Failed to clone the Neovim configuration repository."
        exit 1
    fi

    print_message "$GREEN" ":: Cleaning up unnecessary files..."
    cd "$nvim_config_dir" || exit 1
    rm -rf .git README.md LICENSE

    print_message "$GREEN" "Neovim setup completed successfully!"
}

setup_nvchad() {
    local nvchad_dir="/tmp/chadnvim"
    local nvim_config_dir="$HOME/.config/nvim"

    handle_existing_config

    print_message "$GREEN" ":: Cloning NvChad configuration from GitHub..."
    if ! git clone https://github.com/harilvfs/chadnvim "$nvchad_dir"; then
        print_message "$RED" "Failed to clone the NvChad repository."
        return 1
    fi

    print_message "$GREEN" ":: Moving NvChad configuration..."
    cp -r "$nvchad_dir/nvim/"* "$nvim_config_dir/"

    print_message "$GREEN" ":: Cleaning up temporary files..."
    rm -rf "$nvchad_dir"

    print_message "$GREEN" ":: Cleaning up unnecessary files..."
    cd "$nvim_config_dir" || return 1
    rm -rf LICENSE README.md

    print_message "$GREEN" "NvChad setup completed successfully!"
}

main() {
    local options=("Neovim" "NvChad" "Exit")
    show_menu "Choose the setup option:" "${options[@]}"

    get_choice "${#options[@]}"
    local choice_index=$?
    local choice="${options[$((choice_index - 1))]}"

    case "$choice" in
        "Neovim")
            setup_neovim
            install_dependencies
            ;;
        "NvChad")
            setup_nvchad
            install_dependencies
            ;;
        "Exit")
            exit 0
            ;;
        *)
            print_message "$RED" "Invalid option selected! Exiting."
            exit 1
            ;;
    esac

    print_message "$GREEN" "Setup completed!"
}

main
