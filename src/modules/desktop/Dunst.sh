#!/usr/bin/env bash

# Configures Dunst, a lightweight and customizable notification daemon, with optimized settings for a sleek and unobtrusive experience.

BLUE="\e[34m"
RESET="\e[0m"
RED="\e[31m"
GREEN="\e[32m"

fzf_confirm() {
    local prompt="$1"
    local options=("Yes" "No")
    local selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="$prompt " --height=10 --layout=reverse --border)
    [[ "$selected" == "Yes" ]]
}

print_message() {
    local color="$1"
    shift
    echo -e "${color}$*${RESET}"
}

clear

echo -e "${BLUE}"
if command -v figlet &>/dev/null; then
    figlet -f slant "Dunst"
else
    echo "========== Dunst Setup =========="
fi
echo -e "${RESET}"

if ! fzf_confirm "This script will install and configure Dunst. Continue?"; then
    print_message "$RED" "Setup aborted by the user. Exiting..."
    exit 1
fi

if ! command -v dunst &>/dev/null; then
    print_message "$BLUE" "Dunst not found. Installing..."
    if command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm dunst || { print_message "$RED" "Failed to install Dunst. Exiting..."; exit 1; }
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y dunst || { print_message "$RED" "Failed to install Dunst. Exiting..."; exit 1; }
    else
        print_message "$RED" "Unsupported package manager. Install Dunst manually."
        exit 1
    fi
else
    print_message "$GREEN" "Dunst is already installed."
fi

DUNST_DIR="$HOME/.config/dunst"
DUNST_FILE="$DUNST_DIR/dunstrc"

if [[ -d "$DUNST_DIR" ]]; then
    print_message "$BLUE" "Backing up existing Dunst directory..."
    mv "$DUNST_DIR" "${DUNST_DIR}.bak" || { print_message "$RED" "Failed to backup Dunst directory."; exit 1; }
    print_message "$GREEN" "Backup created: ${DUNST_DIR}.bak"
fi

mkdir -p "$DUNST_DIR" || { print_message "$RED" "Failed to create ~/.config/dunst directory."; exit 1; }
print_message "$GREEN" "Created ~/.config/dunst directory."

DUNST_URL="https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/dunst/dunstrc"
DUNST_PATH="$DUNST_FILE"

print_message "$BLUE" "Downloading Dunstrc..."

spin='-\|/'
i=0

( while true; do
    printf "\r[%c] Downloading..." "${spin:i++%${#spin}}"
    sleep 0.1
done ) &
SPIN_PID=$!

if curl -fsSL "$DUNST_URL" -o "$DUNST_PATH"; then
    kill $SPIN_PID
    printf "\r[✔] Download complete!      \n"
    print_message "$GREEN" "Dunstrc successfully downloaded to $DUNST_PATH"
else
    kill $SPIN_PID
    printf "\r[✖] Download failed!      \n"
    print_message "$RED" "Failed to download Dunstrc. Exiting..."
    exit 1
fi

print_message "$GREEN" "Dunst setup completed successfully!"
