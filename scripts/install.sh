#!/bin/sh

set -eu

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
NC='\033[0m'

detect_distro() {
    if command -v pacman > /dev/null 2>&1; then
        echo "arch"
    elif command -v dnf > /dev/null 2>&1; then
        echo "fedora"
    elif command -v zypper > /dev/null 2>&1; then
        echo "opensuse"
    else
        echo "unsupported"
    fi
}

install_arch() {
    printf "${GREEN}==> ${NC}Cloning pkgbuild repo\n"
    rm -rf ~/pkgs
    git clone https://github.com/carch-org/pkgs ~/pkgs > /dev/null 2>&1

    cd ~/pkgs/carch-bin || exit 1
    makepkg -si --noconfirm
}

install_fedora() {
    printf "${YELLOW}:: ${NC}downloading carch rpm\n"
    rpm_url=$(curl -sL https://api.github.com/repos/harilvfs/carch/releases/latest | grep browser_download_url | grep '\.rpm"' | cut -d '"' -f 4)
    if [ -z "$rpm_url" ]; then
        printf "Error: Could not find RPM package URL\n"
        exit 1
    fi
    curl -sL "$rpm_url" -o /tmp/carch.rpm > /dev/null 2>&1

    sudo dnf install -y /tmp/carch.rpm
}

install_opensuse() {
    printf "${YELLOW}:: ${NC}downloading carch rpm\n"
    rpm_url=$(curl -sL https://api.github.com/repos/harilvfs/carch/releases/latest | grep browser_download_url | grep '\.rpm"' | cut -d '"' -f 4)
    if [ -z "$rpm_url" ]; then
        printf "Error: Could not find RPM package URL\n"
        exit 1
    fi
    curl -sL "$rpm_url" -o /tmp/carch.rpm > /dev/null 2>&1

    sudo zypper install -y /tmp/carch.rpm
}

main() {
    distro=$(detect_distro)
    case "$distro" in
        arch)
            install_arch
            ;;
        fedora)
            install_fedora
            ;;
        opensuse)
            install_opensuse
            ;;
        unsupported)
            printf "Error: carch is not supported on this distribution.\n"
            exit 1
            ;;
    esac
}

main
