#!/bin/bash

clear

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

dependencies=("tmux" "figlet" "gum" "wget" "git")
missing=()
for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
        missing+=("$dep")
    fi
done

if [[ ${#missing[@]} -ne 0 ]]; then
    echo -e "${RED}The following dependencies are missing: ${missing[*]}${RESET}"
    echo -e "${YELLOW}Please install them before running this script.${RESET}"
    exit 1
fi

echo -e "${BLUE}"

figlet "Tmux"

echo -e "${RESET}"

if ! gum confirm "Do you want to proceed with the tmux installation and configuration?"; then
    echo -e "${RED}Exiting...${RESET}"
    exit 0
fi

if ! command -v tmux &>/dev/null; then
    echo -e "${YELLOW}tmux is not installed. Installing tmux...${RESET}"
    sudo pacman -S --noconfirm tmux
fi

config_dir="$HOME/.config/tmux"
if [[ -d "$config_dir" ]]; then
    backup_dir="$HOME/.config/tmux.bak"
    echo -e "${BLUE}Found existing tmux configuration. Backing up to $backup_dir...${RESET}"
    mv "$config_dir" "$backup_dir"
fi

tpm_dir="$HOME/.tmux/plugins/tpm"
if [[ -d "$tpm_dir" ]]; then
    echo -e "${YELLOW}TPM already exists at $tpm_dir. Skipping clone.${RESET}"
else
    echo -e "${GREEN}Cloning Tmux Plugin Manager (TPM)...${RESET}"
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
fi

cd "$tpm_dir" || exit
chmod +x tpm
./tpm

mkdir -p "$config_dir"

config_url="https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/tmux/tmux.conf"
echo -e "${GREEN}Downloading tmux configuration file...${RESET}"
wget -O "$config_dir/tmux.conf" "$config_url"

plugin_script_dir="$HOME/.tmux/plugins/tpm/scripts/"
echo -e "${GREEN}Installing tmux plugins...${RESET}"
cd "$plugin_script_dir" || exit
chmod +x ./*.sh
./install_plugins.sh

echo -e "${GREEN}Updating tmux plugins...${RESET}"
./update_plugin.sh

shell_rc=("$HOME/.zshrc" "$HOME/.bashrc")
startup_line="if [ -z \"$TMUX\" ]; then\n   tmux attach -d || tmux new\nfi"
for rc in "${shell_rc[@]}"; do
    if [[ -f "$rc" ]]; then
        if ! grep -Fxq "$startup_line" "$rc"; then
            echo -e "${GREEN}Adding tmux auto-start to $rc...${RESET}"
            echo -e "$startup_line" >> "$rc"
        else
            echo -e "${YELLOW}Tmux auto-start already present in $rc.${RESET}"
        fi
    fi
done

echo -e "${GREEN}Tmux setup and configuration completed successfully.${RESET}"

