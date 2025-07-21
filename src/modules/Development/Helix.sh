#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

print_message() {
    local color="$1"
    local message="$2"
    printf "%b%s%b\n" "$color" "$message" "$NC"
}

confirm() {
    while true; do
        read -rp "$(printf "%b%s%b" "$CYAN" "$1 [y/N]: " "$NC")" answer
        case "${answer,,}" in
            y | yes) return 0 ;;
            n | no | "") return 1 ;;
            *) print_message "$YELLOW" "Please answer with y/yes or n/no." ;;
        esac
    done
}

if command -v pacman &> /dev/null; then
    DISTRO="arch"
elif command -v dnf &> /dev/null; then
    DISTRO="fedora"
elif command -v zypper &> /dev/null; then
    DISTRO="opensuse"
else
    echo -e "${RED}Unsupported distribution!${NC}"
    exit 1
fi

install_helix() {
    echo -e "${CYAN}Installing Helix editor...${NC}"
    if [[ "$DISTRO" == "arch" ]]; then
        sudo pacman -S --noconfirm helix noto-fonts-emoji git
    elif [[ "$DISTRO" == "fedora" ]]; then
        sudo dnf install -y helix google-noto-color-emoji-fonts google-noto-emoji-fonts git
    elif [[ "$DISTRO" == "opensuse" ]]; then
        sudo zypper install -y helix google-noto-fonts noto-coloremoji-fonts git
    fi
}

install_helix

HELIX_CONFIG="$HOME/.config/helix"
if [[ -d "$HELIX_CONFIG" ]]; then
    if confirm "Existing Helix config found. Do you want to back it up?"; then
        BACKUP_DIR="$HOME/.config/carch/backups"
        mkdir -p "$BACKUP_DIR"
        BACKUP_PATH="$BACKUP_DIR/helix.bak"
        mv "$HELIX_CONFIG" "$BACKUP_PATH"
        echo -e "${GREEN}Backup created at $BACKUP_PATH${NC}"
    fi
fi

if [[ -d "$HOME/dwm" ]]; then
    echo -e "${YELLOW}Removing existing dwm directory...${NC}"
    rm -rf "$HOME/dwm"
fi

echo -e "${CYAN}Cloning Helix configuration...${NC}"
git clone --depth=1 https://github.com/harilvfs/dwm "$HOME/dwm"

if [[ -d "$HOME/dwm/config/helix" ]]; then
    echo -e "${CYAN}Applying Helix configuration...${NC}"
    mkdir -p "$HELIX_CONFIG"
    cp -r "$HOME/dwm/config/helix/"* "$HELIX_CONFIG/"
    echo -e "${GREEN}Helix configuration applied!${NC}"
    rm -rf "$HOME/dwm"
else
    echo -e "${RED}Failed to apply Helix configuration!${NC}"
    rm -rf "$HOME/dwm"
    exit 1
fi

echo -e "${CYAN}Helix setup complete! Restart your editor to apply changes.${NC}"
