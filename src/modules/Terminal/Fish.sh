#!/usr/bin/env bash

# Installs and configures the Fish shell, offering an interactive and user-friendly command-line environment with advanced features such as auto-suggestions and a clean syntax.

clear

source "$(dirname "$0")/../colors.sh" >/dev/null 2>&1

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

fzf_confirm() {
    local prompt="$1"
    local options=("Yes" "No")
    local selected=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                     --height=40% \
                                                     --prompt="$prompt " \
                                                     --header="Confirm" \
                                                     --pointer="➤" \
                                                     --color='fg:white,fg+:green,bg+:black,pointer:green')

    if [[ "$selected" == "Yes" ]]; then
        return 0
    else
        return 1
    fi
}

print_color() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${RESET}"
}

detect_distro() {
    if command -v pacman &>/dev/null; then
        DISTRO="arch"
    elif command -v dnf &>/dev/null; then
        DISTRO="fedora"
    else
        print_color "$RED" "Unsupported distribution!"
        exit 1
    fi
}

install_fish() {
    print_color "$CYAN" "Installing Fish shell..."
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm fish noto-fonts-emoji git eza
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y fish google-noto-color-emoji-fonts google-noto-emoji-fonts git

        print_color "$CYAN" "Installing eza manually for Fedora..."
        if command -v eza &>/dev/null; then
            print_color "$GREEN" "eza is already installed."
        else
            local tmp_dir=$(mktemp -d)
            cd "$tmp_dir" || exit 1
            print_color "$CYAN" "Fetching latest eza release..."
            local latest_url=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep -o "https://github.com/eza-community/eza/releases/download/.*/eza_x86_64-unknown-linux-gnu.zip" | head -1)
            if [ -z "$latest_url" ]; then
                print_color "$YELLOW" "Could not determine latest version, using fallback version..."
                latest_url="https://github.com/eza-community/eza/releases/download/v0.21.1/eza_x86_64-unknown-linux-gnu.zip"
            fi
            print_color "$CYAN" "Downloading eza from: $latest_url"
            if ! curl -L -o eza.zip "$latest_url"; then
                print_color "$RED" "Failed to download eza. Exiting..."
                cd "$HOME" || exit
                rm -rf "$tmp_dir"
                exit 1
            fi
            print_color "$CYAN" "Extracting eza..."
            unzip -q eza.zip
            print_color "$CYAN" "Installing eza to /usr/bin..."
            sudo cp eza /usr/bin/
            sudo chmod +x /usr/bin/eza
            cd "$HOME" || exit
            rm -rf "$tmp_dir"
            print_color "$GREEN" "eza installed successfully!"
        fi
    else
        print_color "$RED" "Unsupported distro: $DISTRO"
        exit 1
    fi
}

install_zoxide() {
    print_color "$CYAN" "Installing zoxide..."
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm zoxide
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y zoxide
    else
        print_color "$RED" "Unsupported distro: $DISTRO"
        exit 1
    fi
}

if ! command -v fzf &> /dev/null; then
    echo -e "${RED}${BOLD}Error: fzf is not installed${NC}"
    echo -e "${YELLOW}Please install fzf before running this script:${NC}"
    echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install fzf"
    echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S fzf"
    exit 1
fi

detect_distro

install_fish

FISH_CONFIG="$HOME/.config/fish"
if [[ -d "$FISH_CONFIG" ]]; then
    fzf_confirm "Existing Fish config found. Do you want to back it up?" && {
        BACKUP_PATH="$HOME/.config/fish.bak.$(date +%s)"
        mv "$FISH_CONFIG" "$BACKUP_PATH"
        print_color "$GREEN" "Backup created at $BACKUP_PATH"
    }
fi

echo "Cloning Fish configuration..."
git clone --depth=1 https://github.com/harilvfs/dwm "$HOME/dwm"
if [[ -d "$HOME/dwm/config/fish" ]]; then
    echo "Applying Fish configuration..."
    cp -r "$HOME/dwm/config/fish" "$FISH_CONFIG"
    print_color "$GREEN" "Fish configuration applied!"
    rm -rf "$HOME/dwm"
else
    print_color "$RED" "Failed to apply Fish configuration!"
    exit 1
fi

CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
FISH_PATH=$(command -v fish)

if [[ "$CURRENT_SHELL" == "$FISH_PATH" ]]; then
    print_color "$GREEN" "Fish is already your default shell."
else
    fzf_confirm "Fish is not your default shell. Set it as default?" && {
        print_color "$CYAN" "Setting Fish as your default shell..."
        chsh -s "$FISH_PATH"
        print_color "$GREEN" "Fish is now set as your default shell!"
    }
fi

install_zoxide
print_color "$GREEN" "Zoxide initialized in Fish!"
print_color "$CYAN" "Fish setup complete! Restart your shell to apply changes."
