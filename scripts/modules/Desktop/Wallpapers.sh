#!/usr/bin/env bash

clear

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

setup_directories() {
    local pictures_dir="$1"
    print_message "$CYAN" "Wallpapers will be set up in the Pictures directory ($pictures_dir)."

    if [ ! -d "$pictures_dir" ]; then
        print_message "$CYAN" "Creating the Pictures directory..."
        mkdir -p "$pictures_dir"
    fi
}

clone_wallpapers() {
    local wallpapers_dir="$1"
    if [ -d "$wallpapers_dir" ]; then
        print_message "$YELLOW" "The wallpapers directory already exists."
        if confirm "Overwrite existing wallpapers directory?"; then
            print_message "$CYAN" "Removing existing wallpapers directory..."
            rm -rf "$wallpapers_dir"
        else
            print_message "$YELLOW" "Operation cancelled. Keeping existing wallpapers."
            exit 0
        fi
    fi

    print_message "$CYAN" "Cloning the wallpapers repository..."
    if git clone https://github.com/harilvfs/wallpapers "$wallpapers_dir"; then
        return 0
    else
        print_message "$RED" "Failed to clone the repository."
        return 1
    fi
}

cleanup_repo() {
    local wallpapers_dir="$1"
    print_message "$CYAN" "Cleaning up unnecessary files from the repository..."
    cd "$wallpapers_dir" || exit 1
    rm -rf .git README.md docs/ 2> /dev/null || true
    print_message "$GREEN" "Wallpapers have been successfully set up in your wallpapers directory."
}

main() {
    local pictures_dir="$HOME/Pictures"
    local wallpapers_dir="$pictures_dir/wallpapers"

    setup_directories "$pictures_dir"
    if clone_wallpapers "$wallpapers_dir"; then
        cleanup_repo "$wallpapers_dir"
    else
        exit 1
    fi
}

main
