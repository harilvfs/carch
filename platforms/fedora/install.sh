#!/usr/bin/env bash

# Carch Installer for Fedora
# Downloads and installs the latest Carch RPM package

VERSION="4.2.6"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m' 

USERNAME=$(whoami)

if command -v pacman &>/dev/null; then
    DISTRO="Arch Linux"
elif command -v dnf &>/dev/null; then
    DISTRO="Fedora"
elif command -v apt &>/dev/null; then
    DISTRO="Debian"
elif command -v zypper &>/dev/null; then
    DISTRO="openSUSE"
elif command -v emerge &>/dev/null; then
    DISTRO="Gentoo"
elif command -v xbps-install &>/dev/null; then
    DISTRO="Void Linux"
else
    DISTRO="Unknown Linux Distribution"
fi

ARCH=$(uname -m)

if ! command -v dnf &>/dev/null; then
    echo -e "${RED}Oops! You are using this script on a non-Fedora based distro.${NC}"
    echo -e "${RED}This script is for Fedora Linux or Fedora-based distributions.${NC}"
    exit 1
fi

TMP_DIR="/tmp/carch-install"
mkdir -p "$TMP_DIR"

typewriter() {
    text="$1"
    color="$2"
    for ((i=0; i<${#text}; i++)); do
        echo -en "${color}${text:$i:1}${NC}"
        sleep 0.03
    done
    echo ""
}

package_installed() {
    rpm -q "$1" >/dev/null 2>&1
}

install_package() {
    local package=$1
    
    if ! package_installed "$package"; then
        echo -e "${BLUE}Installing $package...${NC}"
        if sudo dnf install -y "$package" > /dev/null 2>&1; then
            echo -e "${GREEN}$package installed successfully${NC}"
        else
            echo -e "${RED}Failed to install $package${NC}"
            return 1
        fi
    else
        echo -e "${BLUE}$package is already installed${NC}"
    fi
    return 0
}

display_welcome() {
    clear
    echo -e "${GREEN}"
    cat <<"EOF"
   ____         __       ____
  /  _/__  ___ / /____ _/ / /__ ____
 _/ // _ \(_-</ __/ _ `/ / / -_) __/
/___/_//_/___/\__/\_,_/_/_/\__/_/
EOF
    echo ""
    echo "Carch Installer for Fedora or Fedora based distros."
    echo -e "${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}CARCH${NC}${CYAN}${NC}"
    echo -e "${CYAN}${WHITE}Version: $VERSION${NC}${CYAN}${NC}"
    echo -e "${CYAN}${WHITE}Distribution: $DISTRO${NC}${CYAN}${NC}"
    echo -e "${CYAN}${WHITE}Architecture: $ARCH${NC}${CYAN}${NC}"
    echo ""
    typewriter "Hey ${USERNAME}! Thanks for choosing Carch" "${MAGENTA}${BOLD}"
    sleep 0.5
    echo ""
    echo -e "${BLUE}This is the Carch fast installer for Fedora Linux.${NC}"
    sleep 0.5
    echo -e "${BLUE}This will download and install the pre-built Carch package.${NC}"
    sleep 0.5
    echo ""
}

install_dependencies() {
    echo -e "${YELLOW}Installing dependencies...${NC}"
    
    local dependencies=(
        "git" "curl" "wget" "figlet" "man-db" "bash" "rust" "cargo"
        "glibc" "unzip" "tar" "google-noto-color-emoji-fonts" "google-noto-emoji-fonts" 
        "jetbrains-mono-fonts-all" "bat" "bash-completion-devel" "zsh" "fish"
    )
    
    for dep in "${dependencies[@]}"; do
        install_package "$dep"
        sleep 0.1
    done
    
    echo -e "${GREEN}All dependencies installed.${NC}"
}

main() {
    display_welcome
    
    local response
    read -rp $'\e[33mDo you want to install Carch? (y/n): \e[0m' response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo -e "${YELLOW}Installation cancelled.${NC}"
        exit 0
    fi
    
    typewriter "Sit back and relax while we install Carch for you" "${GREEN}"
    sleep 0.5
    
    clear
    
    install_dependencies
    
    echo -e "${BLUE}Checking for latest Carch release...${NC}"

    REPO="harilvfs/carch"
    API_URL="https://api.github.com/repos/$REPO/releases/latest"

    RELEASE_INFO=$(curl -s "$API_URL")
    RPM_URL=$(echo "$RELEASE_INFO" | grep -o "https://github.com/$REPO/releases/download/[^\"]*\.rpm" | grep "$ARCH" | head -n 1)

    if [ -z "$RPM_URL" ]; then
        echo -e "${RED}Could not find RPM package for $ARCH architecture.${NC}"
        exit 1
    fi

    echo -e "${BLUE}Downloading Carch from: $RPM_URL${NC}"
    RPM_FILE="$TMP_DIR/carch.rpm"

    if curl -L "$RPM_URL" -o "$RPM_FILE"; then
        echo -e "${GREEN}Download complete!${NC}"
    else
        echo -e "${RED}Download failed.${NC}"
        exit 1
    fi

    if [ ! -f "$RPM_FILE" ] || [ ! -s "$RPM_FILE" ]; then
        echo -e "${RED}Downloaded file not found or is empty.${NC}"
        exit 1
    fi

    local install_response
    read -rp $'\e[33mCarch RPM package found. Do you want to install it now? (y/n): \e[0m' install_response
    if [[ "$install_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo -e "${BLUE}Installing Carch...${NC}"
        if sudo dnf install -y "$RPM_FILE"; then
            echo -e "${GREEN}Installation successful!${NC}"
        else
            echo -e "${RED}Installation failed.${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Installation cancelled.${NC}"
        exit 0
    fi

    if command -v carch &>/dev/null; then
        echo -e "${GREEN}Carch is now installed! Run 'carch -h' to see available options.${NC}"
    else
        echo -e "${RED}Carch installation appears to have failed. Please check for errors.${NC}"
        exit 1
    fi

    echo -e "${BLUE}Cleaning up temporary files...${NC}"
    rm -rf "$TMP_DIR"
    echo -e "${GREEN}Done!${NC}"
}

main
