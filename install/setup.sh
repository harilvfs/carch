#!/bin/bash

COLOR_RESET="\e[0m"
COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_CYAN="\e[36m"

TARGET_DIR="/usr/bin"
SCRIPTS_DIR="$TARGET_DIR/scripts"
DESKTOP_FILE="/usr/share/applications/carch.desktop"

if ! command -v gum &> /dev/null; then
    echo -e "${COLOR_RED}Error: gum is not installed. Please install gum first using:${COLOR_GREEN} pacman -S gum.${COLOR_RESET}"
    exit 1
fi

CHOICE=$(gum choose "Rolling Release" "Stable Release")

echo -e "${COLOR_YELLOW}Removing existing installation...${COLOR_RESET}"
sudo rm -f "$TARGET_DIR/carch" "$TARGET_DIR/carch-gtk.py" "$DESKTOP_FILE"
sudo rm -rf "$SCRIPTS_DIR"

if [[ $CHOICE == "Rolling Release" ]]; then
    echo -e "${COLOR_YELLOW}Installing Rolling Release...${COLOR_RESET}"

    sudo curl -L "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/build/carch" --output "$TARGET_DIR/carch" &> /dev/null
    sudo chmod +x "$TARGET_DIR/carch"

    sudo curl -L "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/gtk/carch-gtk.py" --output "$TARGET_DIR/carch-gtk.py" &> /dev/null
    sudo chmod +x "$TARGET_DIR/carch-gtk.py"

    sudo curl -L "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/carch.desktop" --output "$DESKTOP_FILE" &> /dev/null

    echo -e "${COLOR_YELLOW}Downloading additional scripts.zip...${COLOR_RESET}"
    sudo mkdir -p "$SCRIPTS_DIR"
    sudo curl -L "https://github.com/harilvfs/carch/releases/latest/download/scripts.zip" --output "$SCRIPTS_DIR/scripts.zip" &> /dev/null

    echo -e "${COLOR_YELLOW}Extracting scripts.zip...${COLOR_RESET}"
    sudo unzip -q "$SCRIPTS_DIR/scripts.zip" -d "$SCRIPTS_DIR"
    sudo chmod +x "$SCRIPTS_DIR"/*.sh
    sudo rm "$SCRIPTS_DIR/scripts.zip"

elif [[ $CHOICE == "Stable Release" ]]; then
    echo -e "${COLOR_YELLOW}Installing Stable Release...${COLOR_RESET}"

    sudo curl -L "https://github.com/harilvfs/carch/releases/latest/download/carch" --output "$TARGET_DIR/carch" &> /dev/null
    sudo chmod +x "$TARGET_DIR/carch"

    sudo curl -L "https://github.com/harilvfs/carch/releases/latest/download/carch-gtk.py" --output "$TARGET_DIR/carch-gtk.py" &> /dev/null
    sudo chmod +x "$TARGET_DIR/carch-gtk.py"

    echo -e "${COLOR_YELLOW}Downloading additional scripts.zip...${COLOR_RESET}"
    sudo mkdir -p "$SCRIPTS_DIR"
    sudo curl -L "https://github.com/harilvfs/carch/releases/latest/download/scripts.zip" --output "$SCRIPTS_DIR/scripts.zip" &> /dev/null

    echo -e "${COLOR_YELLOW}Extracting scripts.zip...${COLOR_RESET}"
    sudo unzip -q "$SCRIPTS_DIR/scripts.zip" -d "$SCRIPTS_DIR"
    sudo chmod +x "$SCRIPTS_DIR"/*.sh
    sudo rm "$SCRIPTS_DIR/scripts.zip"

    echo -e "${COLOR_GREEN}Scripts installed successfully!${COLOR_RESET}"
fi

echo -e "${COLOR_YELLOW}Creating Carch Desktop Entry...${COLOR_RESET}"
sudo tee "$DESKTOP_FILE" > /dev/null <<EOL
[Desktop Entry]
Name=Carch
Comment=An automated script for quick & easy Arch Linux system setup.
Exec=$TARGET_DIR/carch
Icon=utilities-terminal
Type=Application
Terminal=true
Categories=Utility;
EOL

echo -e "${COLOR_GREEN}Carch Desktop Entry created successfully!${COLOR_RESET}"
echo -e "${COLOR_GREEN}Installation complete!${COLOR_RESET}"

