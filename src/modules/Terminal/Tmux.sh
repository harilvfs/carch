#!/usr/bin/env bash

# Installs and configures Tmux for a more efficient terminal multiplexing experience.

clear

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

fzf_confirm() {
    local prompt="$1"
    local options=("Yes" "No")
    local selected=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                     --height=40% \
                                                     --prompt="$prompt " \
                                                     --header="Confirm" \
                                                     --pointer="➤" \
                                                     --color='fg:white,fg+:green,bg+:black,pointer:green')

    if [[ "$selected" == "Yes" ]]; then
        return 0
    else
        return 1
    fi
}

dependencies=("tmux" "fzf" "wget" "git" "curl")
missing=()

for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
        missing+=("$dep")
    fi
done

if [[ ${#missing[@]} -ne 0 ]]; then
    echo "Please wait, installing required dependencies..."

    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm "${missing[@]}" > /dev/null 2>&1
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "${missing[@]}" > /dev/null 2>&1
    else
        echo -e "${RED}Unsupported package manager. Install dependencies manually.${RESET}"
        exit 1
    fi
fi

clear

if ! command -v tmux &>/dev/null; then
    echo -e "${YELLOW}Tmux is not installed. Installing...${RESET}"

    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm tmux
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y tmux
    fi
fi

config_dir="$HOME/.config/tmux"
backup_dir="$HOME/.config/tmux.bak"

if [[ -d "$config_dir" ]]; then
    echo -e "${YELLOW}Existing tmux configuration detected.${RESET}"
    if fzf_confirm "Do you want to backup the existing configuration?"; then
        if [[ -d "$backup_dir" ]]; then
            echo -e "${YELLOW}Backup already exists.${RESET}"
            if fzf_confirm "Do you want to overwrite the backup?"; then
                rm -rf "$backup_dir"
            else
                echo -e "${RED}Exiting to prevent data loss.${RESET}"
                exit 0
            fi
        fi
        mv "$config_dir" "$backup_dir"
    else
        echo -e "${RED}Exiting to avoid overwriting existing config.${RESET}"
        exit 0
    fi
fi

tpm_dir="$HOME/.tmux/plugins/tpm"

if [[ -d "$tpm_dir" ]]; then
    echo -e "${YELLOW}TPM is already installed.${RESET}"
    if fzf_confirm "Do you want to overwrite TPM?"; then
        rm -rf "$tpm_dir"
    else
        echo -e "${RED}Skipping TPM installation.${RESET}"
    fi
fi

echo -e "${GREEN}Cloning TPM...${RESET}"
git clone https://github.com/tmux-plugins/tpm "$tpm_dir"

mkdir -p "$config_dir"

config_url="https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/tmux/tmux.conf"
echo -e "${GREEN}Downloading tmux configuration...${RESET}"
wget -O "$config_dir/tmux.conf" "$config_url"

plugin_script_dir="$tpm_dir/scripts"

if [[ -d "$plugin_script_dir" ]]; then
    echo -e "${GREEN}Installing tmux plugins...${RESET}"
    cd "$plugin_script_dir" || exit
    chmod +x install_plugins.sh
    ./install_plugins.sh

    echo -e "${GREEN}Updating tmux plugins...${RESET}"
    chmod +x update_plugins.sh
    ./update_plugins.sh
else
    echo -e "${RED}TPM scripts not found. Skipping plugin installation.${RESET}"
fi
echo -e "${GREEN}Tmux setup complete!${RESET}"
