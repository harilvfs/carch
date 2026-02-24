#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_floorp() {
    clear
    case "$DISTRO" in
        "Arch")
            install_package "floorp-bin" "one.ablaze.floorp"
            ;;
        "Fedora")
            print_message "$GREEN" "Setting sneexy/floorp repository"
            sudo dnf copr enable sneexy/floorp
            install_package "floorp" "one.ablaze.floorp"
            ;;
        "openSUSE")
            install_package "" "one.ablaze.floorp"
            ;;
    esac
}

install_floorp
