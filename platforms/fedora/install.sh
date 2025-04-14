#!/usr/bin/env bash

VERSION="4.3.2"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

if ! command -v dnf &>/dev/null; then
    echo -e "${RED}Error: This script requires a Fedora-based distribution.${NC}"
    exit 1
fi

ARCH=$(uname -m)
TMP_DIR="/tmp/carch-install"
mkdir -p "$TMP_DIR"

spinner() {
    local pid=$1
    local spin="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r%s" "${spin:i++%${#spin}:1}"
        sleep 0.1
    done
    printf "\r✔\n"
}

package_installed() {
    rpm -q "$1" >/dev/null 2>&1
}

install_dependencies() {
    local dependencies=(
        "git" "curl" "wget" "figlet" "man-db" "bash" "rust" "cargo"
        "glibc" "google-noto-color-emoji-fonts" "google-noto-emoji-fonts" 
        "jetbrains-mono-fonts-all" "gcc" "fzf" "bash-completion-devel"
    )
    
    for dep in "${dependencies[@]}"; do
        if ! package_installed "$dep"; then
            sudo dnf install -y "$dep" > /dev/null 2>&1
        fi
    done
}

install_carch() {
    install_dependencies

    REPO="harilvfs/carch"
    API_URL="https://api.github.com/repos/$REPO/releases/latest"
    RELEASE_INFO=$(curl -s "$API_URL")
    RPM_URL=$(echo "$RELEASE_INFO" | grep -o "https://github.com/$REPO/releases/download/[^\"]*\.rpm" | grep "$ARCH" | head -n 1)

    if [ -z "$RPM_URL" ]; then
        return 1
    fi

    curl -L "$RPM_URL" -o "$TMP_DIR/carch.rpm" > /dev/null 2>&1

    sudo dnf install -y "$TMP_DIR/carch.rpm" > /dev/null 2>&1

    if ! command -v carch &>/dev/null; then
        return 1
    fi

    return 0
}

main() {
    echo "Installing..."
    
    (install_carch) &
    PID=$!
    spinner $PID
    
    if ! command -v carch &>/dev/null; then
        echo -e "${RED}Error: Installation failed. Please check for errors.${NC}"
        rm -rf "$TMP_DIR" &>/dev/null
        exit 1
    fi

    rm -rf "$TMP_DIR" &>/dev/null
    
    echo -e "${GREEN}Carch has been successfully installed.${NC}"
}

main
