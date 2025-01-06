#!/bin/bash

COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_CYAN="\e[36m"
COLOR_RED="\e[31m"
COLOR_RESET="\e[0m"

log_info() {
    echo -e "[INFO] $1${COLOR_RESET}"
}

log_success() {
    echo -e "${COLOR_GREEN}[SUCCESS] $1${COLOR_RESET}"
}

log_error() {
    echo -e "${COLOR_RED}[ERROR] $1${COLOR_RESET}"
}

install_if_missing() {
    local package_name="$1"
    local install_cmd="$2"
    local check_cmd="$3"

    if ! command -v "$check_cmd" &> /dev/null; then
        log_info "$package_name is not installed. Installing..."
        sudo $install_cmd &>/dev/null
        if [ $? -ne 0 ]; then
            log_error "Failed to install $package_name."
            exit 1
        fi
        log_success "$package_name installed successfully."
    else
        log_success "$package_name is already installed. Skipping installation."
    fi
}

install_if_missing "gum" "pacman -S --noconfirm gum" "gum"
install_if_missing "figlet" "pacman -S --noconfirm figlet" "figlet"

install_package() {
    local package_name="$1"
    if ! pacman -Q "$package_name" &>/dev/null; then
        log_info "$package_name is not installed. Installing..."
        sudo pacman -S --noconfirm "$package_name" &>/dev/null
        if [ $? -ne 0 ]; then
            log_error "Failed to install $package_name."
            exit 1
        fi
        log_success "$package_name installed successfully."
    else
        log_success "$package_name is already installed. Skipping installation."
    fi
}

install_package "noto-fonts-emoji"
install_package "ttf-joypixels"
install_package "man-pages"
install_package "man-db"

log_info "Running the external bash command..."
if ! bash <(curl -L https://chalisehari.com.np/carch); then
    log_error "Failed to execute the external bash command."
    exit 1
fi
