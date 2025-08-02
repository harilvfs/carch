#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

print_message() {
    local color="$1"
    local message="$2"
    printf "%b%s%b\n" "$color" "$message" "$ENDCOLOR"
}

confirm() {
    while true; do
        read -p "$(printf "%b%s%b" "$CYAN" "$1 [y/N]: " "$ENDCOLOR")" answer
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
        printf "%b[%d]%b %s\n" "$GREEN" "$((i + 1))" "$ENDCOLOR" "${options[$i]}"
    done
    echo
}

get_choice() {
    local max_option="$1"
    local choice

    while true; do
        read -p "$(printf "%b%s%b" "$YELLOW" "Enter your choice (1-$max_option): " "$ENDCOLOR")" choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$max_option" ]; then
            return "$choice"
        else
            print_message "$RED" "Invalid choice. Please enter a number between 1 and $max_option."
        fi
    done
}

FASTFETCH_DIR="$HOME/.config/fastfetch"

check_command() {
    local cmd=$1
    if ! command -v "$cmd" &> /dev/null; then
        print_message "$RED" "Required command '$cmd' not found. Please install it and try again."
        return 1
    fi
    return 0
}

check_fastfetch() {
    if command -v fastfetch &> /dev/null; then
        print_message "$GREEN" "Fastfetch is already installed."
    else
        print_message "$CYAN" "Fastfetch is not installed. Installing..."
        case "$DISTRO" in
            "Arch") sudo pacman -S --noconfirm fastfetch git ;;
            "Fedora") sudo dnf install -y fastfetch git ;;
            "openSUSE") sudo zypper install -y fastfetch git ;;
            *)
                print_message "$RED" "Unsupported package manager! Please install Fastfetch manually."
                exit 1
                ;;
        esac
        print_message "$GREEN" "Fastfetch has been installed."
    fi
}

handle_existing_config() {
    if [ -d "$FASTFETCH_DIR" ]; then
        print_message "$YELLOW" "Existing Fastfetch configuration found."
        if confirm "Do you want to back up your existing Fastfetch configuration?"; then
            local backup_dir="$HOME/.config/carch/backups"
            local backup_path="$backup_dir/fastfetch.bak"

            mkdir -p "$backup_dir"

            print_message "$CYAN" "Backing up existing Fastfetch configuration to $backup_path..."

            if [ -d "$backup_path" ]; then
                rm -rf "$backup_path"
            fi

            mv "$FASTFETCH_DIR" "$backup_path"
            print_message "$GREEN" "Backup completed."
        else
            print_message "$YELLOW" "Proceeding without backup..."
        fi
    else
        mkdir -p "$FASTFETCH_DIR"
    fi
}

setup_standard_fastfetch() {
    check_fastfetch
    handle_existing_config

    print_message "$CYAN" "Setting up standard Fastfetch configuration..."
    print_message "$CYAN" "Downloading standard configuration..."
    curl -sSLo "$FASTFETCH_DIR/config.jsonc" "https://raw.githubusercontent.com/harilvfs/fastfetch/refs/heads/old-days/fastfetch/config.jsonc"
    print_message "$GREEN" "Standard Fastfetch setup completed!"
}

setup_png_fastfetch() {
    check_fastfetch
    handle_existing_config

    print_message "$CYAN" "Setting up Fastfetch with custom PNG support..."
    print_message "$CYAN" "Cloning Fastfetch repository directly..."

    rm -rf "$FASTFETCH_DIR"/* 2> /dev/null
    mkdir -p "$FASTFETCH_DIR"

    git clone https://github.com/harilvfs/fastfetch "$FASTFETCH_DIR"

    print_message "$CYAN" "Cleaning up unnecessary files..."
    rm -rf "$FASTFETCH_DIR/.git" "$FASTFETCH_DIR/LICENSE" "$FASTFETCH_DIR/README.md"

    print_message "$GREEN" "Fastfetch with PNG support setup completed!"
}

main() {
    check_command "git" || exit 1

    while true; do
        clear
        print_message "$TEAL" "Standard is best for terminals that don't support image rendering"
        print_message "$TEAL" "PNG option should only be used in terminals that support image rendering"

        local options=("Fastfetch Standard" "Fastfetch with PNG" "Exit")
        show_menu "Choose the setup option" "${options[@]}"

        get_choice "${#options[@]}"
        choice_index=$?
        choice="${options[$((choice_index - 1))]}"

        case "$choice" in
            "Fastfetch Standard")
                setup_standard_fastfetch
                print_message "$GREEN" "Setup completed! You can now run 'fastfetch' to see the results."
                break
                ;;
            "Fastfetch with PNG")
                setup_png_fastfetch
                print_message "$GREEN" "Setup completed! You can now run 'fastfetch' to see the results."
                break
                ;;
            "Exit")
                exit 0
                ;;
        esac
    done
}

main
