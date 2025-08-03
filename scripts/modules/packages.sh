#!/usr/bin/env bash

source "$(dirname "$0")/colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/detect-distro.sh" > /dev/null 2>&1

print_message() {
    local color="$1"
    local message="$2"
    printf "%b%s%b\n" "$color" "$message" "${NC}"
}

show_menu() {
    local title="$1"
    shift
    local options=("$@")

    echo
    print_message "$CYAN" "=== $title ==="
    echo

    for i in "${!options[@]}"; do
        printf "%b[%d]%b %s\n" "$GREEN" "$((i + 1))" "${NC}" "${options[$i]}"
    done
    echo
}

get_choice() {
    local max_option="$1"
    local choice

    while true; do
        read -p "$(printf "%b%s%b" "$YELLOW" "Enter your choice (1-$max_option): " "${NC}")" choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$max_option" ]; then
            return "$choice"
        else
            print_message "$RED" "Invalid choice. Please enter a number between 1 and $max_option."
        fi
    done
}

AUR_HELPER=""

detect_aur_helper() {
    for helper in paru yay; do
        if command -v $helper &> /dev/null; then
            AUR_HELPER=$helper
            return 0
        fi
    done

    echo -e "${YELLOW}:: No AUR helper found.${NC}"
    return 1
}

install_aur_helper() {
    if [ "$DISTRO" != "Arch" ]; then
        return
    fi

    detect_aur_helper
    if [ $? -eq 0 ]; then
        return
    fi

    echo -e "${RED}:: No AUR helper found. Installing yay...${NC}"

    sudo pacman -S --needed --noconfirm git base-devel

    local temp_dir
    temp_dir=$(mktemp -d)
    (   
        cd "$temp_dir"
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
    )
    local exit_code=$?
    rm -rf "$temp_dir"

    if [ $exit_code -ne 0 ]; then
        echo -e "${RED}Failed to install yay.${NC}"
        exit 1
    fi

    AUR_HELPER="yay"
    echo -e "${GREEN}:: Yay installed successfully and set as AUR helper.${NC}"
}

install_flatpak() {
    if ! command -v flatpak &> /dev/null; then
        echo -e "${YELLOW}:: Flatpak not found. Installing...${NC}"

        case "$DISTRO" in
            "Fedora") sudo dnf install -y flatpak ;;
            "openSUSE") sudo zypper install -y flatpak ;;
            "Arch") sudo pacman -S --noconfirm flatpak ;;
            *)
                exit 1
                ;;
        esac
    fi

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

install_arch_package() {
    install_aur_helper
    local package_name="$1"
    local aur_name="$2"
    local flatpak_id="$3"

    if pacman -Q "$package_name" &> /dev/null || ([ -n "$AUR_HELPER" ] && $AUR_HELPER -Q "$aur_name" &> /dev/null); then
        print_message "$GREEN" "$package_name is already installed."
        return
    fi

    if pacman -Si "$package_name" &> /dev/null; then
        print_message "$GREEN" "Installing $package_name from official repositories..."
        sudo pacman -S --noconfirm --needed "$package_name"
    elif [ -n "$AUR_HELPER" ] && $AUR_HELPER -Si "$aur_name" &> /dev/null; then
        print_message "$GREEN" "Installing $aur_name from AUR..."
        $AUR_HELPER -S --noconfirm --needed "$aur_name"
    elif [ -n "$flatpak_id" ]; then
        print_message "$YELLOW" "$package_name not found in official repositories or AUR. Falling back to Flatpak."
        install_flatpak
        flatpak install -y flathub "$flatpak_id"
    else
        print_message "$RED" "Cannot install $package_name. Package not found, no AUR fallback, and no Flatpak ID provided."
    fi
}

install_fedora_package() {
    local package_name="$1"
    local flatpak_id="$2"

    if rpm -q "$package_name" &> /dev/null; then
        print_message "$GREEN" "$package_name is already installed."
        return
    fi

    if sudo dnf info "$package_name" &> /dev/null; then
        print_message "$GREEN" "Installing $package_name from dnf..."
        sudo dnf install -y "$package_name"
    elif [ -n "$flatpak_id" ]; then
        print_message "$YELLOW" "$package_name not found in DNF. Falling back to Flatpak."
        install_flatpak
        flatpak install -y flathub "$flatpak_id"
    else
        print_message "$RED" "Cannot install $package_name. Package not found in dnf and no Flatpak ID provided."
    fi
}

install_opensuse_package() {
    local package_name="$1"
    local flatpak_id="$2"

    if rpm -q "$package_name" &> /dev/null; then
        print_message "$GREEN" "$package_name is already installed."
        return
    fi

    if sudo zypper info "$package_name" &> /dev/null; then
        print_message "$GREEN" "Installing $package_name from zypper..."
        sudo zypper install -y "$package_name"
    elif [ -n "$flatpak_id" ]; then
        print_message "$YELLOW" "$package_name not found in zypper. Falling back to Flatpak."
        install_flatpak
        flatpak install -y flathub "$flatpak_id"
    else
        print_message "$RED" "Cannot install $package_name. Package not found in zypper and no Flatpak ID provided."
    fi
}

install_package() {
    local package_name="$1"
    local flatpak_id="$2"
    local aur_name="${3:-$package_name}"

    echo
    print_message "$CYAN" "Installing $package_name..."

    case "$DISTRO" in
        "Arch")
            install_arch_package "$package_name" "$aur_name" "$flatpak_id"
            ;;
        "Fedora")
            install_fedora_package "$package_name" "$flatpak_id"
            ;;
        "openSUSE")
            install_opensuse_package "$package_name" "$flatpak_id"
            ;;
        *)
            if [ -n "$flatpak_id" ]; then
                print_message "$YELLOW" "Unsupported distribution for native packages. Falling back to Flatpak."
                install_flatpak
                flatpak install -y flathub "$flatpak_id"
            else
                print_message "$RED" "Cannot install $package_name. Unsupported distribution and no Flatpak ID provided."
            fi
            ;;
    esac
}
