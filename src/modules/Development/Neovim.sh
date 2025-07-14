#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

if ! command -v fzf &> /dev/null; then
    echo -e "${RED}${BOLD}Error: fzf is not installed${NC}"
    echo -e "${YELLOW}Please install fzf before running this script:${NC}"
    echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install fzf"
    echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S fzf"
    echo -e "${CYAN}  • openSuse: ${NC}sudo zypper install -y fzf"
    exit 1
fi

echo -e "${TEAL}"
cat << "EOF"

This script helps you set up Neovim or NvChad.

:: 'Neovim' will install and configure the standard Neovim setup.
:: 'NvChad' will install and configure the NvChad setup.
:: 'Exit' to exit the script at any time.

For either option:
- 'Yes': Will check for an existing Neovim configuration and back it up before applying the new configuration.
- 'No': Will create a new Neovim configuration directory.

-------------------------------------------------------------------------------------------------
EOF
echo -e "${NC}"

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
    local options=("Yes" "No" "Exit")
    printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
        --height=40% \
        --prompt="$prompt " \
        --header="Confirm" \
        --pointer="➤" \
        --color='fg:white,fg+:green,bg+:black,pointer:green'
}

fzf_select() {
    local prompt="$1"
    shift
    local options=("$@")
    printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
        --height=40% \
        --prompt="$prompt " \
        --header="Select Option" \
        --pointer="➤" \
        --color='fg:white,fg+:blue,bg+:black,pointer:blue'
}

detect_os() {
    if command -v pacman &> /dev/null; then
        echo -e "${TEAL}Detected Arch-based distribution.${NC}"
        echo "OS=arch" >&2
        return 0
    elif command -v dnf &> /dev/null; then
        echo -e "${TEAL}Detected Fedora-based distribution.${NC}"
        echo "OS=fedora" >&2
        return 0
    elif command -v zypper &> /dev/null; then
        echo -e "${TEAL}Detected opensuse distribution.${NC}"
        echo "OS=opensuse" >&2
        return 0
    else
        echo -e "${RED}Unsupported distribution.${NC}"
        return 1
    fi
}

install_dependencies() {
    local os_type=$1

    echo -e "${GREEN}Installing required dependencies...${NC}"

    if [[ "$os_type" == "arch" ]]; then
        sudo pacman -S --needed --noconfirm ripgrep neovim vim fzf python-virtualenv luarocks go npm shellcheck \
            xclip wl-clipboard lua-language-server shfmt python3 yaml-language-server meson ninja \
            make gcc ttf-jetbrains-mono ttf-jetbrains-mono-nerd git
    elif [[ "$os_type" == "fedora" ]]; then
        sudo dnf install -y ripgrep neovim vim fzf python3-virtualenv luarocks go nodejs shellcheck xclip \
            wl-clipboard lua-language-server shfmt python3 meson ninja-build \
            make gcc jetbrains-mono-fonts-all jetbrains-mono-fonts jetbrains-mono-nl-fonts git
    elif [[ "$os_type" == "opensuse" ]]; then
        sudo zypper install -y ripgrep neovim vim fzf python313-virtualenv lua53-luarocks go nodejs ShellCheck xclip \
            wl-clipboard lua-language-server shfmt python313 meson ninja \
            make gcc jetbrains-mono-fonts git
    else
        echo -e "${RED}Unsupported OS type: $os_type${NC}"
        return 1
    fi

    echo -e "${GREEN}Dependencies installed successfully!${NC}"
    return 0
}

check_command() {
    local cmd=$1
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Required command '$cmd' not found. Please install it and try again.${NC}"
        return 1
    fi
    return 0
}

handle_existing_config() {
    local nvim_config_dir="$HOME/.config/nvim"
    local backup_dir="$HOME/.config/nvimbackup"

    if [ ! -d "$nvim_config_dir" ]; then
        echo -e "${GREEN}:: Creating Neovim configuration directory...${NC}"
        mkdir -p "$nvim_config_dir"
        return 0
    fi

    echo -e "${YELLOW}Existing Neovim configuration found.${NC}"

    choice=$(fzf_confirm "Backup existing config?")

    case $choice in
        "Yes")
            echo -e "${RED}:: Backing up existing config...${NC}"
            mkdir -p "$backup_dir"
            mv "$nvim_config_dir" "$backup_dir/nvim_$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$nvim_config_dir"
            echo -e "${GREEN}:: Backup created at $backup_dir.${NC}"
            ;;
        "No")
            echo -e "${YELLOW}:: Removing existing Neovim configuration...${NC}"
            rm -rf "$nvim_config_dir"
            mkdir -p "$nvim_config_dir"
            ;;
        "Exit")
            echo -e "${RED}Exiting...${NC}"
            exit 0
            ;;
    esac
}

setup_neovim() {
    local nvim_config_dir="$HOME/.config/nvim"

    handle_existing_config

    echo -e "${GREEN}:: Cloning Neovim configuration from GitHub...${NC}"
    if ! git clone https://github.com/harilvfs/nvim "$nvim_config_dir"; then
        echo -e "${RED}Failed to clone the Neovim configuration repository.${NC}"
        return 1
    fi

    echo -e "${GREEN}:: Cleaning up unnecessary files...${NC}"
    cd "$nvim_config_dir" || return 1
    rm -rf .git README.md LICENSE

    echo -e "${GREEN}Neovim setup completed successfully!${NC}"
    return 0
}

setup_nvchad() {
    local nvchad_dir="/tmp/chadnvim"
    local nvim_config_dir="$HOME/.config/nvim"

    handle_existing_config

    echo -e "${GREEN}:: Cloning NvChad configuration from GitHub...${NC}"
    if ! git clone https://github.com/harilvfs/chadnvim "$nvchad_dir"; then
        echo -e "${RED}Failed to clone the NvChad repository.${NC}"
        return 1
    fi

    echo -e "${GREEN}:: Moving NvChad configuration...${NC}"
    cp -r "$nvchad_dir/nvim/"* "$nvim_config_dir/"

    echo -e "${GREEN}:: Cleaning up temporary files...${NC}"
    rm -rf "$nvchad_dir"

    echo -e "${GREEN}:: Cleaning up unnecessary files...${NC}"
    cd "$nvim_config_dir" || return 1
    rm -rf LICENSE README.md

    echo -e "${GREEN}NvChad setup completed successfully!${NC}"
    return 0
}

main() {
    os_info=$(detect_os 2>&1)
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}OS detection failed. Exiting.${NC}"
        exit 1
    fi

    os_type=$(echo "$os_info" | grep "OS=" | cut -d= -f2)

    choice=$(fzf_select "Choose the setup option:" "Neovim" "NvChad" "Exit")

    case $choice in
        "Neovim")
            setup_neovim || exit 1
            install_dependencies "$os_type" || exit 1
            ;;
        "NvChad")
            setup_nvchad || exit 1
            install_dependencies "$os_type" || exit 1
            ;;
        "Exit")
            echo -e "${RED}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option selected! Exiting.${NC}"
            exit 1
            ;;
    esac

    echo -e "${GREEN}Setup completed!${NC}"
}

main
