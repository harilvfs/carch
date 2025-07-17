#!/bin/sh

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
    rm -rf ~/pkgs
    git clone https://github.com/carch-org/pkgs ~/pkgs
    cd ~/pkgs/carch-bin || exit 1
    makepkg -si
}

install_fedora() {
    rpm_url=$(curl -sL https://api.github.com/repos/harilvfs/carch/releases/latest | grep browser_download_url | grep '\.rpm"' | cut -d '"' -f 4)
    if [ -z "$rpm_url" ]; then
        printf "Error: Could not find RPM package URL\n"
        exit 1
    fi
    printf "%s\n" "$rpm_url" | tee /tmp/carch.rpm
    sudo dnf install -y "$rpm_url"
}

install_opensuse() {
    rpm_url=$(curl -sL https://api.github.com/repos/harilvfs/carch/releases/latest | grep browser_download_url | grep '\.rpm"' | cut -d '"' -f 4)
    if [ -z "$rpm_url" ]; then
        printf "Error: Could not find RPM package URL\n"
        exit 1
    fi
    printf "%s\n" "$rpm_url" | tee /tmp/carch.rpm
    sudo zypper install -y "$rpm_url"
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
