#!/usr/bin/env bash
# shellcheck disable=SC2155

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_ladybird_browser() {
    clear
    print_message "$YELLOW" "=== Ladybird Browser (Nightly) ==="
    echo
    print_message "$RED" "WARNING: Ladybird is pre-alpha software, not a released browser."
    print_message "$RED" "It is only suitable for developer use and may be unstable."
    echo
    print_message "$YELLOW" "This nightly build is NOT from the upstream Ladybird developers."
    print_message "$YELLOW" "It is built by me at https://github.com/harilvfs/ladybird-nightly"
    echo
    print_message "$CYAN" "For more info: https://github.com/LadybirdBrowser/ladybird"
    echo

    if ! confirm "Do you want to proceed with the installation?"; then
        print_message "$YELLOW" "Installation cancelled."
        return
    fi

    echo
    print_message "$CYAN" "Cloning ladybird-nightly repository..."

    local temp_dir
    temp_dir=$(mktemp -d)

    if ! git clone https://github.com/harilvfs/ladybird-nightly.git "$temp_dir/ladybird-nightly"; then
        print_message "$RED" "Failed to clone repository."
        rm -rf "$temp_dir"
        return
    fi

    print_message "$GREEN" "Repository cloned successfully."
    print_message "$CYAN" "Running install script..."

    chmod +x "$temp_dir/ladybird-nightly/install.sh"

    if "$temp_dir/ladybird-nightly/install.sh"; then
        print_message "$GREEN" "Ladybird Browser (Nightly) installed successfully."
    else
        print_message "$RED" "Installation failed. Check the output above for details."
    fi

    rm -rf "$temp_dir"
}

install_ladybird_browser
