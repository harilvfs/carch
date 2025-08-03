#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

FONTS_DIR="$HOME/.fonts"
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

check_dependencies() {
    local failed=0
    local deps=("curl" "unzip")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            print_message "$RED" "Error: ${dep} is not installed."
            print_message "$YELLOW" "Please install ${dep} before running this script:"
            print_message "$CYAN" "  • Fedora: sudo dnf install ${dep}"
            print_message "$CYAN" "  • Arch Linux: sudo pacman -S ${dep}"
            print_message "$CYAN" "  • openSUSE: sudo zypper install ${dep}"
            failed=1
        fi
    done
    if [ "$failed" -eq 1 ]; then
        exit 1
    fi
}

get_latest_release() {
    curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" |
        grep '"tag_name":' |
        sed -E 's/.*"v([^"]+)".*/\1/'
}

check_aur_helper() {
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

install_font_arch() {
    local font_pkg="$@"
    print_message "$GREEN" ":: Installing $font_pkg via pacman..."
    sudo pacman -S --noconfirm $font_pkg
    print_message "$GREEN" "$font_pkg installed successfully!"
}

install_font_fedora() {
    local font_name="$1"
    local latest_version=$(get_latest_release)
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${latest_version}/${font_name}.zip"
    local zip_file="/tmp/${font_name}.zip"

    print_message "$GREEN" ":: Downloading $font_name version ${latest_version} to /tmp..."
    curl -L "$font_url" -o "$zip_file"

    print_message "$GREEN" ":: Extracting $font_name..."
    mkdir -p "$FONTS_DIR"
    unzip -q "$zip_file" -d "$FONTS_DIR"

    print_message "$GREEN" ":: Cleaning up temporary files..."
    rm -f "$zip_file"

    print_message "$GREEN" ":: Refreshing font cache..."
    fc-cache -vf

    print_message "$GREEN" "$font_name installed successfully in $FONTS_DIR!"
}

install_fedora_system_fonts() {
    local font_pkg="$@"
    print_message "$GREEN" ":: Installing $font_pkg via dnf..."
    sudo dnf install -y $font_pkg
    print_message "$GREEN" "$font_pkg installed successfully!"
}

install_font_opensuse() {
    local font_name="$1"
    local latest_version=$(get_latest_release)
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${latest_version}/${font_name}.zip"
    local zip_file="/tmp/${font_name}.zip"

    print_message "$GREEN" ":: Downloading $font_name version ${latest_version} to /tmp..."
    curl -L "$font_url" -o "$zip_file"

    print_message "$GREEN" ":: Extracting $font_name..."
    mkdir -p "$FONTS_DIR"
    unzip -q "$zip_file" -d "$FONTS_DIR"

    print_message "$GREEN" ":: Cleaning up temporary files..."
    rm -f "$zip_file"

    print_message "$GREEN" ":: Refreshing font cache..."
    fc-cache -vf

    print_message "$GREEN" "$font_name installed successfully in $FONTS_DIR!"
}

install_opensuse_system_fonts() {
    local font_pkg="$@"
    print_message "$GREEN" ":: Installing $font_pkg via zypper..."
    sudo zypper install -y $font_pkg
    print_message "$GREEN" "$font_pkg installed successfully!"
}

install_font() {
    local font_name="$1"

    case "$font_name" in
        "FiraCode")
            case "$DISTRO" in
                "Arch") install_font_arch "ttf-firacode-nerd" ;;
                "openSUSE") install_opensuse_system_fonts "fira-code-fonts" ;;
                "Fedora") install_font_fedora "FiraCode" ;;
            esac
            ;;

        "Meslo")
            case "$DISTRO" in
                "Arch") install_font_arch "ttf-meslo-nerd" ;;
                "openSUSE") install_opensuse_system_fonts "meslo-lg-fonts" ;;
                "Fedora") install_font_fedora "Meslo" ;;
            esac
            ;;

        "JetBrainsMono")
            case "$DISTRO" in
                "Arch") install_font_arch ttf-jetbrains-mono-nerd ttf-jetbrains-mono ;;
                "openSUSE") install_opensuse_system_fonts "jetbrains-mono-fonts" ;;
                "Fedora") install_font_fedora "JetBrainsMono" ;;
            esac
            ;;

        "Hack")
            case "$DISTRO" in
                "Arch") install_font_arch "ttf-hack-nerd" ;;
                "openSUSE") install_opensuse_system_fonts "hack-fonts" ;;
                "Fedora") install_font_fedora "Hack" ;;
            esac
            ;;

        "CascadiaMono")
            case "$DISTRO" in
                "Arch") install_font_arch ttf-cascadia-mono-nerd ttf-cascadia-code-nerd ;;
                "openSUSE") install_font_opensuse "CascadiaMono" ;;
                "Fedora") install_font_fedora "CascadiaMono" ;;
            esac
            ;;

        "Terminus")
            case "$DISTRO" in
                "Arch") install_font_arch "terminus-font" ;;
                "openSUSE") install_font_opensuse "Terminus" ;;
                "Fedora") install_font_fedora "Terminus" ;;
            esac
            ;;

        "Noto")
            case "$DISTRO" in
                "Arch") install_font_arch noto-fonts noto-fonts-emoji noto-fonts-cjk noto-fonts-extra ;;
                "openSUSE") install_opensuse_system_fonts google-noto-fonts noto-coloremoji-fonts ;;
                "Fedora") install_fedora_system_fonts google-noto-fonts google-noto-emoji-fonts ;;
            esac
            ;;

        "DejaVu")
            case "$DISTRO" in
                "Arch") install_font_arch ttf-dejavu ;;
                "openSUSE") install_opensuse_system_fonts "dejavu-fonts" ;;
                "Fedora") install_fedora_system_fonts dejavu-sans-fonts ;;
            esac
            ;;

        "JoyPixels")
            case "$DISTRO" in
                "Arch")
                    check_aur_helper
                    print_message "$GREEN" ":: Installing JoyPixels (ttf-joypixels) via $aur_helper..."
                    $aur_helper -S --noconfirm ttf-joypixels
                    print_message "$GREEN" "JoyPixels installed successfully!"
                    ;;
                "openSUSE" | "Fedora")
                    print_message "$GREEN" ":: Downloading JoyPixels font..."
                    mkdir -p "$HOME/.fonts"
                    curl -L "https://cdn.joypixels.com/arch-linux/font/8.0.0/joypixels-android.ttf" -o "$HOME/.fonts/joypixels-android.ttf"
                    print_message "$GREEN" ":: Refreshing font cache..."
                    fc-cache -vf "$HOME/.fonts"
                    print_message "$GREEN" "JoyPixels installed successfully to ~/.fonts!"
                    ;;
            esac
            ;;

        "FontAwesome")
            case "$DISTRO" in
                "Arch")
                    check_aur_helper
                    print_message "$GREEN" ":: Installing Font Awesome (ttf-font-awesome) via $aur_helper..."
                    $aur_helper -S --noconfirm ttf-font-awesome
                    print_message "$GREEN" "Font Awesome installed successfully!"
                    ;;
                "openSUSE") install_opensuse_system_fonts "fontawesome-fonts" ;;
                "Fedora") install_fedora_system_fonts fontawesome-fonts-all ;;
            esac
            ;;
    esac
}

