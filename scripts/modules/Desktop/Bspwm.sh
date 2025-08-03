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
        read -p "$(printf "%b%s%b" "$CYAN" "$1 [y/N]: " "$RC")" answer
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

main_menu() {
    clear

    print_message "$TEAL" "Distro: $DISTRO Linux"

    if [[ "$DISTRO" != "Arch" ]]; then
        echo
        print_message "$RED" "This dotfiles configuration is not supported on $DISTRO Linux."
        print_message "$CYAN" "Please check the repository for compatible configurations: https://github.com/gh0stzk/dotfiles"
        echo
        print_message "$GREEN" "Press any key to exit..."
        read -n 1
        exit 0
    fi

    options=("gh0stzk/dotfiles" "Exit")

    echo
    print_message "$YELLOW" "Note: These are not my personal dotfiles; I am sourcing them from their respective users."
    print_message "$YELLOW" "Backup your configurations before proceeding. I am not responsible for any data loss."

    show_menu "BSPWM Configuration Options" "${options[@]}"

    get_choice "${#options[@]}"
    choice_index=$?
    choice="${options[$((choice_index - 1))]}"

    if [[ "$choice" == "Exit" ]]; then
        exit 0
    fi

    echo
    print_message "$GREEN" "You selected: $choice"

    declare -A repos
    repos["gh0stzk/dotfiles"]="https://github.com/gh0stzk/dotfiles"

    print_message "$CYAN" "Sourcing from: ${repos[$choice]}"
    echo

    print_message "$RED" "IMPORTANT: Please check the official repository first to ensure installation methods haven't changed!"
    echo

    if ! confirm "Do you want to continue?"; then
        print_message "$YELLOW" "Returning to menu..."
        main_menu
        return
    fi

    install_config "$choice"
}

install_config() {
    local choice="$1"

    echo
    print_message "$GREEN" "Installing configuration: $choice"
    echo

    if [[ "$choice" == "gh0stzk/dotfiles" ]]; then
        print_message "$CYAN" "Removing any existing RiceInstaller to avoid conflicts..."
        rm -f ~/RiceInstaller

        print_message "$CYAN" "Downloading the installer to your home directory..."
        cd ~ || exit
        curl -LO http://gh0stzk.github.io/dotfiles/RiceInstaller

        print_message "$CYAN" "Setting execution permissions..."
        chmod +x ~/RiceInstaller

        print_message "$GREEN" "Running the installer from home directory..."
        ~/RiceInstaller
    fi
}

main_menu
