#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_vivaldi() {
    clear
    case "$DISTRO" in
        "Arch")
            install_package "vivaldi" "com.vivaldi.Vivaldi"
            ;;
        "Fedora")
            install_package "" "com.vivaldi.Vivaldi"
            ;;
        "openSUSE")
            print_message "$GREEN" "Setting up Vivaldi repository for openSUSE..."
            sudo zypper ar https://repo.vivaldi.com/archive/vivaldi-suse.repo
            install_package "vivaldi-stable" "com.vivaldi.Vivaldi"
            ;;
    esac
}

install_vivaldi
