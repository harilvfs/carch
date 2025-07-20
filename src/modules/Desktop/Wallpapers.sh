#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

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

PICTURES_DIR="$HOME/Pictures"
WALLPAPERS_DIR="$PICTURES_DIR/wallpapers"

main() {
    print_message "$CYAN" ":: Wallpapers will be set up in the Pictures directory ($PICTURES_DIR)."

    if [ ! -d "$PICTURES_DIR" ]; then
        print_message "$CYAN" ":: Creating the Pictures directory..."
        mkdir -p "$PICTURES_DIR"
    fi

    if [ -d "$WALLPAPERS_DIR" ]; then
        print_message "$YELLOW" ":: The wallpapers directory already exists."
        if confirm "Overwrite existing wallpapers directory?"; then
            print_message "$CYAN" ":: Removing existing wallpapers directory..."
            rm -rf "$WALLPAPERS_DIR"
        else
            print_message "$YELLOW" "Operation cancelled. Keeping existing wallpapers."
            exit 0
        fi
    fi

    print_message "$CYAN" ":: Cloning the wallpapers repository..."
    if git clone https://github.com/harilvfs/wallpapers "$WALLPAPERS_DIR"; then
        print_message "$CYAN" ":: Cleaning up unnecessary files from the repository..."
        cd "$WALLPAPERS_DIR" || exit 1
        rm -rf .git README.md docs/ 2> /dev/null || true
        print_message "$GREEN" ":: Wallpapers have been successfully set up in your wallpapers directory."
    else
        print_message "$RED" ":: Failed to clone the repository."
        exit 1
    fi
}

main
