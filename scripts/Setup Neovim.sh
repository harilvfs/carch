#!/bin/bash

tput init
tput clear
GREEN="\e[32m"
RED="\e[31m"
ENDCOLOR="\e[0m"

setup_neovim() {
    NVIM_CONFIG_DIR="$HOME/.config/nvim"
    BACKUP_DIR="$HOME/.config/nvimbackup"

    echo -e "${GREEN}This script will help you set up Neovim.${ENDCOLOR}"
    echo -e "${GREEN}If you press 'Y', it will check for an existing Neovim configuration.${ENDCOLOR}"
    echo -e "${GREEN}If an existing configuration is found, it will back it up before applying the new configuration.${ENDCOLOR}"
    echo -e "${GREEN}If you press 'N', it will create a new Neovim directory and apply the new configuration.${ENDCOLOR}"
    echo -e "${GREEN}Press 'E' to exit the script at any time.${ENDCOLOR}"

    while true; do
        read -p "Do you have an existing Neovim configuration? [Y/n/E] " yn
        yn=${yn:-Y} 

        case $yn in
            [Yy]* )
                if [ -d "$NVIM_CONFIG_DIR" ]; then
                    echo -e "${RED}Existing Neovim config found at $NVIM_CONFIG_DIR. Backing up...${ENDCOLOR}"
                    mkdir -p "$BACKUP_DIR"
                    mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR/nvim_$(date +%Y%m%d_%H%M%S)"
                    echo -e "${GREEN}Backup created at $BACKUP_DIR.${ENDCOLOR}"
                fi
                break
                ;;
            [Nn]* )
                echo -e "${GREEN}Creating Neovim configuration directory...${ENDCOLOR}"
                mkdir -p "$NVIM_CONFIG_DIR"
                break
                ;;
            [Ee]* )
                echo -e "${RED}Exiting the script.${ENDCOLOR}"
                exit 0
                ;;
            * )
                echo -e "${RED}Please answer 'Y', 'N', or 'E'.${ENDCOLOR}"
                ;;
        esac
    done

    echo -e "${GREEN}Cloning Neovim configuration from GitHub...${ENDCOLOR}"
    if ! git clone https://github.com/harilvfs/nvim "$NVIM_CONFIG_DIR"; then
        echo -e "${RED}Failed to clone the Neovim configuration repository. Please check your internet connection or the repository URL.${ENDCOLOR}"
        exit 1
    fi

    echo -e "${GREEN}Cleaning up unnecessary files...${ENDCOLOR}"
    cd "$NVIM_CONFIG_DIR" || { echo -e "${RED}Failed to change directory to $NVIM_CONFIG_DIR. Aborting cleanup.${ENDCOLOR}"; exit 1; }
    rm -rf .git README.md LICENSE

    echo -e "${GREEN}Neovim setup completed successfully!${ENDCOLOR}"

    echo -e "${GREEN}Installing necessary dependencies...${ENDCOLOR}"
    sudo pacman -S --needed ripgrep neovim vim fzf python-virtualenv luarocks go shellcheck xclip wl-clipboard
}

setup_neovim
