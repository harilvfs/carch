#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

print_message() {
    local color="$1"
    local message="$2"
    printf "%b:: %s%b\n" "$color" "$message" "$NC"
}

confirm() {
    while true; do
        read -p "$(printf "%b:: %s%b" "$CYAN" "$1 [y/N]: " "$NC")" answer
        case ${answer,,} in
            y | yes) return 0 ;;
            n | no | "") return 1 ;;
            *) print_message "$YELLOW" "Please answer with y/yes or n/no." ;;
        esac
    done
}

check_essential_dependencies() {
    local dependencies=("git" "wget" "curl" "tmux")
    local missing=()

    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -ne 0 ]]; then
        print_message "$YELLOW" "Please wait, installing required dependencies..."

        case "$DISTRO" in
            "Arch") sudo pacman -S --noconfirm "${missing[@]}" > /dev/null 2>&1 ;;
            "Fedora") sudo dnf install -y "${missing[@]}" > /dev/null 2>&1 ;;
            "openSUSE") sudo zypper install -y "${missing[@]}" > /dev/null 2>&1 ;;
            *)
                exit 1
                ;;
        esac
    fi
}

backup_tmux_config() {
    local config_dir="$HOME/.config/tmux"
    local backup_dir_base="$HOME/.config/carch/backups"

    if [[ -d "$config_dir" ]]; then
        print_message "$YELLOW" "Existing tmux configuration detected."
        if confirm "Do you want to backup the existing configuration?"; then
            mkdir -p "$backup_dir_base"
            local backup_path="$backup_dir_base/tmux.bak.$RANDOM"
            mv "$config_dir" "$backup_path"
            print_message "$GREEN" "Backup created: $backup_path"
        else
            print_message "$RED" "Exiting to avoid overwriting existing config."
            exit 0
        fi
    fi
}

install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [[ -d "$tpm_dir" ]]; then
        print_message "$YELLOW" "TPM is already installed."
        if confirm "Do you want to overwrite TPM?"; then
            rm -rf "$tpm_dir"
        else
            print_message "$RED" "Skipping TPM installation."
            return
        fi
    fi

    print_message "$GREEN" "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
}

setup_tmux_config() {
    local config_dir="$HOME/.config/tmux"
    mkdir -p "$config_dir"

    local config_url="https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/tmux/tmux.conf"
    print_message "$GREEN" "Downloading tmux configuration..."
    wget -O "$config_dir/tmux.conf" "$config_url"
}

install_tmux_plugins() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    local plugin_script_dir="$tpm_dir/scripts"

    if [[ -d "$plugin_script_dir" ]]; then
        print_message "$GREEN" "Installing tmux plugins..."
        cd "$plugin_script_dir" || exit
        chmod +x install_plugins.sh
        ./install_plugins.sh

        print_message "$GREEN" "Updating tmux plugins..."
        chmod +x update_plugin.sh
        ./update_plugin.sh
    else
        print_message "$RED" "TPM scripts not found. Skipping plugin installation."
    fi
}

main() {
    check_essential_dependencies
    backup_tmux_config
    install_tpm
    setup_tmux_config
    install_tmux_plugins
    print_message "$GREEN" "Tmux setup complete!"
}

main
