#!/bin/bash

clear

COLOR_RESET="\e[0m"
COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_CYAN="\e[36m"
COLOR_RED="\e[31m"
COLOR_BLUE="\e[34m"

TARGET_DIR="/usr/bin"
SCRIPTS_DIR="$TARGET_DIR/scripts"
DESKTOP_FILE="/usr/share/applications/carch.desktop"
MAN_PAGES_DIR="/usr/share/man/man1/carch.1"

echo -e "${COLOR_BLUE}"
figlet -f slant "Carch"
echo "Version 4.1.0"
echo -e "${COLOR_RESET}"

check_dependency() {
    local dependency="$1"
    if ! command -v "$dependency" &>/dev/null; then
        echo -e "${COLOR_RED}Error: $dependency is not installed. Install it using:${COLOR_GREEN} pacman -S $dependency.${COLOR_RESET}"
        exit 1
    fi
}

check_dependency "gum"

CHOICE=$(gum choose "Rolling Release" "Stable Release" "Cancel")
if [[ $CHOICE == "Cancel" ]]; then
    echo -e "${COLOR_RED}Installation canceled by the user.${COLOR_RESET}"
    exit 0
fi

echo -e "${COLOR_YELLOW}Removing existing installation...${COLOR_RESET}"
sudo rm -f "$TARGET_DIR/carch" "$TARGET_DIR/carch-gtk.py" "$DESKTOP_FILE" "$MAN_PAGES_DIR"
sudo rm -rf "$SCRIPTS_DIR"

download_and_install() {
    local url="$1"
    local output="$2"
    local is_executable="$3"
    echo -e "${COLOR_YELLOW}:: Downloading $(basename "$output")...${COLOR_RESET}"
    sudo curl -L "$url" --output "$output" &>/dev/null
    if [[ $is_executable == "true" ]]; then
        sudo chmod +x "$output"
    fi
}

download_scripts() {
    sudo mkdir -p "$SCRIPTS_DIR"
    download_and_install "$1" "$SCRIPTS_DIR/scripts.zip" false
    echo -e "${COLOR_YELLOW}:: Extracting scripts.zip...${COLOR_RESET}"
    sudo unzip -q "$SCRIPTS_DIR/scripts.zip" -d "$SCRIPTS_DIR"
    sudo chmod +x "$SCRIPTS_DIR"/*.sh
    sudo rm "$SCRIPTS_DIR/scripts.zip"
}

install_man_page() {
    download_and_install "$1" "$MAN_PAGES_DIR" false
    echo -e "${COLOR_YELLOW}:: Updating man database...${COLOR_RESET}"
    sudo mandb &>/dev/null
}

install_icons() {
    local icon_sizes=("16" "24" "32" "48" "64" "128" "256")
    local base_url="https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/source/logo"
    local icon_dir="/usr/share/icons/hicolor"

    echo -e "${COLOR_YELLOW}:: Downloading and installing icons...${COLOR_RESET}"
    for size in "${icon_sizes[@]}"; do
        local icon_path="$icon_dir/${size}x${size}/apps"
        sudo mkdir -p "$icon_path"
        sudo curl -L "$base_url/product_logo_${size}.png" --output "$icon_path/carch.png" &>/dev/null
    done
}

if [[ $CHOICE == "Rolling Release" ]]; then
    echo -e "${COLOR_YELLOW}:: Installing Rolling Release...${COLOR_RESET}"
    download_and_install "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/build/carch" "$TARGET_DIR/carch" true
    download_and_install "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/gtk/carch-gtk.py" "$TARGET_DIR/carch-gtk.py" true
    download_scripts "https://github.com/harilvfs/carch/raw/refs/heads/main/source/zip/scripts.zip"
    install_man_page "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/man/carch.1"
    install_icons
elif [[ $CHOICE == "Stable Release" ]]; then
    echo -e "${COLOR_YELLOW}:: Installing Stable Release...${COLOR_RESET}"
    download_and_install "https://github.com/harilvfs/carch/releases/latest/download/carch" "$TARGET_DIR/carch" true
    download_and_install "https://github.com/harilvfs/carch/releases/latest/download/carch-gtk.py" "$TARGET_DIR/carch-gtk.py" true
    download_scripts "https://github.com/harilvfs/carch/releases/latest/download/scripts.zip"
    install_man_page "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/man/carch.1"
    install_icons
fi

echo -e "${COLOR_YELLOW}:: Creating Carch Desktop Entry...${COLOR_RESET}"
sudo tee "$DESKTOP_FILE" > /dev/null <<EOL
[Desktop Entry]
Name=Carch
Comment=An automated script for quick & easy Arch Linux system setup.
Exec=$TARGET_DIR/carch
Icon=carch
Type=Application
Terminal=true
Categories=Utility;
EOL

echo -e "${COLOR_GREEN}:: Carch Desktop Entry created successfully!${COLOR_RESET}"

echo -e "${COLOR_GREEN}"
figlet -f slant "Note"
echo -e "${COLOR_CYAN}Carch has been successfully installed!${COLOR_RESET}"
echo -e "${COLOR_CYAN}Use 'carch' or 'carch --gtk' to run the script.${COLOR_RESET}"
echo -e "${COLOR_CYAN}For help, type 'carch --help'.${COLOR_RESET}"

