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
        read -p "$(printf "%b%s%b" "$CYAN" "$1 [y/N]: " "$ENDCOLOR")" answer
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

check_brightnessctl() {
    if ! command -v brightnessctl &> /dev/null; then
        print_message "$RED" "brightnessctl is not installed!"

        if [ -n "$DISTRO" ]; then
            print_message "$YELLOW" "Attempting to install brightnessctl..."
            if confirm "Do you want to install brightnessctl now?"; then
                case "$DISTRO" in
                    "Arch") sudo pacman -S --noconfirm brightnessctl ;;
                    "Fedora") sudo dnf install -y brightnessctl ;;
                    "openSUSE") sudo zypper install -y brightnessctl ;;
                esac
                if [ $? -eq 0 ]; then
                    print_message "$GREEN" "Installation successful!"
                else
                    print_message "$RED" "Installation failed. Please install brightnessctl manually."
                    exit 1
                fi
            else
                print_message "$RED" "brightnessctl is required to proceed. Exiting."
                exit 1
            fi
        else
            print_message "$RED" "Unsupported distribution. Please install brightnessctl manually."
            exit 1
        fi
    fi
}

get_current_brightness() {
    brightnessctl info | grep "Current brightness" | awk '{print $4}' | tr -d '(%)'
}

display_brightness() {
    local current
    current=$(get_current_brightness)
    local max_bars=20
    local bars=$((current * max_bars / 100))

    local progress="["
    for ((i = 0; i < max_bars; i++)); do
        if [ $i -lt $bars ]; then
            progress+="■"
        else
            progress+="□"
        fi
    done
    progress+="]"

    print_message "$TEAL" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${CYAN}Current brightness: ${YELLOW}$current%${ENDCOLOR} $progress"
    print_message "$TEAL" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

increase_brightness() {
    local current
    current=$(get_current_brightness)

    if [ $((current + 5)) -gt 100 ]; then
        brightnessctl set "100%" -q
        print_message "$GREEN" "Brightness set to maximum (100%)"
    else
        brightnessctl set "5%+" -q
        print_message "$GREEN" "Brightness increased by 5%"
    fi
    sleep 1
}

decrease_brightness() {
    local current
    current=$(get_current_brightness)

    if [ $((current - 5)) -lt 5 ]; then
        brightnessctl set "5%" -q
        print_message "$YELLOW" "Brightness set to minimum (5%)"
    else
        brightnessctl set "5%-" -q
        print_message "$GREEN" "Brightness decreased by 5%"
    fi
    sleep 1
}

set_specific_brightness() {
    while true; do
        clear
        display_brightness
        read -p "$(printf "%b%s%b" "$YELLOW" "Enter desired brightness (5-100) or 'q' to return: " "$ENDCOLOR")" input

        if [[ "$input" == "q" || "$input" == "Q" ]]; then
            return
        fi

        if [[ "$input" =~ ^[0-9]+$ ]] && [ "$input" -ge 5 ] && [ "$input" -le 100 ]; then
            if confirm "Set brightness to $input%?"; then
                brightnessctl set "$input%" -q
                print_message "$GREEN" "Brightness set to $input%"
                sleep 1
                return
            else
                print_message "$YELLOW" "Operation cancelled."
                sleep 1
            fi
        else
            print_message "$RED" "Invalid input. Please enter a number between 5 and 100."
            sleep 2
        fi
    done
}

main() {
    check_brightnessctl

    while true; do
        clear
        display_brightness

        local options=("Increase brightness (+5%)" "Decrease brightness (-5%)" "Set specific brightness" "Exit")
        show_menu "Brightness Control" "${options[@]}"

        get_choice "${#options[@]}"
        choice_index=$?
        choice="${options[$((choice_index - 1))]}"

        case "$choice" in
            "Increase brightness (+5%)")
                increase_brightness
                ;;
            "Decrease brightness (-5%)")
                decrease_brightness
                ;;
            "Set specific brightness")
                set_specific_brightness
                ;;
            "Exit")
                exit 0
                ;;
        esac
    done
}

main
