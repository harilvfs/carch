#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_opera() {
    clear
    case "$DISTRO" in
        "Arch")
            install_package "opera" "com.opera.Opera"
            ;;
        "Fedora")
            print_message "$GREEN" "Setting up Opera repository..."
            sudo rpm --import https://rpm.opera.com/rpmrepo.key
            echo -e "[opera]\nname=Opera packages\ntype=rpm-md\nbaseurl=https://rpm.opera.com/rpm\ngpgcheck=1\ngpgkey=https://rpm.opera.com/rpmrepo.key\nenabled=1" | sudo tee /etc/yum.repos.d/opera.repo
            install_package "opera-stable" "com.opera.Opera"
            ;;
        "openSUSE")
            install_package "opera" "com.opera.Opera"
            ;;
    esac
}

install_opera
