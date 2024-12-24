#!/bin/bash

tput init
tput clear
export RED="\e[31m"
export GREEN="\e[32m"
export BLUE="\e[34m"
export ENDCOLOR="\e[0m"

print_banner() {
    echo -e "${BLUE}"
    figlet -f slant "SDDM"
    cat <<"EOF"
-----------------------------------
Catppuccin SDDM Theme    
https://github.com/catppuccin/sddm
------------------------------------

EOF
    echo -e "${ENDCOLOR}"
}

install_sddm() {
    if ! command -v sddm &> /dev/null; then
        echo -e "${GREEN}Installing SDDM...${ENDCOLOR}"
        if ! sudo pacman -S sddm --noconfirm; then
            echo -e "${RED}Failed to install SDDM. Exiting...${ENDCOLOR}"
            exit 1
        fi
    else
        echo -e "${GREEN}SDDM is already installed.${ENDCOLOR}"
    fi
}

install_theme() {
    local theme_dir="/usr/share/sddm/themes/"
    local theme_url="https://github.com/catppuccin/sddm/releases/download/v1.0.0/catppuccin-mocha.zip"

    if [ ! -d "$theme_dir" ]; then
        echo -e "${GREEN}Downloading Catppuccin SDDM theme...${ENDCOLOR}"
        sudo mkdir -p "$theme_dir"
        if ! sudo wget -O /tmp/catppuccin-mocha.zip "$theme_url"; then
            echo -e "${RED}Failed to download the theme. Exiting...${ENDCOLOR}"
            exit 1
        fi
        if ! sudo unzip -o /tmp/catppuccin-mocha.zip -d "$theme_dir"; then
            echo -e "${RED}Failed to unzip the theme. Exiting...${ENDCOLOR}"
            exit 1
        fi
        sudo rm /tmp/catppuccin-mocha.zip
    else
        echo -e "${GREEN}Catppuccin SDDM theme is already installed.${ENDCOLOR}"
    fi
}

set_theme() {
    echo -e "${GREEN}Setting Catppuccin as the SDDM theme...${ENDCOLOR}"
    sudo bash -c 'cat > /etc/sddm.conf <<EOF
[Theme]
Current=catppuccin-mocha
EOF'
}

print_banner

if ! gum confirm "Continue with SDDM setup?"; then
    echo -e "${RED}Setup aborted by the user.${NC}"
    exit 1
fi

echo "Proceeding with installation..."

install_sddm
install_theme
set_theme

echo -e "${GREEN}Setup complete. Please reboot your system to see the changes.${ENDCOLOR}"
