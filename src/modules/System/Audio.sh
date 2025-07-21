#!/usr/bin/env bash

clear

source "$(dirname "$0")"/../colors.sh > /dev/null 2>&1

print_message() {
    local color="$1"
    local message="$2"
    printf "%b%s%b\n" "$color" "$message" "$ENDCOLOR"
}

confirm() {
    while true; do
        read -p "$(printf "%b%s%b" "$CYAN" "$1 [y/N]: " "$ENDCOLOR")" answer
        case ${answer,,} in
            y | yes) return 0 ;;
            n | no | "") return 1 ;;
            *) print_message "$YELLOW" "Please answer with y/yes or n/no." ;;
        esac
    done
}

detect_distro() {
    print_message "$TEAL" ":: Detecting distribution..."
    if command -v pacman &> /dev/null; then
        print_message "$GREEN" ":: Arch Linux detected."
        DISTRO="arch"
    elif command -v dnf &> /dev/null; then
        print_message "$GREEN" ":: Fedora detected."
        DISTRO="fedora"
    elif command -v zypper &> /dev/null; then
        print_message "$GREEN" ":: openSUSE detected."
        DISTRO="opensuse"
    else
        print_message "$RED" ":: Unsupported distribution."
        exit 1
    fi
}

check_multilib() {
    print_message "$TEAL" ":: Checking multilib repository status..."

    if grep -q '^\[multilib\]' /etc/pacman.conf; then
        print_message "$GREEN" ":: 32-bit multilib repository is already enabled."
        return 0
    elif grep -q '^\#\[multilib\]' /etc/pacman.conf; then
        print_message "$YELLOW" ":: Multilib repository found but is commented out."

        if confirm "Do you want to enable the multilib repository?"; then
            sudo cp /etc/pacman.conf /etc/pacman.conf.bak
            sudo sed -i '/^\#\[multilib\]/,+1 s/^\#//' /etc/pacman.conf
            print_message "$GREEN" ":: Multilib repository has been enabled."
            print_message "$CYAN" ":: Updating package databases..."
            sudo pacman -Sy
            return 0
        else
            print_message "$YELLOW" ":: Warning: Multilib repository is required for 32-bit applications."
            print_message "$YELLOW" ":: Some functionality may be limited."
            return 1
        fi
    else
        print_message "$RED" ":: Multilib repository not found in pacman.conf."
        return 1
    fi
}

install_pipewire() {
    print_message "$TEAL" ":: Installing PipeWire and related packages..."
    if [ "$DISTRO" = "arch" ]; then
        print_message "$CYAN" ":: Installing PipeWire packages for Arch Linux..."

        local multilib_enabled=true
        if ! check_multilib; then
            multilib_enabled=false
            print_message "$YELLOW" ":: Installing without 32-bit support..."
        fi

        if [ "$multilib_enabled" = true ]; then
            sudo pacman -S --noconfirm pipewire pipewire-alsa pipewire-jack pipewire-pulse lib32-pipewire gst-plugin-pipewire wireplumber rtkit
        else
            sudo pacman -S --noconfirm pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire wireplumber rtkit
        fi

        if [ $? -ne 0 ]; then
            print_message "$RED" ":: Failed to install PipeWire packages on Arch."
            exit 1
        fi
    elif [ "$DISTRO" = "fedora" ]; then
        print_message "$CYAN" ":: Installing PipeWire packages for Fedora..."
        sudo dnf install -y pipewire
        if [ $? -ne 0 ]; then
            print_message "$RED" ":: Failed to install PipeWire packages on Fedora."
            exit 1
        fi
    elif [ "$DISTRO" = "opensuse" ]; then
        print_message "$CYAN" ":: Installing PipeWire packages for openSUSE..."
        sudo zypper install -y pipewire rtkit wireplumber pipewire-alsa gstreamer-plugin-pipewire pipewire-pulseaudio
        if [ $? -ne 0 ]; then
            print_message "$RED" ":: Failed to install PipeWire packages on openSUSE."
            exit 1
        fi
    fi

    print_message "$GREEN" ":: PipeWire packages installed successfully."
}

setup_user_and_services() {
    print_message "$TEAL" ":: Configuring user permissions and services..."
    print_message "$CYAN" ":: Adding user to rtkit group for realtime audio processing..."
    sudo usermod -a -G rtkit "$USER"
    if [ $? -ne 0 ]; then
        print_message "$RED" ":: Failed to add user to rtkit group."
        exit 1
    fi
    print_message "$CYAN" ":: Enabling PipeWire services..."
    systemctl --user enable pipewire pipewire-pulse wireplumber
    if [ $? -ne 0 ]; then
        print_message "$RED" ":: Failed to enable PipeWire services."
        exit 1
    fi

    print_message "$GREEN" ":: User settings and services configured successfully."
}

main() {
    detect_distro
    if confirm "Do you want to install PipeWire audio system?"; then
        install_pipewire
        setup_user_and_services
        print_message "$GREEN" ":: PipeWire setup completed successfully!"
        if confirm "Do you want to log out to apply changes? (Recommended)"; then
            print_message "$TEAL" ":: Logging out to apply audio system changes..."
            sleep 2
            if command -v loginctl &> /dev/null; then
                loginctl terminate-user "$USER"
            else
                print_message "$CYAN" ":: Please log out manually to apply changes."
            fi
        else
            print_message "$CYAN" ":: Please log out or reboot your system later to apply changes."
        fi
    else
        print_message "$TEAL" ":: PipeWire installation cancelled."
    fi
}

main
