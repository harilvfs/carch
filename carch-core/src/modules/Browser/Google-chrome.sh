#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_google_chrome() {
    clear
    case "$DISTRO" in
        "Arch")
            install_package "google-chrome" "com.google.Chrome"
            ;;
        "Fedora")
            print_message "$GREEN" "Setting up Google Chrome repository..."
            sudo dnf install -y dnf-plugins-core
            sudo dnf config-manager --set-enabled google-chrome
            install_package "google-chrome-stable" "com.google.Chrome"
            ;;
        "openSUSE")
            print_message "$GREEN" "Setting up Google Chrome repository for openSUSE..."
            sudo zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64 google-chrome
            sudo rpm --import https://dl-ssl.google.com/linux/linux_signing_key.pub
            install_package "google-chrome-stable" "com.google.Chrome"
            ;;
    esac
}

install_google_chrome
