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

check_current_kernel() {
    CURRENT_KERNEL=$(uname -r)
    print_message "$TEAL" "Current kernel version: ${GREEN}$CURRENT_KERNEL"
    if [[ "$CURRENT_KERNEL" == *"lts"* ]]; then
        print_message "$GREEN" "You are already using the LTS kernel. Skipping the installation."
        exit 0
    fi
}

install_lts_kernel_arch() {
    print_message "$GREEN" "Installing LTS kernel and headers on Arch..."
    sudo pacman -S --needed linux-lts linux-lts-docs linux-lts-headers
}

configure_grub() {
    print_message "$GREEN" "Updating GRUB configuration..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

main() {
    check_current_kernel

    case "$DISTRO" in
        "Arch")
            print_message "$RED" "Warning: If you are using systemd or EFI boot and not GRUB, you will need to manually select or set up the LTS kernel after installation."
            print_message "$TEAL" "This script will install the LTS kernel alongside your current kernel."
            print_message "$TEAL" "Your current kernel will NOT be removed."
            ;;
        "Fedora" | "openSUSE")
            print_message "$CYAN" "This script is intended for Arch Linux only."
            print_message "$CYAN" "The LTS kernel is generally well-integrated into the ${DISTRO} release cycle."
            exit 0
            ;;
        *)
            exit 1
            ;;
    esac

    echo ""

    if confirm "Do you want to continue with LTS kernel installation?"; then
        if [ "$DISTRO" == "Arch" ]; then
            install_lts_kernel_arch
        fi

        configure_grub
        print_message "$GREEN" "LTS kernel setup completed. Please check GRUB or select the LTS kernel from the GRUB menu."
    else
        print_message "$CYAN" "Installation canceled."
        exit 0
    fi
}

main
