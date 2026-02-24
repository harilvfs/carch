#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_qutebrowser() {
    clear
    install_package "qutebrowser" "org.qutebrowser.qutebrowser"
}

install_qutebrowser
