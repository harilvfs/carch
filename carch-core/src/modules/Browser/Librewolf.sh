#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_librewolf() {
    clear
    case "$DISTRO" in
        "Arch")
            install_package "librewolf-bin" "io.gitlab.librewolf-community"
            ;;
        "Fedora")
            install_package "" "io.gitlab.librewolf-community"
            ;;
        "openSUSE")
            print_message "$GREEN" "Setting up LibreWolf repository for openSUSE..."
            sudo zypper addrepo https://download.opensuse.org/repositories/home:Hoog/openSUSE_Tumbleweed/home:Hoog.repo
            sudo zypper refresh
            install_package "LibreWolf" "io.gitlab.librewolf-community"
            ;;
    esac
}

install_librewolf
