#!/bin/bash

clear

COLOR_RESET="\e[0m"
COLOR_GREEN="\e[32m"
COLOR_CYAN="\e[36m"
COLOR_RED="\e[31m"

VERSION="4.1.2"
TARGET_DIR="/usr/bin"
SCRIPTS_DIR="$TARGET_DIR/scripts"
DESKTOP_FILE="/usr/share/applications/carch.desktop"
MAN_PAGES_DIR="/usr/share/man/man1/carch.1"

BASH_COMPLETION_DIR="/usr/share/bash-completion/completions"
ZSH_COMPLETION_DIR="/usr/share/zsh/functions/Completion/Unix"
FISH_COMPLETION_DIR="/usr/share/fish/completions"

print_message() {
    local type="$1"
    local message="$2"
    case "$type" in
        INFO) echo -e "${COLOR_CYAN}[INFO] $message${COLOR_RESET}" ;;
        SUCCESS) echo -e "${COLOR_GREEN}[SUCCESS] $message${COLOR_RESET}" ;;
        ERROR) echo -e "${COLOR_RED}[ERROR] $message${COLOR_RESET}" ;;
        *) echo "$message" ;;
    esac
}

print_message INFO "Launching Carch Installer"
figlet -f slant "Carch"
echo "Version $VERSION"

check_dependency() {
    local dependency="$1"
    if ! command -v "$dependency" &>/dev/null; then
        print_message ERROR "$dependency is not installed. Install it using: pacman -S $dependency."
        exit 1
    fi
}

check_dependency "gum"

CHOICE=$(gum choose "Rolling Release" "Stable Release" "Cancel")
if [[ $CHOICE == "Cancel" ]]; then
    print_message INFO "Installation canceled by the user."
    exit 0
fi

print_message INFO "Removing existing installation..."
sudo rm -f "$TARGET_DIR/carch" "$TARGET_DIR/carch-tui" "$DESKTOP_FILE" "$MAN_PAGES_DIR"
sudo rm -rf "$SCRIPTS_DIR"
sudo rm -f "$BASH_COMPLETION_DIR/carch"
sudo rm -f "$ZSH_COMPLETION_DIR/_carch"
sudo rm -f "$FISH_COMPLETION_DIR/carch.fish"

print_message INFO "Removing icons..."
for size in 16 24 32 48 64 128 256; do
    sudo rm -f "/usr/share/icons/hicolor/${size}x${size}/apps/carch.png"
done

detect_shell() {
    local detected_shell
    detected_shell=$(basename "$SHELL")
    echo "$detected_shell"
}

ensure_directories() {
    print_message INFO "Ensuring completion directories exist..."

    if [[ ! -d "$BASH_COMPLETION_DIR" ]]; then
        print_message INFO "Creating Bash completion directory..."
        sudo mkdir -p "$BASH_COMPLETION_DIR" || {
            print_message ERROR "Failed to create Bash completion directory."
            exit 1
        }
    fi

    if [[ ! -d "$ZSH_COMPLETION_DIR" ]]; then
        print_message INFO "Creating Zsh completion directory..."
        sudo mkdir -p "$ZSH_COMPLETION_DIR" || {
            print_message ERROR "Failed to create Zsh completion directory."
            exit 1
        }
    fi

    if [[ ! -d "$FISH_COMPLETION_DIR" ]]; then
        print_message INFO "Creating Fish completion directory..."
        mkdir -p "$FISH_COMPLETION_DIR" || {
            print_message ERROR "Failed to create Fish completion directory."
            exit 1
        }
    fi
}

install_completions() {
    local shell="$1"
    print_message INFO "Installing completion files for $shell..."

    case "$shell" in
        bash)
            sudo curl -L "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/completions/bash/carch" \
                -o "$BASH_COMPLETION_DIR/carch" &>/dev/null
            print_message SUCCESS "Bash completion installed in: $BASH_COMPLETION_DIR"
            ;;
        zsh)
            sudo curl -L "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/completions/zsh/_carch" \
                -o "$ZSH_COMPLETION_DIR/_carch" &>/dev/null
            print_message SUCCESS "Zsh completion installed in: $ZSH_COMPLETION_DIR"
            ;;
        fish)
            sudo curl -L "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/completions/fish/carch.fish" \
                -o "$FISH_COMPLETION_DIR/carch.fish" &>/dev/null
            print_message SUCCESS "Fish completion installed in: $FISH_COMPLETION_DIR"
            ;;
        *)
            print_message ERROR "Unknown shell: $shell. Skipping completion installation."
            ;;
    esac
}

download_and_install() {
    local url="$1"
    local output="$2"
    local is_executable="$3"
    print_message INFO "Downloading $(basename "$output")..."
    sudo curl -L "$url" --output "$output" &>/dev/null
    if [[ $is_executable == "true" ]]; then
        sudo chmod +x "$output"
    fi
}

download_scripts() {
    sudo mkdir -p "$SCRIPTS_DIR"
    download_and_install "$1" "$SCRIPTS_DIR/scripts.zip" false
    print_message INFO "Extracting scripts.zip..."
    sudo unzip -q "$SCRIPTS_DIR/scripts.zip" -d "$SCRIPTS_DIR"
    sudo chmod +x "$SCRIPTS_DIR"/*.sh
    sudo rm "$SCRIPTS_DIR/scripts.zip"
}

install_man_page() {
    download_and_install "$1" "$MAN_PAGES_DIR" false
    print_message INFO "Updating man database..."
    sudo mandb &>/dev/null
}

install_icons() {
    local icon_sizes=("16" "24" "32" "48" "64" "128" "256")
    local base_url="https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/source/logo"
    local icon_dir="/usr/share/icons/hicolor"

    print_message INFO "Downloading and installing icons..."
    for size in "${icon_sizes[@]}"; do
        local icon_path="$icon_dir/${size}x${size}/apps"
        sudo mkdir -p "$icon_path"
        sudo curl -L "$base_url/product_logo_${size}.png" --output "$icon_path/carch.png" &>/dev/null
    done
}

if [[ $CHOICE == "Rolling Release" ]]; then
    print_message INFO "Installing Rolling Release..."
    download_and_install "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/build/carch" "$TARGET_DIR/carch" true
    download_and_install "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/build/carch-tui" "$TARGET_DIR/carch-tui" true
    download_scripts "https://github.com/harilvfs/carch/raw/refs/heads/main/source/zip/scripts.zip"
elif [[ $CHOICE == "Stable Release" ]]; then
    print_message INFO "Installing Stable Release..."
    download_and_install "https://github.com/harilvfs/carch/releases/latest/download/carch" "$TARGET_DIR/carch" true
    download_and_install "https://github.com/harilvfs/carch/releases/latest/download/carch-tui" "$TARGET_DIR/carch-tui" true
    download_scripts "https://github.com/harilvfs/carch/releases/latest/download/scripts.zip"
fi

install_man_page "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/man/carch.1"
install_icons
ensure_directories
current_shell=$(detect_shell)
install_completions "$current_shell"

print_message INFO "Creating Carch Desktop Entry..."
sudo tee "$DESKTOP_FILE" > /dev/null <<EOL
[Desktop Entry]
Name=Carch
Comment=An automated script for quick & easy Arch Linux system setup.
Exec=$TARGET_DIR/carch
Icon=carch
Type=Application
Terminal=true
Categories=Utility;
EOL

print_message SUCCESS "Carch Desktop Entry created successfully!"

print_message SUCCESS "Carch Installed!"
print_message INFO "Use 'carch' or 'carch --tui' to run the script."
print_message INFO "For help, type 'carch --help'."

