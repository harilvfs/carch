#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

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

get_current_user() {
    if [ -n "$SUDO_USER" ]; then
        echo "$SUDO_USER"
    else
        echo "$USER"
    fi
}

check_autologin_enabled() {
    if [ -d "/etc/systemd/system/getty@tty1.service.d" ] && [ -f "/etc/systemd/system/getty@tty1.service.d/autologin.conf" ]; then
        return 0
    else
        return 1
    fi
}

print_security_warning() {
    echo
    print_message "$RED" "WARNING"
    print_message "$YELLOW" "Enabling autologin allows anyone with physical access to your system"
    print_message "$YELLOW" "to login without entering a password or username."
    echo
}

enable_autologin() {
    local username
    username=$(get_current_user)

    print_security_warning

    if ! confirm "Do you want to continue and enable autologin for user '$username'?"; then
        print_message "$GREEN" ":: Autologin setup cancelled."
        return
    fi

    print_message "$GREEN" ":: Creating autologin configuration..."

    if ! sudo mkdir -p /etc/systemd/system/getty@tty1.service.d; then
        print_message "$RED" "Failed to create autologin directory."
        return 1
    fi

    cat << EOF | sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf > /dev/null
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $username --noclear %I 38400 linux
EOF

    if [ $? -eq 0 ]; then
        print_message "$GREEN" ":: Autologin configuration created successfully."
        print_message "$GREEN" ":: Reloading systemd daemon..."

        if sudo systemctl daemon-reload; then
            print_message "$GREEN" ":: Autologin enabled for user '$username' on tty1."
            print_message "$TEAL" ":: Changes will take effect after next reboot."
        else
            print_message "$RED" "Failed to reload systemd daemon."
            return 1
        fi
    else
        print_message "$RED" "Failed to create autologin configuration."
        return 1
    fi
}

remove_autologin() {
    if ! check_autologin_enabled; then
        print_message "$RED" ":: Autologin is not currently enabled."
        print_message "$YELLOW" ":: Nothing to remove."
        return
    fi

    print_message "$GREEN" ":: Autologin configuration found."

    if confirm "Remove autologin configuration?"; then
        print_message "$GREEN" ":: Removing autologin configuration..."

        if sudo rm -rf /etc/systemd/system/getty@tty1.service.d; then
            print_message "$GREEN" ":: Autologin configuration removed successfully."
            print_message "$GREEN" ":: Reloading systemd daemon..."

            if sudo systemctl daemon-reload; then
                print_message "$GREEN" ":: Autologin disabled successfully."
                print_message "$TEAL" ":: Changes will take effect after next reboot."
            else
                print_message "$RED" "Failed to reload systemd daemon."
                return 1
            fi
        else
            print_message "$RED" "Failed to remove autologin configuration."
            return 1
        fi
    else
        print_message "$GREEN" ":: Autologin removal cancelled."
    fi
}

check_systemd() {
    if ! command -v systemctl &> /dev/null; then
        print_message "$RED" "systemctl not found. This script requires systemd."
        exit 1
    fi
}

print_current_status() {
    echo
    print_message "$CYAN" "=== Current Autologin Status ==="
    if check_autologin_enabled; then
        print_message "$GREEN" ":: Autologin is currently ENABLED"
        local current_user
        current_user=$(grep "autologin" /etc/systemd/system/getty@tty1.service.d/autologin.conf 2> /dev/null | sed 's/.*--autologin \([^ ]*\).*/\1/')
        if [ -n "$current_user" ]; then
            print_message "$TEAL" ":: Configured for user: $current_user"
        fi
    else
        print_message "$RED" ":: Autologin is currently DISABLED"
    fi
    echo
}

main() {
    check_systemd
    print_current_status

    local options=("Enable autologin" "Remove autologin" "Exit")
    show_menu "TTY Autologin Manager:" "${options[@]}"

    get_choice "${#options[@]}"
    choice_index=$?
    choice="${options[$((choice_index - 1))]}"

    case "$choice" in
        "Enable autologin")
            enable_autologin
            ;;
        "Remove autologin")
            remove_autologin
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
