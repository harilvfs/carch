#!/usr/bin/env bash
# shellcheck disable=SC2034

detect_distro() {
    if [ -x "$(command -v pacman)" ]; then
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
