#!/usr/bin/env bash

set -euo pipefail

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../fzf.sh" > /dev/null 2>&1

check_brightnessctl() {
    if ! command -v brightnessctl &> /dev/null; then
        echo -e "${RED}brightnessctl is not installed!${NC}"

        if command -v pacman &> /dev/null; then
            echo -e "${YELLOW}Detected Arch-based system.${NC}"
            echo -e "${GREEN}Installing brightnessctl with pacman...${NC}"
            if sudo pacman -S --noconfirm brightnessctl; then
                echo -e "${GREEN}Installation successful!${NC}"
                sleep 1
            else
                echo -e "${RED}Installation failed. Please install manually: sudo pacman -S brightnessctl${NC}"
                exit 1
            fi

        elif command -v dnf &> /dev/null; then
            echo -e "${YELLOW}Detected Fedora-based system.${NC}"
            echo -e "${GREEN}Installing brightnessctl with dnf...${NC}"
            if sudo dnf install -y brightnessctl; then
                echo -e "${GREEN}Installation successful!${NC}"
                sleep 1
            else
                echo -e "${RED}Installation failed. Please install manually: sudo dnf install brightnessctl${NC}"
                exit 1
            fi

        elif command -v zypper &> /dev/null; then
            echo -e "${YELLOW}Detected openSUSE system.${NC}"
            echo -e "${GREEN}Installing brightnessctl with zypper...${NC}"
            if sudo zypper install -y brightnessctl; then
                echo -e "${GREEN}Installation successful!${NC}"
                sleep 1
            else
                echo -e "${RED}Installation failed. Please install manually: sudo zypper install brightnessctl${NC}"
                exit 1
            fi

        else
            echo -e "${RED}Unsupported distribution.${NC}"
            echo -e "${GREEN}Please install brightnessctl manually using your package manager.${NC}"
            exit 1
        fi
    fi
}

get_current_brightness() {
    current=$(brightnessctl info | grep "Current brightness" | awk '{print $4}' | tr -d '(%)')
    echo "$current"
}

display_brightness() {
    current=$(get_current_brightness)
    max_bars=20
    bars=$(($current * $max_bars / 100))

    progress="["
    for ((i = 0; i < $max_bars; i++)); do
        if [ $i -lt $bars ]; then
            progress+="■"
        else
            progress+="□"
        fi
    done
    progress+="]"

    echo -e "${TEAL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Current brightness: ${YELLOW}$current%${NC} $progress"
    echo -e "${TEAL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

fzf_confirm() {
    local prompt="$1"
    local options=("Yes" "No" "Back to Menu")
    local selected=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                     --height=40% \
                                                     --prompt="$prompt " \
                                                     --header="Confirm" \
                                                     --pointer="➤" \
                                                     --color='fg:white,fg+:green,bg+:black,pointer:green')
    echo "$selected"
}

fzf_select() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                     --height=40% \
                                                     --prompt="$prompt " \
                                                     --header="Select Option" \
                                                     --pointer="➤" \
                                                     --color='fg:white,fg+:blue,bg+:black,pointer:blue')
    echo "$selected"
}

increase_brightness() {
    current=$(get_current_brightness)

    if [ $((current + 5)) -gt 100 ]; then
        brightnessctl set "100%" -q
        echo -e "${GREEN}Brightness set to maximum (100%)${NC}"
    else
        brightnessctl set "5%+" -q
        echo -e "${GREEN}Brightness increased by 5%${NC}"
    fi
    sleep 1
}

decrease_brightness() {
    current=$(get_current_brightness)

    if [ $((current - 5)) -lt 5 ]; then
        brightnessctl set "5%" -q
        echo -e "${YELLOW}Brightness set to minimum (5%)${NC}"
    else
        brightnessctl set "5%-" -q
        echo -e "${GREEN}Brightness decreased by 5%${NC}"
    fi
    sleep 1
}

set_specific_brightness() {
    while true; do
        clear
        display_brightness
        echo -e "${YELLOW}Enter the desired brightness level (5-100) or type 'exit' to return to menu:${NC}"
        read -p "> " input

        if [[ "$input" == "exit" ]]; then
            echo -e "${YELLOW}Returning to main menu...${NC}"
            return
        fi

        if [[ "$input" =~ ^[0-9]+$ ]] && [ "$input" -ge 5 ] && [ "$input" -le 100 ]; then
            response=$(fzf_confirm "Set brightness to $input%?")

            case "$response" in
                "Yes")
                    brightnessctl set "$input%" -q
                    echo -e "${GREEN}Brightness set to $input%${NC}"
                    sleep 1
                    ;;
                "No")
                    echo -e "${YELLOW}Operation cancelled${NC}"
                    sleep 1
                    ;;
                "Back to Menu" | *)
                    echo -e "${YELLOW}Returning to main menu...${NC}"
                    return
                    ;;
            esac
        else
            echo -e "${RED}Invalid input. Please enter a number between 5 and 100.${NC}"
            sleep 2
        fi
    done
}

main() {
    check_fzf
    check_brightnessctl

    while true; do
        clear
        display_brightness

        choice=$(fzf_select "Select an option:" "Increase brightness (+5%)" "Decrease brightness (-5%)" "Set specific brightness" "Exit")

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
                clear
                echo -e "${GREEN}Exiting...${NC}"
                exit 0
                ;;
            *)
                clear
                echo -e "${YELLOW}No selection made. Exiting.${NC}"
                exit 0
                ;;
        esac
    done
}

main
