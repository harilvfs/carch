#!/bin/bash

clear

GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
figlet -f slant "Picom"
echo -e "${GREEN}"
cat << "EOF"
Picom is a standalone compositor for Xorg.
EOF
echo -e "${ENDCOLOR}"

detect_package_manager() {
    if command -v pacman &>/dev/null; then
        pkg_manager="pacman"
    elif command -v dnf &>/dev/null; then
        pkg_manager="dnf"
    else
        echo -e "${RED}Unsupported package manager. Please install Picom manually.${ENDCOLOR}"
        exit 1
    fi
}

install_aur_helper() {
    if ! command -v yay &>/dev/null; then
        echo -e "${RED}No AUR helper found. Installing yay...${ENDCOLOR}"
        sudo pacman -S --needed --noconfirm git base-devel
        temp_dir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
        cd "$temp_dir/yay" || { echo -e "${RED}Failed to enter yay directory${ENDCOLOR}"; exit 1; }
        makepkg -si --noconfirm
        cd ..
        rm -rf "$temp_dir"
        echo -e "${GREEN}yay installed successfully.${ENDCOLOR}"
    else
        echo -e "${GREEN}:: yay is already installed.${ENDCOLOR}"
    fi
}

print_source_message() {
    echo -e "${BLUE}:: This Picom build is from FT-Labs.${ENDCOLOR}"
    echo -e "${BLUE}:: Check out here: ${GREEN}https://github.com/FT-Labs/picom${ENDCOLOR}"
}

install_dependencies_normal() {
    echo -e "${GREEN}:: Installing Picom...${ENDCOLOR}"
    case "$pkg_manager" in
        pacman) sudo pacman -S --needed --noconfirm picom ;;
        dnf) sudo dnf install -y picom ;;
    esac
}

setup_picom_ftlabs() {
    echo -e "${GREEN}:: Installing Picom FT-Labs (picom-ftlabs-git) via yay...${ENDCOLOR}"
    yay -S --noconfirm picom-ftlabs-git
}

install_picom_ftlabs_fedora() {
    echo -e "${GREEN}:: Installing dependencies for Picom FT-Labs (Fedora)...${ENDCOLOR}"
    sudo dnf install -y dbus-devel gcc git libconfig-devel libdrm-devel libev-devel libX11-devel libX11-xcb libXext-devel libxcb-devel libGL-devel libEGL-devel libepoxy-devel meson pcre2-devel pixman-devel uthash-devel xcb-util-image-devel xcb-util-renderutil-devel xorg-x11-proto-devel xcb-util-devel cmake

    echo -e "${GREEN}:: Cloning Picom FT-Labs repository...${ENDCOLOR}"
    git clone https://github.com/FT-Labs/picom ~/.cache/picom
    cd ~/.cache/picom || { echo -e "${RED}Failed to clone Picom repo.${ENDCOLOR}"; exit 1; }

    echo -e "${GREEN}:: Building Picom with meson and ninja...${ENDCOLOR}"
    meson setup --buildtype=release build
    ninja -C build

    echo -e "${GREEN}:: Installing the built Picom binary...${ENDCOLOR}"
    sudo cp build/src/picom /usr/local/bin
    sudo ldconfig

    echo -e "${GREEN}Done...${ENDCOLOR}"
}

download_config() {
    local config_url="$1"
    local config_path="$HOME/.config/picom.conf"
    
    if [ -f "$config_path" ]; then
        echo -e "${YELLOW}:: picom.conf already exists in $HOME/.config. Do you want to overwrite it?${ENDCOLOR}"
        choice=$(gum choose "Yes" "No")
        
        case "$choice" in
            "Yes")
                echo -e "${GREEN}:: Overwriting picom.conf...${ENDCOLOR}"
                ;;
            "No")
                echo -e "${RED}:: Skipping picom.conf download...${ENDCOLOR}"
                return 0
                ;;
            *)
                echo -e "${RED}Invalid option. Exiting...${ENDCOLOR}"
                exit 1
                ;;
        esac
    fi
    
    mkdir -p ~/.config
    echo -e "${GREEN}:: Downloading Picom configuration...${ENDCOLOR}"
    wget -O "$config_path" "$config_url"
}

detect_package_manager

print_source_message

choice=$(gum choose "Picom with animation (FT-Labs)" "Picom normal" "Exit")

case "$choice" in
    "Picom with animation (FT-Labs)")
        case "$pkg_manager" in
            pacman)
                install_aur_helper
                setup_picom_ftlabs
                ;;
            dnf)
                install_picom_ftlabs_fedora
                ;;
        esac
        download_config "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/picom/picom.conf"
        echo -e "${GREEN}:: Picom setup completed with animations from FT-Labs!${ENDCOLOR}"
        ;;
    "Picom normal")
        install_dependencies_normal
        download_config "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/picom/picom.conf"
        echo -e "${GREEN}:: Picom setup completed without animations!${ENDCOLOR}"
        ;;
    "Exit")
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option. Please try again.${ENDCOLOR}"
        exit 1
        ;;
esac

