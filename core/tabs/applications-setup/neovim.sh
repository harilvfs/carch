#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
figlet -f slant "Neovim"
cat <<"EOF"
      
This script will help you set up Neovim.

:: 'Yes', it will check for an existing Neovim configuration.
If an existing configuration is found, it will back it up before applying the new configuration.

:: 'No', it will create a new Neovim directory and apply the new configuration.

:: 'Exit' to exit the script at any time.
-------------------------------------------------------------------------------------------------
EOF
echo -e "${ENDCOLOR}"

setup_neovim() {
    NVIM_CONFIG_DIR="$HOME/.config/nvim"
    BACKUP_DIR="$HOME/.config/nvimbackup"

    while true; do
        echo -e "${YELLOW}Do you want to continue?${ENDCOLOR}"
        echo "1) Yes"
        echo "2) No"
        echo "3) Exit"
        read -p "Enter your choice [1-3]: " choice
        
        case $choice in
            1)
                if [ -d "$NVIM_CONFIG_DIR" ]; then
                    echo -e "${RED}:: Existing Neovim config found at $NVIM_CONFIG_DIR. Backing up...${ENDCOLOR}"
                    mkdir -p "$BACKUP_DIR"
                    mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR/nvim_$(date +%Y%m%d_%H%M%S)"
                    echo -e "${GREEN}:: Backup created at $BACKUP_DIR.${ENDCOLOR}"
                fi
                break
                ;;
            2)
                echo -e "${GREEN}:: Creating Neovim configuration directory...${ENDCOLOR}"
                mkdir -p "$NVIM_CONFIG_DIR"
                break
                ;;
            3)
                echo -e "${RED}Exiting the script.${ENDCOLOR}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option, please choose '1', '2', or '3'.${ENDCOLOR}"
                ;;
        esac
    done

    echo -e "${GREEN}:: Cloning Neovim configuration from GitHub...${ENDCOLOR}"
    if ! git clone https://github.com/harilvfs/nvim "$NVIM_CONFIG_DIR"; then
        echo -e "${RED}Failed to clone the Neovim configuration repository. Please check your internet connection or the repository URL.${ENDCOLOR}"
        exit 1
    fi

    echo -e "${GREEN}:: Cleaning up unnecessary files...${ENDCOLOR}"
    cd "$NVIM_CONFIG_DIR" || { echo -e "${RED}Failed to change directory to $NVIM_CONFIG_DIR. Aborting cleanup.${ENDCOLOR}"; exit 1; }
    rm -rf .git README.md LICENSE

    echo -e "${GREEN}Neovim setup completed successfully!${ENDCOLOR}"

    echo -e "${GREEN}:: Installing necessary dependencies...${ENDCOLOR}"
    sudo pacman -S --needed ripgrep neovim vim fzf python-virtualenv luarocks go shellcheck xclip wl-clipboard
}

setup_neovim