choose_fonts() {
    while true; do
        clear
        local options=("FiraCode" "Meslo" "JetBrainsMono" "Hack" "CascadiaMono" "Terminus" "Noto" "DejaVu" "JoyPixels" "FontAwesome" "Install All Fonts" "Exit")
        show_menu "Choose fonts to install:" "${options[@]}"

        get_choice "${#options[@]}"
        choice_index=$?
        choice="${options[$((choice_index - 1))]}"

        case "$choice" in
            "Install All Fonts")
                if confirm "Install all available fonts?"; then
                    local all_fonts=("FiraCode" "Meslo" "JetBrainsMono" "Hack" "CascadiaMono" "Terminus" "Noto" "DejaVu" "JoyPixels" "FontAwesome")
                    for font in "${all_fonts[@]}"; do
                        print_message "$CYAN" "Installing $font..."
                        install_font "$font"
                        echo
                    done
                    print_message "$GREEN" "All fonts installed successfully!"
                else
                    print_message "$YELLOW" "Installation cancelled."
                fi
                ;;
            "Exit")
                exit 0
                ;;
            *)
                if confirm "Install $choice font?"; then
                    install_font "$choice"
                else
                    print_message "$YELLOW" "Installation cancelled."
                fi
                ;;
        esac

        echo
        read -rp "Press Enter to continue..."
    done
}

main() {
    check_dependencies
    print_message "$TEAL" ":: Detected OS: $DISTRO"
    echo
    choose_fonts
}

main
