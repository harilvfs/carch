#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_ungoogled_chromium() {
    clear
    case "$DISTRO" in
        "Arch")
            install_package "ungoogled-chromium-bin" "io.github.ungoogled_software.ungoogled_chromium"
            ;;
        "Fedora")
            print_message "$GREEN" "Enabling COPR repository..."
            sudo dnf copr enable -y wojnilowicz/ungoogled-chromium
            install_package "ungoogled-chromium" "io.github.ungoogled_software.ungoogled_chromium"
            ;;
        "openSUSE")
            install_package "" "io.github.ungoogled_software.ungoogled_chromium"
            ;;
    esac
}

install_ungoogled_chromium
