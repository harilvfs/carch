#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

print_message() {
    local color="$1"
    local message="$2"
    printf "%b:: %s%b\n" "$color" "$message" "$NC"
}

check_multilib() {
    print_message "$TEAL" "Checking multilib repository status..."

    if grep -q '^\[multilib\]' /etc/pacman.conf; then
        print_message "$GREEN" "32-bit multilib repository is already enabled."
        return 0
    elif grep -q '^\#\[multilib\]' /etc/pacman.conf; then
        print_message "$YELLOW" "Multilib repository found but is commented out."

        local backup_dir="$HOME/.config/carch/backups"
        local backup_path="$backup_dir/pacman.conf.bak.$RANDOM"
        print_message "$CYAN" "Backing up /etc/pacman.conf to $backup_path..."
        mkdir -p "$backup_dir"
        sudo cp -r /etc/pacman.conf "$backup_path"
        sudo sed -i '/^\#\[multilib\]/,+1 s/^\#//' /etc/pacman.conf
        print_message "$GREEN" "Multilib repository has been enabled."
        print_message "$CYAN" "Updating package databases..."
        sudo pacman -Sy
        return 0
    else
        print_message "$RED" "Multilib repository not found in pacman.conf."
        return 1
    fi
}

install_pipewire() {
    print_message "$TEAL" "Installing PipeWire and related packages..."
    case "$DISTRO" in
        "Arch")
            print_message "$CYAN" "Installing PipeWire packages for Arch Linux..."

            local multilib_enabled=true
            if ! check_multilib; then
                multilib_enabled=false
                print_message "$YELLOW" "Installing without 32-bit support..."
            fi

            if [ "$multilib_enabled" = true ]; then
                sudo pacman -S --noconfirm pipewire pipewire-alsa pipewire-jack pipewire-pulse lib32-pipewire gst-plugin-pipewire wireplumber rtkit
            else
                sudo pacman -S --noconfirm pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire wireplumber rtkit
            fi

            if [ $? -ne 0 ]; then
                print_message "$RED" "Failed to install PipeWire packages on Arch."
                exit 1
            fi
            ;;
        "Fedora")
            print_message "$CYAN" "Installing PipeWire packages for Fedora..."
            sudo dnf install -y pipewire
            if [ $? -ne 0 ]; then
                print_message "$RED" "Failed to install PipeWire packages on Fedora."
                exit 1
            fi
            ;;
        "openSUSE")
            print_message "$CYAN" "Installing PipeWire packages for openSUSE..."
            sudo zypper install -y pipewire rtkit wireplumber pipewire-alsa gstreamer-plugin-pipewire pipewire-pulseaudio
            if [ $? -ne 0 ]; then
                print_message "$RED" "Failed to install PipeWire packages on openSUSE."
                exit 1
            fi
            ;;
    esac

    print_message "$GREEN" "PipeWire packages installed successfully."
}

setup_user_and_services() {
    print_message "$TEAL" "Configuring user permissions and services..."
    print_message "$CYAN" "Adding user to rtkit group for realtime audio processing..."
    sudo usermod -a -G rtkit "$USER"
    if [ $? -ne 0 ]; then
        print_message "$RED" "Failed to add user to rtkit group."
        exit 1
    fi
    print_message "$CYAN" "Enabling PipeWire services..."
    systemctl --user enable pipewire pipewire-pulse wireplumber
    if [ $? -ne 0 ]; then
        print_message "$RED" "Failed to enable PipeWire services."
        exit 1
    fi

    print_message "$GREEN" "User settings and services configured successfully."
}

main() {
    install_pipewire
    setup_user_and_services
    print_message "$GREEN" "PipeWire setup completed successfully!"
    print_message "$CYAN" "Please log out or reboot your system later to apply changes."
}

main
