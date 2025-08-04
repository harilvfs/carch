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

check_dependencies() {
    local failed=0
    local deps=("git" "make")

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            print_message "$RED" "Error: ${dep} is not installed."
            print_message "$YELLOW" "Please install ${dep} before running this script:"
            print_message "$CYAN" "  • Arch Linux: sudo pacman -S ${dep}"
            failed=1
        fi
    done

    if [ "$failed" -eq 1 ]; then
        exit 1
    fi
}

install_paru() {
    if command -v paru &> /dev/null; then
        print_message "$GREEN" "Paru is already installed on this system."
        print_message "$CYAN" "$(paru --version | head -n 1)"
        return
    fi

    print_message "$CYAN" "Installing Paru..."
    sudo pacman -S --needed --noconfirm base-devel git
    if [ $? -ne 0 ]; then
        print_message "$RED" "Failed to install dependencies."
        return
    fi

    temp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/paru.git "$temp_dir/paru"
    cd "$temp_dir/paru" || {
        print_message "$RED" "Failed to enter paru directory"
        exit 1
    }
    makepkg -si --noconfirm
    cd ~ || exit 1
    rm -rf "$temp_dir"

    if command -v paru &> /dev/null; then
        print_message "$GREEN" "Paru installed successfully."
    else
        print_message "$RED" "Paru installation failed."
    fi
}

install_yay() {
    if command -v yay &> /dev/null; then
        print_message "$GREEN" "Yay is already installed on this system."
        print_message "$CYAN" "$(yay --version | head -n 1)"
        return
    fi

    print_message "$CYAN" "Installing Yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    if [ $? -ne 0 ]; then
        print_message "$RED" "Failed to install dependencies."
        read -p "Press Enter to continue..."
        return
    fi

    temp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
    cd "$temp_dir/yay" || {
        print_message "$RED" "Failed to enter yay directory"
        exit 1
    }
    makepkg -si --noconfirm
    cd ~ || exit 1
    rm -rf "$temp_dir"

    if command -v yay &> /dev/null; then
        print_message "$GREEN" "Yay installed successfully."
    else
        print_message "$RED" "Yay installation failed."
    fi
    read -p "Press Enter to continue..."
}

check_existing_helpers() {
    local helpers_found=false
    local helper_list=""

    if command -v paru &> /dev/null; then
        helpers_found=true
        paru_version=$(paru --version | head -n 1)
        helper_list="${helper_list}• Paru: ${paru_version}\n"
    fi

    if command -v yay &> /dev/null; then
        helpers_found=true
        yay_version=$(yay --version | head -n 1)
        helper_list="${helper_list}• Yay: ${yay_version}\n"
    fi

    if $helpers_found; then
        print_message "$GREEN" "AUR helper(s) already installed on this system:"
        printf "%b" "$helper_list"
    else
        print_message "$YELLOW" "No AUR helpers detected on this system."
    fi
}

main() {
    if [ "$DISTRO" != "Arch" ]; then
        print_message "$YELLOW" "NOTICE: This system is detected as ${DISTRO}."
        print_message "$RED" "AUR helpers (Paru/Yay) are specifically for Arch-based distributions and are not compatible with ${DISTRO}."
        print_message "$YELLOW" "These tools will not work on your system."
        exit 1
    fi

    check_dependencies

    while true; do
        clear
        print_message "$CYAN" "AUR Setup Menu [ For Arch Only ]"
        echo
        check_existing_helpers
        echo

        local options=("Install Paru" "Install Yay" "Exit")
        show_menu "Choose an option" "${options[@]}"

        get_choice "${#options[@]}"
        choice_index=$?
        choice="${options[$((choice_index - 1))]}"

        case "$choice" in
            "Install Paru") install_paru ;;
            "Install Yay") install_yay ;;
            "Exit")
                exit 0
                ;;
        esac
    done
}

main
