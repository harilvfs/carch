#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_brave() {
    clear
    case "$DISTRO" in
        "Arch")
            install_package "brave-bin" "com.brave.Browser"
            ;;
        "Fedora")
            print_message "$GREEN" "Setting up Brave repository..."
            sudo dnf install -y dnf-plugins-core
            sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
            sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
            install_package "brave-browser" "com.brave.Browser"
            ;;
        "openSUSE")
            print_message "$GREEN" "Setting up Brave repository for openSUSE..."
            sudo zypper install -y curl
            sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
            sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
            install_package "brave-browser" "com.brave.Browser"
            ;;
    esac
}

install_brave
