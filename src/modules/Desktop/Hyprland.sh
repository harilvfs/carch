#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

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

    if command -v pacman &> /dev/null; then
        distro="arch"
    elif command -v dnf &> /dev/null; then
        distro="fedora"
    elif command -v zypper &> /dev/null; then
        distro="opensuse"
    else
        print_message "$RED" "Unsupported distro. Exiting..."
        exit 1
    fi

    print_message "$TEAL" "Distro: ${distro^} Linux"

    if [[ "$distro" == "arch" ]]; then
        options=("prasanthrangan/hyprdots" "mylinuxforwork/dotfiles" "end-4/dots-hyprland" "jakoolit/Arch-Hyprland" "Exit")
    elif [[ "$distro" == "fedora" ]]; then
        options=("mylinuxforwork/dotfiles" "jakoolit/Fedora-Hyprland" "Exit")
    elif [[ "$distro" == "opensuse" ]]; then
        options=("mylinuxforwork/dotfiles (Coming Soon)" "jakoolit/OpenSUSE-Hyprland" "Exit")
    fi

    echo
    print_message "$YELLOW" "Note: These are not my personal dotfiles; I am sourcing them from their respective users."
    print_message "$YELLOW" "Backup your configurations before proceeding. I am not responsible for any data loss."

    show_menu "Hyprland Configuration Options" "${options[@]}"

    get_choice "${#options[@]}"
    choice_index=$?
    choice="${options[$((choice_index - 1))]}"

    if [[ "$choice" == "Exit" ]]; then
        print_message "$RED" "Exiting..."
        exit 0
    fi

    if [[ "$choice" == "mylinuxforwork/dotfiles (Coming Soon)" ]]; then
        echo
        print_message "$YELLOW" "ML4W dotfiles for OpenSUSE is coming soon!"
        print_message "$CYAN" "The owner has not officially published the guide yet."
        print_message "$CYAN" "I will add support once it's officially available."
        echo
        print_message "$GREEN" "Press any key to return to menu..."
        read -n 1
        main_menu
        return
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

    if ! confirm "Do you want to continue?"; then
        print_message "$YELLOW" "Returning to menu..."
        main_menu
        return
    fi

    install_config "$choice" "$distro"
}

install_config() {
    local choice="$1"
    local distro="$2"

    echo
    print_message "$GREEN" "Installing configuration: $choice"
    echo

    if [[ "$choice" == "prasanthrangan/hyprdots" ]]; then
        pacman -S --needed git base-devel
        git clone --depth 1 https://github.com/HyDE-Project/HyDE ~/HyDE
        cd ~/HyDE/Scripts || exit
        ./install.sh
    elif [[ "$choice" == "mylinuxforwork/dotfiles" ]]; then
        if [[ "$distro" == "arch" ]]; then
            bash -c "$(curl -s https://raw.githubusercontent.com/mylinuxforwork/dotfiles/main/setup-arch.sh)"
        else
            bash -c "$(curl -s https://raw.githubusercontent.com/mylinuxforwork/dotfiles/main/setup-fedora.sh)"
        fi
    elif [[ "$choice" == "end-4/dots-hyprland" ]]; then
        bash -c "$(curl -s https://end-4.github.io/dots-hyprland-wiki/setup.sh)"
    elif [[ "$choice" == "jakoolit/Arch-Hyprland" ]]; then
        git clone --depth=1 https://github.com/JaKooLit/Arch-Hyprland.git ~/Arch-Hyprland
        cd ~/Arch-Hyprland || exit
        chmod +x install.sh
        ./install.sh
    elif [[ "$choice" == "jakoolit/Fedora-Hyprland" ]]; then
        git clone --depth=1 https://github.com/JaKooLit/Fedora-Hyprland.git ~/Fedora-Hyprland
        cd ~/Fedora-Hyprland || exit
        chmod +x install.sh
        ./install.sh
    elif [[ "$choice" == "jakoolit/OpenSUSE-Hyprland" ]]; then
        git clone --depth=1 https://github.com/JaKooLit/OpenSUSE-Hyprland.git ~/OpenSUSE-Hyprland
        cd ~/OpenSUSE-Hyprland || exit
        chmod +x install.sh
        ./install.sh
    fi
}

main_menu
