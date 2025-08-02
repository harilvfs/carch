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

install_dependencies() {
    print_message "$CYAN" ":: Installing dependencies..."

    if [ "$distro" == "arch" ]; then
        sudo pacman -S --needed --noconfirm git lxappearance gtk3 gtk4 qt5ct qt6ct nwg-look kvantum papirus-icon-theme adwaita-icon-theme || {
            print_message "$RED" ":: Failed to install dependencies. Exiting..."
            exit 1
        }
    elif [ "$distro" == "fedora" ]; then
        sudo dnf install -y git lxappearance gtk3 gtk4 qt5ct qt6ct kvantum papirus-icon-theme adwaita-icon-theme || {
            print_message "$RED" ":: Failed to install dependencies. Exiting..."
            exit 1
        }

        if ! command -v nwg-look &> /dev/null; then
            print_message "$CYAN" ":: Installing nwg-look for Fedora..."
            sudo dnf copr enable -y solopasha/hyprland || {
                print_message "$RED" ":: Failed to enable solopasha/hyprland COPR repository."
                exit 1
            }
            sudo dnf install -y nwg-look || {
                print_message "$RED" ":: Failed to install nwg-look. Exiting..."
                exit 1
            }
        fi
    elif [ "$distro" == "opensuse" ]; then
        sudo zypper install -y git lxappearance nwg-look gtk3-tools gtk4-tools qt5ct qt6ct kvantum-manager papirus-icon-theme adwaita-icon-theme || {
            print_message "$RED" ":: Failed to install dependencies. Exiting..."
            exit 1
        }
    fi

    print_message "$GREEN" ":: Dependencies installed successfully."
}

check_and_create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        print_message "$TEAL" ":: Created directory: $1"
    fi
}

clone_repo() {
    local repo_url=$1
    local target_dir=$2

    if [ -d "$target_dir" ]; then
        print_message "$YELLOW" ":: $target_dir already exists. Skipping clone."
    else
        git clone "$repo_url" "$target_dir" || {
            print_message "$RED" ":: Failed to clone $repo_url. Exiting..."
            exit 1
        }
    fi
}

cleanup_files() {
    local target_dir=$1
    rm -f "$target_dir/LICENSE" "$target_dir/README.md"
}

setup_themes() {
    print_message "$CYAN" ":: Setting up Themes..."
    local tmp_dir="/tmp/themes"
    clone_repo "https://github.com/harilvfs/themes" "$tmp_dir"

    check_and_create_dir "$HOME/.themes"

    cp -r "$tmp_dir"/* "$HOME/.themes/" 2> /dev/null
    cleanup_files "$HOME/.themes"

    rm -rf "$tmp_dir"

    print_message "$GREEN" ":: Themes have been set up successfully."
}

setup_icons() {
    print_message "$CYAN" ":: Setting up Icons..."
    local tmp_dir="/tmp/icons"
    clone_repo "https://github.com/harilvfs/icons" "$tmp_dir"

    check_and_create_dir "$HOME/.icons"

    cp -r "$tmp_dir"/* "$HOME/.icons/" 2> /dev/null
    cleanup_files "$HOME/.icons"

    rm -rf "$tmp_dir"

    print_message "$GREEN" ":: Icons have been set up successfully."
}

confirm_and_proceed() {
    print_message "$YELLOW" ":: This will install themes and icons, but you must select them manually using lxappearance (X11) or nwg-look (Wayland)."

    if ! confirm "Do you want to continue?"; then
        print_message "$YELLOW" "Operation canceled."
        exit 0
    fi
}

main() {
    local options=("Themes" "Icons" "Both" "Exit")
    show_menu "Themes and Icons" "${options[@]}"
    get_choice "${#options[@]}"
    choice_index=$?
    choice="${options[$((choice_index - 1))]}"

    distro=$(echo "$DISTRO" | tr '[:upper:]' '[:lower:]')

    case "$choice" in
        "Themes")
            install_dependencies
            confirm_and_proceed
            setup_themes
            print_message "$TEAL" ":: Use lxappearance for X11 or nwg-look for Wayland to select the theme."
            ;;
        "Icons")
            install_dependencies
            confirm_and_proceed
            setup_icons
            print_message "$TEAL" ":: Use lxappearance for X11 or nwg-look for Wayland to select the icons."
            ;;
        "Both")
            install_dependencies
            confirm_and_proceed
            setup_themes
            setup_icons
            print_message "$TEAL" ":: Use lxappearance for X11 or nwg-look for Wayland to select the theme and icons."
            ;;
        "Exit")
            exit 0
            ;;
        *)
            print_message "$RED" "Invalid option. Exiting..."
            exit 1
            ;;
    esac
}

main
