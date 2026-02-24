#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_zen_browser() {
    clear
    install_package "zen-browser-bin" "app.zen_browser.zen"
}

install_zen_browser
