#!/usr/bin/env bash

detect_distro() {
    if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ] || [ "$(uname -o 2> /dev/null)" = "Android" ]; then
        DISTRO="Termux"
    elif [ -x "$(command -v pacman)" ]; then
        DISTRO="Arch"
    elif [ -x "$(command -v dnf)" ]; then
        DISTRO="Fedora"
    elif [ -x "$(command -v zypper)" ]; then
        DISTRO="openSUSE"
    else
        DISTRO="Unknown"
        exit 1
    fi
}

detect_distro
