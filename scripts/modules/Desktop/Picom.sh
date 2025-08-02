#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

aur_helper=""

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

install_aur_helper() {
    local aur_helpers=("yay" "paru")
    for helper in "${aur_helpers[@]}"; do
        if command -v "$helper" &> /dev/null; then
            print_message "$GREEN" ":: AUR helper '$helper' is already installed. Using it."
            aur_helper="$helper"
            return
        fi
    done

    print_message "$RED" "No AUR helper found. Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    temp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
    cd "$temp_dir/yay" || {
        print_message "$RED" "Failed to enter yay directory"
        exit 1
    }
    makepkg -si --noconfirm
    cd ~ || exit 1
    rm -rf "$temp_dir"
    print_message "$GREEN" "yay installed successfully."
    aur_helper="yay"
}

print_source_message() {
    print_message "$TEAL" ":: This Picom build is from FT-Labs."
    print_message "$TEAL" ":: Check out here: https://github.com/FT-Labs/picom"
}

install_dependencies_normal() {
    print_message "$GREEN" ":: Installing Picom..."
    case "$DISTRO" in
        "Arch") sudo pacman -S --needed --noconfirm picom ;;
        "Fedora") sudo dnf install -y picom ;;
        "openSUSE") sudo zypper install -y picom ;;
    esac
}

setup_picom_ftlabs() {
    print_message "$GREEN" ":: Installing Picom FT-Labs (picom-ftlabs-git) via $aur_helper..."
    "$aur_helper" -S --noconfirm picom-ftlabs-git
}

install_picom_ftlabs_fedora() {
    print_message "$GREEN" ":: Installing dependencies for Picom FT-Labs (Fedora)..."
    sudo dnf install -y dbus-devel gcc git libconfig-devel libdrm-devel libev-devel libX11-devel libX11-xcb libXext-devel libxcb-devel libGL-devel libEGL-devel libepoxy-devel meson pcre2-devel pixman-devel uthash-devel xcb-util-image-devel xcb-util-renderutil-devel xorg-x11-proto-devel xcb-util-devel cmake

    print_message "$GREEN" ":: Cloning Picom FT-Labs repository..."
    git clone https://github.com/FT-Labs/picom ~/.cache/picom
    cd ~/.cache/picom || {
        print_message "$RED" "Failed to clone Picom repo."
        exit 1
    }

    print_message "$GREEN" ":: Building Picom with meson and ninja..."
    meson setup --buildtype=release build
    ninja -C build

    print_message "$GREEN" ":: Installing the built Picom binary..."
    sudo cp build/src/picom /usr/local/bin
    sudo ldconfig

    print_message "$GREEN" "Done..."
}

install_picom_ftlabs_opensuse() {
    print_message "$GREEN" ":: Installing dependencies for Picom FT-Labs (OpenSUSE)..."
    sudo zypper install -y dbus-1-devel gcc git libconfig-devel libdrm-devel libev-devel \
            libX11-devel libXext-devel libxcb-devel Mesa-libGL-devel Mesa-libEGL1 \
            libepoxy-devel meson pcre2-devel libpixman-1-0-devel pkgconf uthash-devel cmake libev-devel \
            xcb-util-image-devel xcb-util-renderutil-devel xorg-x11-proto-devel xcb-util-devel

    print_message "$GREEN" ":: Cloning Picom FT-Labs repository..."
    git clone https://github.com/FT-Labs/picom ~/.cache/picom
    cd ~/.cache/picom || {
        print_message "$RED" "Failed to clone Picom repo."
        exit 1
    }

    print_message "$GREEN" ":: Building Picom with meson and ninja..."
    meson setup --buildtype=release build
    ninja -C build

    print_message "$GREEN" ":: Installing the built Picom binary..."
    sudo cp build/src/picom /usr/local/bin
    sudo ldconfig

    print_message "$GREEN" "Done..."
}

download_config() {
    local config_url="$1"
    local config_path="$HOME/.config/picom.conf"
    local backup_dir="$HOME/.config/carch/backups"

    if [ -f "$config_path" ]; then
        if confirm "Overwrite existing picom.conf?"; then
            print_message "$GREEN" ":: Backing up existing picom.conf..."
            mkdir -p "$backup_dir"
            mv "$config_path" "$backup_dir/picom.conf.bak"
            print_message "$GREEN" ":: Backup created: $backup_dir/picom.conf.bak"
        else
            print_message "$RED" ":: Skipping picom.conf download..."
            return
        fi
    fi

    mkdir -p ~/.config
    print_message "$GREEN" ":: Downloading Picom configuration..."
    wget -O "$config_path" "$config_url"
}

main() {
    print_source_message

    local options=("Picom with animation (FT-Labs)" "Picom normal" "Exit")
    show_menu "Choose Picom version:" "${options[@]}"

    get_choice "${#options[@]}"
    choice_index=$?
    choice="${options[$((choice_index - 1))]}"

    case "$choice" in
        "Picom with animation (FT-Labs)")
            case "$DISTRO" in
                "Arch")
                    install_aur_helper
                    setup_picom_ftlabs
                    ;;
                "Fedora")
                    install_picom_ftlabs_fedora
                    ;;
                "openSUSE")
                    install_picom_ftlabs_opensuse
                    ;;
            esac
            download_config "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/picom/picom.conf"
            print_message "$GREEN" ":: Picom setup completed with animations from FT-Labs!"
            ;;
        "Picom normal")
            install_dependencies_normal
            download_config "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/picom/picom.conf"
            print_message "$GREEN" ":: Picom setup completed without animations!"
            ;;
        "Exit")
            exit 0
            ;;
        *)
            print_message "$RED" "Invalid option. Please try again."
            exit 1
            ;;
    esac
}

main
