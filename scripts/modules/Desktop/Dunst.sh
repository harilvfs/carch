#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

print_message() {
    local color="$1"
    shift
    echo -e "${color}$*${NC}"
}

clear

if ! command -v dunst &> /dev/null; then
    print_message "${TEAL}" "Dunst not found. Installing..."
    case "$DISTRO" in
        "Arch") sudo pacman -Sy --noconfirm dunst ;;
        "Fedora") sudo dnf install -y dunst ;;
        "openSUSE") sudo zypper install -y dunst ;;
        *)
            exit 1
            ;;
    esac
else
    print_message "$GREEN" "Dunst is already installed."
fi

print_message "${TEAL}" "Installing papirus-icon-theme..."
case "$DISTRO" in
    "Arch") sudo pacman -Sy --noconfirm papirus-icon-theme ;;
    "Fedora") sudo dnf install -y papirus-icon-theme ;;
    "openSUSE") sudo zypper install -y papirus-icon-theme ;;
esac

DUNST_DIR="$HOME/.config/dunst"
BACKUP_DIR="$HOME/.config/carch/backups"
DUNST_FILE="$DUNST_DIR/dunstrc"

if [[ -d "$DUNST_DIR" ]]; then
    print_message "${TEAL}" "Backing up existing Dunst directory..."
    mkdir -p "$BACKUP_DIR"
    mv "$DUNST_DIR" "$BACKUP_DIR/dunst.bak"
    print_message "$GREEN" "Backup created: $BACKUP_DIR/dunst.bak"
fi

mkdir -p "$DUNST_DIR"
print_message "$GREEN" "Created ~/.config/dunst directory."

DUNST_URL="https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/dunst/dunstrc"
DUNST_PATH="$DUNST_FILE"

print_message "${TEAL}" "Downloading Dunstrc..."

spin='-\|/'
i=0

( while true; do
    printf "\r[%c] Downloading..." "${spin:i++%${#spin}}"
    sleep 0.1
done ) &
SPIN_PID=$!

if curl -fsSL "$DUNST_URL" -o "$DUNST_PATH"; then
    kill $SPIN_PID
    printf "\r[done] Download complete!      \n"
    print_message "$GREEN" "Dunstrc successfully downloaded to $DUNST_PATH"
else
    kill $SPIN_PID
    printf "\r[fail] Download failed!      \n"
    print_message "$RED" "Failed to download Dunstrc. Exiting..."
    exit 1
fi

print_message "$GREEN" "Dunst setup completed successfully!"
