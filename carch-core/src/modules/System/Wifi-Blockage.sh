#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

# export sbin path to user path because rfkill won't be detected when running directly without sudo if /usr/sbin isn't in PATH
export PATH="$PATH:/usr/sbin"

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

# these are the radio switch modules from different vendors
PLATFORM_MODULES=(
    "Dell|dell_rbtn|blacklist-dell-rbtn.conf"
    "HP|hp_wmi|blacklist-hp-wmi.conf"
    "HP|hp_wireless|blacklist-hp-wireless.conf"
    "Lenovo IdeaPad|ideapad_laptop|blacklist-ideapad-laptop.conf"
    "Acer|acer_wmi|blacklist-acer-wmi.conf"
    "Asus|asus_nb_wmi|blacklist-asus-nb-wmi.conf"
)

DETECTED_MODULES=()

detect_wireless_hardware() {
    print_message "$TEAL" "Detecting wireless hardware..."

    if command -v lspci &> /dev/null; then
        local wireless_pci
        wireless_pci=$(lspci -nn | grep -iE 'network|wireless|wifi|atheros|qualcomm|broadcom|intel|realtek' 2> /dev/null)
        if [ -n "$wireless_pci" ]; then
            print_message "$CYAN" "PCI Wireless devices detected:"
            echo "$wireless_pci" | while IFS= read -r line; do
                printf "  %b•%b %s\n" "$YELLOW" "$NC" "$line"
            done
        else
            print_message "$YELLOW" "No PCI wireless devices found via lspci."
        fi
    fi

    if command -v lsusb &> /dev/null; then
        local wireless_usb
        wireless_usb=$(lsusb | grep -iE 'wireless|wifi|bluetooth|atheros|qualcomm|broadcom' 2> /dev/null)
        if [ -n "$wireless_usb" ]; then
            print_message "$CYAN" "USB wireless devices detected:"
            echo "$wireless_usb" | while IFS= read -r line; do
                printf "  %b•%b %s\n" "$YELLOW" "$NC" "$line"
            done
        fi
    fi

    print_message "$TEAL" "Checking for loaded wireless drivers..."
    lsmod | grep -iE 'ath|iwl|b43|brcm|rtl|wil621|wl' | while IFS= read -r line; do
        printf "  %b•%b %s\n" "$GREEN" "$NC" "$line"
    done
}

check_rfkill_status() {
    print_message "$TEAL" "Checking rfkill status..."

    if ! command -v rfkill &> /dev/null; then
        print_message "$YELLOW" "rfkill not found. Ensure util-linux is installed."
        return 1
    fi

    local rfkill_output
    rfkill_output=$(rfkill list 2> /dev/null)

    if [ -z "$rfkill_output" ]; then
        print_message "$GREEN" "No rfkill devices found. Wireless should be unblocked."
        return 0
    fi

    printf "%s\n" "$rfkill_output" | while IFS= read -r line; do
        printf "  %b•%b %s\n" "$CYAN" "$NC" "$line"
    done

    local blocked
    blocked=$(rfkill list | grep -c "Hard blocked: yes")
    local soft_blocked
    soft_blocked=$(rfkill list | grep -c "Soft blocked: yes")

    if [ "$blocked" -gt 0 ]; then
        print_message "$RED" "Detected $blocked device(s) with HARD block."
    else
        print_message "$GREEN" "No hard-blocked devices detected."
    fi

    if [ "$soft_blocked" -gt 0 ]; then
        print_message "$YELLOW" "Detected $soft_blocked device(s) with SOFT block."
    else
        print_message "$GREEN" "No soft-blocked devices detected."
    fi

    return "$((blocked + soft_blocked))"
}

