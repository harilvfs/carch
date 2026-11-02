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

NITCH_REPO="https://github.com/harilvfs/nitch"
TEMP_DIR=""

cleanup() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

main() {
    print_message "$TEAL" "Nitch is an incredibly fast system fetch written in Nim."
    print_message "$TEAL" "Note: The main repo (ssleert/nitch) is deprecated."
    print_message "$TEAL" "This uses a maintained fork: $NITCH_REPO"
    echo

    if ! confirm "Do you want to proceed with the installation?"; then
        print_message "$YELLOW" "Installation cancelled."
        exit 0
    fi

    TEMP_DIR=$(mktemp -d)

    print_message "$TEAL" "Cloning nitch repository..."
    if ! git clone "$NITCH_REPO" "$TEMP_DIR/nitch"; then
        print_message "$RED" "Failed to clone repository."
        exit 1
    fi

    print_message "$TEAL" "Running setup script..."
    cd "$TEMP_DIR/nitch" || exit 1
    chmod +x setup.sh
    ./setup.sh

    print_message "$GREEN" "Nitch installed successfully!"
    print_message "$GREEN" "Run 'nitch' to see it in action."
}

main
