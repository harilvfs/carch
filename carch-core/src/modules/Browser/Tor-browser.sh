#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_tor_browser() {
    clear
    case "$DISTRO" in
        "Arch")
            install_package "tor-browser-bin" "org.torproject.torbrowser-launcher"
            ;;
        "Fedora")
            install_package "" "org.torproject.torbrowser-launcher"
            ;;
        "openSUSE")
            install_package "torbrowser-launcher" "org.torproject.torbrowser-launcher"
            ;;
    esac
}

install_tor_browser
