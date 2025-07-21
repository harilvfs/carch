#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

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

required_cmds="git curl wget"
missing=0

echo_missing_cmd() {
    cmd="$1"
    echo -e "${YELLOW} $cmd is not installed.${NC}"
    echo -e "${CYAN} • Fedora:     ${NC}sudo dnf install $cmd"
    echo -e "${CYAN} • Arch Linux: ${NC}sudo pacman -S $cmd"
    echo -e "${CYAN} • openSUSE:   ${NC}sudo zypper install $cmd"
}

for cmd in $required_cmds; do
    if ! command -v "$cmd" > /dev/null 2>&1; then
        [ "$missing" -eq 0 ] && echo -e "${RED}${BOLD}Error: Required command(s) not found${NC}"
        echo_missing_cmd "$cmd"
        missing=1
    fi
done

[ "$missing" -eq 1 ] && exit 1

if ! command -v tmux &> /dev/null; then
    echo -e "${YELLOW}Tmux is not installed. Installing...${NC}"

    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm tmux
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y tmux
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y tmux
    fi
fi

config_dir="$HOME/.config/tmux"
backup_dir="$HOME/.config/tmux.bak"

if [[ -d "$config_dir" ]]; then
    echo -e "${YELLOW}Existing tmux configuration detected.${NC}"
    if confirm "Do you want to backup the existing configuration?"; then
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