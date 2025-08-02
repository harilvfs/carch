#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

print_message() {
    local color="$1"
    local message="$2"
    printf "%b%s%b\n" "$color" "$message" "$ENDCOLOR"
}

install_bluetooth() {
    print_message "$TEAL" ":: Installing Bluetooth packages..."

    case "$DISTRO" in
        "Arch")
            print_message "$CYAN" ":: Installing Bluetooth packages for Arch Linux..."
            sudo pacman -S --noconfirm bluez bluez-utils blueman
            ;;
        "Fedora")
            print_message "$CYAN" ":: Installing Bluetooth packages for Fedora..."
            sudo dnf install -y bluez bluez-tools blueman
            ;;
        "openSUSE")
            print_message "$CYAN" ":: Installing Bluetooth packages for openSUSE..."
            sudo zypper install -y bluez blueman
            ;;
        *)
            print_message "$RED" ":: Unsupported distribution."
            exit 1
            ;;
    esac

    if [ $? -ne 0 ]; then
        print_message "$RED" ":: Failed to install Bluetooth packages on ${DISTRO}."
        exit 1
    fi

    print_message "$GREEN" ":: Bluetooth packages installed successfully."
}

enable_bluetooth() {
    print_message "$TEAL" ":: Enabling Bluetooth service..."
    sudo systemctl enable --now bluetooth.service
    if [ $? -ne 0 ]; then
        print_message "$RED" ":: Failed to enable Bluetooth service."
        exit 1
    fi
    print_message "$GREEN" ":: Bluetooth service enabled successfully."
}

provide_additional_info() {
    print_message "$TEAL" ":: Additional Information:"
    echo -e "${CYAN}:: • To pair a device: Use the Blueman applet or 'bluetoothctl' in terminal${ENDCOLOR}"
    echo -e "${CYAN}:: • To access Bluetooth settings: Use the Blueman application${ENDCOLOR}"
    echo -e "${CYAN}:: • To pair via terminal: Run 'bluetoothctl', then 'power on', 'scan on', 'pair MAC_ADDRESS'${ENDCOLOR}"
}

main() {
    install_bluetooth
    enable_bluetooth
    print_message "$GREEN" ":: Bluetooth setup completed successfully!"
    provide_additional_info

    if confirm "Do you want to restart the Bluetooth service now?"; then
        print_message "$TEAL" ":: Restarting Bluetooth service..."
        sudo systemctl restart bluetooth.service
        print_message "$GREEN" ":: Bluetooth service restarted."
    fi
}

main