check_platform_blockage() {
    print_message "$TEAL" "Checking for platform modules known to falsely block wireless..."
    echo

    DETECTED_MODULES=()

    for entry in "${PLATFORM_MODULES[@]}"; do
        local vendor="${entry%%|*}"
        local rest="${entry#*|}"
        local module="${rest%%|*}"
        local conf="${rest#*|}"

        if lsmod | grep -qw "$module"; then
            print_message "$YELLOW" "$vendor: '$module' module is currently loaded (known to falsely block wireless)."
            DETECTED_MODULES+=("$module|$conf")
        fi
    done

    if [ ${#DETECTED_MODULES[@]} -eq 0 ]; then
        print_message "$GREEN" "No known problematic platform modules detected."

        for entry in "${PLATFORM_MODULES[@]}"; do
            local rest="${entry#*|}"
            local conf="${rest#*|}"
            local blacklist_path="/etc/modprobe.d/$conf"
            if [ -f "$blacklist_path" ]; then
                local module="${rest%%|*}"
                print_message "$GREEN" "  $module is already blacklisted ($blacklist_path)."
            fi
        done

        return 1
    fi

    return 0
}

fix_wifi_blockage() {
    print_message "$TEAL" "Applying fix for wireless blockage..."

    for detected in "${DETECTED_MODULES[@]}"; do
        local module="${detected%%|*}"
        local conf="${detected#*|}"
        local blacklist_path="/etc/modprobe.d/$conf"

        if lsmod | grep -qw "$module"; then
            print_message "$CYAN" "Removing $module module..."
            sudo modprobe -r "$module"
            if [ $? -ne 0 ]; then
                print_message "$RED" "Failed to remove $module module."
                exit 1
            fi
            print_message "$GREEN" "$module module removed successfully."
        else
            print_message "$CYAN" "$module is not currently loaded, skipping removal."
        fi

        if [ ! -f "$blacklist_path" ]; then
            print_message "$CYAN" "Blacklisting $module to prevent loading on boot..."
            echo "blacklist $module" | sudo tee "$blacklist_path" > /dev/null
            if [ $? -ne 0 ]; then
                print_message "$RED" "Failed to create $blacklist_path"
                exit 1
            fi
            print_message "$GREEN" "$module blacklisted in $blacklist_path"
        else
            print_message "$GREEN" "$module is already blacklisted in $blacklist_path"
        fi
    done

    print_message "$CYAN" "Unblocking all wireless devices via rfkill..."
    sudo rfkill unblock all
    if [ $? -ne 0 ]; then
        print_message "$RED" "Failed to unblock rfkill devices."
        exit 1
    fi
    print_message "$GREEN" "All wireless devices unblocked."

    print_message "$CYAN" "Bringing wireless interfaces up..."
    for iface in /sys/class/net/wl*; do
        if [ -d "$iface" ]; then
            local name
            name=$(basename "$iface")
            print_message "$CYAN" "  Bringing up $name..."
            sudo ip link set "$name" up 2> /dev/null
            if [ $? -eq 0 ]; then
                print_message "$GREEN" "  $name is now up."
            else
                print_message "$YELLOW" "  Could not bring $name up (may not exist yet)."
            fi
        fi
    done

    for iface in /sys/class/net/wlan*; do
        if [ -d "$iface" ]; then
            local name
            name=$(basename "$iface")
            if ! ip link show "$name" | grep -q "state UP"; then
                print_message "$CYAN" "  Bringing up $name..."
                sudo ip link set "$name" up 2> /dev/null
                if [ $? -eq 0 ]; then
                    print_message "$GREEN" "  $name is now up."
                fi
            fi
        fi
    done

    print_message "$GREEN" "Fix applied successfully!"
}

main() {
    print_message "$TEAL" "=== Wireless Blockage Fix ==="
    echo

    detect_wireless_hardware
    echo

    check_rfkill_status
    local rfkill_return=$?
    echo

    check_platform_blockage
    local platform_detected=$?
    echo

    if [ "$rfkill_return" -eq 0 ] && [ "$platform_detected" -ne 0 ]; then
        print_message "$GREEN" "No wireless blockage detected. Your wireless should be working correctly."
        echo

        # rfkill unblock command when nothing is blocked won't break anything. this is just for kind of safety measure.
        if confirm "Run rfkill unblock and bring interfaces up as a safety measure?"; then
            print_message "$CYAN" "Unblocking all wireless devices via rfkill..."
            sudo rfkill unblock all
            print_message "$CYAN" "Bringing wireless interfaces up..."
            for iface in /sys/class/net/wl* /sys/class/net/wlan*; do
                if [ -d "$iface" ]; then
                    sudo ip link set "$(basename "$iface")" up 2> /dev/null
                fi
            done
            print_message "$GREEN" "Done."
        else
            print_message "$GREEN" "No changes made."
        fi
    else
        if [ "$platform_detected" -eq 0 ]; then
            print_message "$YELLOW" "Detected platform module(s) known to falsely block wireless."
        fi
        echo
        if confirm "Do you want to apply the fix for wireless blockage?"; then
            fix_wifi_blockage
            echo
            print_message "$GREEN" "Fix completed. Please restart your network manager or reboot for changes to take full effect."

            if command -v systemctl &> /dev/null; then
                if confirm "Do you want to restart NetworkManager now?"; then
                    sudo systemctl restart NetworkManager
                fi
            fi
        else
            print_message "$YELLOW" "Fix skipped. You can re-run the script anytime."
        fi
    fi
}

main
