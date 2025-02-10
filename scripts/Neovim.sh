#!/bin/bash

clear

GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
figlet -f slant "Neovim Setup"
cat <<"EOF"
      
This script helps you set up Neovim or NvChad.

:: 'Neovim' will install and configure the standard Neovim setup.
:: 'NvChad' will install and configure the NvChad setup.
:: 'Exit' to exit the script at any time.

For 'Neovim':
- 'Yes': Will check for an existing Neovim configuration and back it up before applying the new configuration.
- 'No': Will create a new Neovim configuration directory.

-------------------------------------------------------------------------------------------------
EOF
echo -e "${ENDCOLOR}"

# OS Detection using ID_LIKE for better compatibility
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
else
    echo -e "${RED}Unsupported system!${RESET}"
    exit 1
fi

if [[ "$ID" == "arch" || "$ID_LIKE" == "arch" ]]; then
    OS="arch"
    echo -e "${BLUE}Detected Arch-based distribution.${RESET}"
elif [[ "$ID" == "fedora" || "$ID_LIKE" == "fedora" ]]; then
    OS="fedora"
    echo -e "${BLUE}Detected Fedora-based distribution.${RESET}"
else
    echo -e "${RED}This script only supports Arch Linux and Fedora-based distributions.${RESET}"
    exit 1
fi

install_dependencies() {
    echo -e "${GREEN}Installing required dependencies...${RESET}"
    
    if [[ "$OS" == "arch" ]]; then
        sudo pacman -S --needed ripgrep neovim vim fzf python-virtualenv luarocks go shellcheck xclip wl-clipboard lua-language-server shellcheck shfmt python3 yaml-language-server meson ninja make 
    elif [[ "$OS" == "fedora" ]]; then
        sudo dnf install -y ripgrep neovim vim fzf python3virtualenv luarocks go shellcheck xclip wl-clipboard lua-language-server shellcheck shfmt python3 ghc-ShellCheck meson ninja-build make
    fi
}
setup_neovim() {
    NVIM_CONFIG_DIR="$HOME/.config/nvim"
    BACKUP_DIR="$HOME/.config/nvimbackup"

    while true; do
        echo -e "${YELLOW}Do you want to continue?${ENDCOLOR}"
        choice=$(gum choose "Yes" "No" "Exit")
        
        case $choice in
            "Yes")
                if [ -d "$NVIM_CONFIG_DIR" ]; then
                    echo -e "${RED}:: Existing Neovim config found at $NVIM_CONFIG_DIR. Backing up...${ENDCOLOR}"
                    mkdir -p "$BACKUP_DIR"
                    mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR/nvim_$(date +%Y%m%d_%H%M%S)"
                    echo -e "${GREEN}:: Backup created at $BACKUP_DIR.${ENDCOLOR}"
                fi
                break
                ;;
            "No")
                echo -e "${GREEN}:: Creating Neovim configuration directory...${ENDCOLOR}"
                mkdir -p "$NVIM_CONFIG_DIR"
                break
                ;;
            "Exit")
                echo -e "${RED}Exiting the script.${ENDCOLOR}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option, please choose 'Yes', 'No', or 'Exit'.${ENDCOLOR}"
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

    install_dependencies
}

setup_nvchad() {
    NVCHAD_DIR="/tmp/chadnvim"
    NVIM_CONFIG_DIR="$HOME/.config/nvim"
    BACKUP_DIR="$HOME/.config/nvimbackup"

    while true; do
        echo -e "${YELLOW}Do you want to continue?${ENDCOLOR}"
        choice=$(gum choose "Yes" "No" "Exit")
        
        case $choice in
            "Yes")
                if [ -d "$NVIM_CONFIG_DIR" ]; then
                    echo -e "${RED}:: Existing Neovim config found at $NVIM_CONFIG_DIR. Backing up...${ENDCOLOR}"
                    mkdir -p "$BACKUP_DIR"
                    mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR/nvim_$(date +%Y%m%d_%H%M%S)"
                    echo -e "${GREEN}:: Backup created at $BACKUP_DIR.${ENDCOLOR}"
                fi
                break
                ;;
            "No")
                echo -e "${GREEN}:: Creating Neovim configuration directory...${ENDCOLOR}"
                mkdir -p "$NVIM_CONFIG_DIR"
                break
                ;;
            "Exit")
                echo -e "${RED}Exiting the script.${ENDCOLOR}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option, please choose 'Yes', 'No', or 'Exit'.${ENDCOLOR}"
                ;;
        esac
    done

    echo -e "${GREEN}:: Cloning NvChad configuration from GitHub...${ENDCOLOR}"
    if ! git clone https://github.com/harilvfs/chadnvim "$NVCHAD_DIR"; then
        echo -e "${RED}Failed to clone the NvChad repository. Please check your internet connection or the repository URL.${ENDCOLOR}"
        exit 1
    fi

    echo -e "${GREEN}:: Moving NvChad configuration...${ENDCOLOR}"
    mv "$NVCHAD_DIR/nvim" "$NVIM_CONFIG_DIR"
    
    echo -e "${GREEN}:: Cleaning up unnecessary files...${ENDCOLOR}"
    cd "$NVIM_CONFIG_DIR" || { echo -e "${RED}Failed to change directory to $NVIM_CONFIG_DIR. Aborting cleanup.${ENDCOLOR}"; exit 1; }
    rm -rf LICENSE README.md

    echo -e "${GREEN}NvChad setup completed successfully!${ENDCOLOR}"

    install_dependencies
}

echo -e "${YELLOW}Choose the setup option:${ENDCOLOR}"
choice=$(gum choose "Neovim" "NvChad" "Exit")

case $choice in
    "Neovim")
        setup_neovim
        ;;
    "NvChad")
        setup_nvchad
        ;;
    "Exit")
        echo -e "${RED}Exiting the script.${ENDCOLOR}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option selected! Exiting.${ENDCOLOR}"
        exit 1
        ;;
esac

