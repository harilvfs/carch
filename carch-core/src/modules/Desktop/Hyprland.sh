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
        read -p "$(printf "%b:: %s%b" "$YELLOW" "Enter your choice (1-$max_option): " "$NC")" choice

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

    case "$DISTRO" in
        "Arch")
            options=("prasanthrangan/hyprdots" "mylinuxforwork/dotfiles" "end-4/dots-hyprland" "jakoolit/Arch-Hyprland" "Exit")
            ;;
        "Fedora")
            options=("mylinuxforwork/dotfiles" "jakoolit/Fedora-Hyprland" "Exit")
            ;;
        "openSUSE")
            options=("mylinuxforwork/dotfiles" "jakoolit/OpenSUSE-Hyprland" "Exit")
            ;;
    esac

    echo
    print_message "$YELLOW" "Note: These are not my personal dotfiles; I am sourcing them from their respective users."
    print_message "$YELLOW" "Backup your configurations before proceeding. I am not responsible for any data loss."

    show_menu "Hyprland Configuration Options" "${options[@]}"

    get_choice "${#options[@]}"
    choice_index=$?
    choice="${options[$((choice_index - 1))]}"

    if [[ "$choice" == "Exit" ]]; then
        exit 0
    fi

    echo
    print_message "$GREEN" "You selected: $choice"

    declare -A repos
    repos["prasanthrangan/hyprdots"]="https://github.com/prasanthrangan/hyprdots"
    repos["mylinuxforwork/dotfiles"]="https://github.com/mylinuxforwork/dotfiles"
    repos["end-4/dots-hyprland"]="https://github.com/end-4/dots-hyprland"
    repos["jakoolit/Arch-Hyprland"]="https://github.com/JaKooLit/Arch-Hyprland"
    repos["jakoolit/Fedora-Hyprland"]="https://github.com/JaKooLit/Fedora-Hyprland"
    repos["jakoolit/OpenSUSE-Hyprland"]="https://github.com/JaKooLit/OpenSUSE-Hyprland"

    print_message "$CYAN" "Sourcing from: ${repos[$choice]}"
    echo

    if [[ "$choice" == "mylinuxforwork/dotfiles" ]]; then
        print_message "$RED" "IMPORTANT: ML4W installation methods may have changed. Please check the official repo first!"
        echo
    elif [[ "$choice" != "Exit" ]]; then
        print_message "$RED" "IMPORTANT: Please check the official repository first to ensure installation methods haven't changed!"
        echo
    fi

    if ! confirm "Do you want to continue?"; then
        print_message "$YELLOW" "Returning to menu..."
        main_menu
        return
    fi

    install_config "$choice" "$DISTRO"
}

install_config() {
    local choice="$1"
    local distro="$2"

    echo
    print_message "$GREEN" "Installing configuration: $choice"
    echo

    case "$choice" in
        "prasanthrangan/hyprdots")
            pacman -S --needed git base-devel
            git clone --depth 1 https://github.com/HyDE-Project/HyDE ~/HyDE
            cd ~/HyDE/Scripts || exit
            ./install.sh
            ;;
        "mylinuxforwork/dotfiles")
            case "$distro" in
                "Arch")
                    bash -c "$(curl -s https://raw.githubusercontent.com/mylinuxforwork/dotfiles/refs/heads/main/setup/setup-arch.sh)"
                    ;;
                "Fedora")
                    bash -c "$(curl -s https://raw.githubusercontent.com/mylinuxforwork/dotfiles/refs/heads/main/setup/setup-fedora.sh)"
                    ;;
                "openSUSE")
                    bash -c "$(curl -s https://raw.githubusercontent.com/mylinuxforwork/dotfiles/refs/heads/main/setup/setup-fedora.sh)"
                    ;;
            esac
            ;;
        "end-4/dots-hyprland")
            bash -c "$(curl -s https://end-4.github.io/dots-hyprland-wiki/setup.sh)"
            ;;
        "jakoolit/Arch-Hyprland")
            git clone --depth=1 https://github.com/JaKooLit/Arch-Hyprland.git ~/Arch-Hyprland
            cd ~/Arch-Hyprland || exit
            chmod +x install.sh
            ./install.sh
            ;;
        "jakoolit/Fedora-Hyprland")
            git clone --depth=1 https://github.com/JaKooLit/Fedora-Hyprland.git ~/Fedora-Hyprland
            cd ~/Fedora-Hyprland || exit
            chmod +x install.sh
            ./install.sh
            ;;
        "jakoolit/OpenSUSE-Hyprland")
            git clone --depth=1 https://github.com/JaKooLit/OpenSUSE-Hyprland.git ~/OpenSUSE-Hyprland
            cd ~/OpenSUSE-Hyprland || exit
            chmod +x install.sh
            ./install.sh
            ;;
    esac
}

main_menu
