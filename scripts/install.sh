#!/bin/sh

set -eu

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

show_usage() {
    printf "Usage: %s [install|uninstall|update]\n" "$0"
    printf "  install   - Install carch (default)\n"
    printf "  uninstall - Remove carch from system\n"
    printf "  update    - Update carch to latest version\n"
    exit 1
}

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

uninstall_arch() {
    printf "${RED}==> ${NC}Removing carch from Arch Linux\n"
    sudo pacman -R carch-bin carch-bin-debug --noconfirm
}

uninstall_fedora() {
    printf "${RED}:: ${NC}Removing carch from Fedora\n"
    sudo dnf remove carch -y
}

uninstall_opensuse() {
    printf "${RED}:: ${NC}Removing carch from openSUSE\n"
    sudo zypper remove -y carch
}

update_arch() {
    printf "${GREEN}==> ${NC}Updating carch on Arch Linux\n"
    install_arch
}

update_fedora() {
    printf "${YELLOW}:: ${NC}Updating carch on Fedora\n"
    install_fedora
}

update_opensuse() {
    printf "${YELLOW}:: ${NC}Updating carch on openSUSE\n"
    install_opensuse
}

main() {
    action="${1:-install}"

    case "$action" in
        install | uninstall | update) ;;
        *)
            printf "Error: Invalid action '%s'\n" "$action"
            show_usage
            ;;
    esac

    distro=$(detect_distro)

    if [ "$distro" = "unsupported" ]; then
        printf "Error: carch is not supported on this distribution.\n"
        exit 1
    fi

    case "$action" in
        install)
            case "$distro" in
                arch) install_arch ;;
                fedora) install_fedora ;;
                opensuse) install_opensuse ;;
            esac
            ;;
        uninstall)
            case "$distro" in
                arch) uninstall_arch ;;
                fedora) uninstall_fedora ;;
                opensuse) uninstall_opensuse ;;
            esac
            ;;
        update)
            case "$distro" in
                arch) update_arch ;;
                fedora) update_fedora ;;
                opensuse) update_opensuse ;;
            esac
            ;;
    esac
}

main "$@"
