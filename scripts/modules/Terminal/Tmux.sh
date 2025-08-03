#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

confirm() {
    while true; do
        read -p "$(echo -e "${CYAN}$1 [y/N]: ${NC}")" answer
        case ${answer,,} in
            y | yes) return 0 ;;
            n | no | "") return 1 ;;
            *) echo -e "${YELLOW}Please answer with y/yes or n/no.${NC}" ;;
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
        echo "Please wait, installing required dependencies..."

        case "$DISTRO" in
            "Arch") sudo pacman -S --noconfirm "${missing[@]}" > /dev/null 2>&1 ;;
            "Fedora") sudo dnf install -y "${missing[@]}" > /dev/null 2>&1 ;;
            "openSUSE") sudo zypper install -y "${missing[@]}" > /dev/null 2>&1 ;;
            *)
                echo -e "${RED}Unsupported package manager. Install dependencies manually.${NC}"
                exit 1
                ;;
        esac
    fi
}

check_essential_dependencies

config_dir="$HOME/.config/tmux"
backup_dir="$HOME/.config/carch/backups/tmux.bak"

if [[ -d "$config_dir" ]]; then
    echo -e "${YELLOW}Existing tmux configuration detected.${NC}"
    if confirm "Do you want to backup the existing configuration?"; then
        mkdir -p "$(dirname "$backup_dir")"
        if [[ -d "$backup_dir" ]]; then
            echo -e "${YELLOW}Backup already exists.${NC}"
            if confirm "Do you want to overwrite the backup?"; then
                rm -rf "$backup_dir"
            else
                echo -e "${RED}Exiting to prevent data loss.${NC}"
                exit 0
            fi
        fi
        mv "$config_dir" "$backup_dir"
    else
        echo -e "${RED}Exiting to avoid overwriting existing config.${NC}"
        exit 0
    fi
fi

tpm_dir="$HOME/.tmux/plugins/tpm"

if [[ -d "$tpm_dir" ]]; then
    echo -e "${YELLOW}TPM is already installed.${NC}"
    if confirm "Do you want to overwrite TPM?"; then
        rm -rf "$tpm_dir"
    else
        echo -e "${RED}Skipping TPM installation.${NC}"
    fi
fi

echo -e "${GREEN}Cloning TPM...${NC}"
git clone https://github.com/tmux-plugins/tpm "$tpm_dir"

mkdir -p "$config_dir"

config_url="https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/tmux/tmux.conf"
echo -e "${GREEN}Downloading tmux configuration...${NC}"
wget -O "$config_dir/tmux.conf" "$config_url"

plugin_script_dir="$tpm_dir/scripts"

if [[ -d "$plugin_script_dir" ]]; then
    echo -e "${GREEN}Installing tmux plugins...${NC}"
    cd "$plugin_script_dir" || exit
    chmod +x install_plugins.sh
    ./install_plugins.sh

    echo -e "${GREEN}Updating tmux plugins...${NC}"
    chmod +x update_plugin.sh
    ./update_plugin.sh
else
    echo -e "${RED}TPM scripts not found. Skipping plugin installation.${NC}"
fi

echo -e "${GREEN}Tmux setup complete!${NC}"
