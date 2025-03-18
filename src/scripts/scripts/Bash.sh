#!/usr/bin/env bash

detect_distro() {
    if grep -q "ID=arch" /etc/os-release 2>/dev/null || [ -f "/etc/arch-release" ]; then
        distro="arch"
    elif grep -q "ID_LIKE=arch" /etc/os-release 2>/dev/null; then
        distro="arch"
    elif grep -q "ID=fedora" /etc/os-release 2>/dev/null || [ -f "/etc/fedora-release" ]; then
        distro="fedora"
    elif grep -q "ID_LIKE=fedora" /etc/os-release 2>/dev/null; then
        distro="fedora"
    else
        distro="unsupported"
    fi
}

check_fzf() {
    if ! command -v fzf &>/dev/null; then
        echo -e "${CYAN}Installing fzf...${RESET}"
        case "$distro" in
            arch) sudo pacman -S --noconfirm fzf ;;
            fedora) sudo dnf install -y fzf ;;
            *) echo -e "${RED}Unsupported distribution.${RESET}"; exit 1 ;;
        esac
    fi
}

clear

RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

echo -e "${BLUE}"
figlet -f slant "Bash"
echo -e "${RESET}"

echo -e "${BLUE}Nerd Font Are Recommended${RESET}"

detect_distro
check_fzf

echo -e "${CYAN}Detected distribution: $distro${RESET}"

install_arch() {
    if ! command -v bash &>/dev/null; then
        echo -e "${CYAN}Installing Bash...${RESET}"
        sudo pacman -S --noconfirm bash
    fi
    if ! pacman -Q bash-completion &>/dev/null; then
        echo -e "${CYAN}Installing bash-completion...${RESET}"
        sudo pacman -S --noconfirm bash-completion
    fi
}

install_fedora() {
    echo -e "${CYAN}Reinstalling Bash and bash-completion to avoid errors...${RESET}"
    sudo dnf install -y bash bash-completion
}

case "$distro" in
    arch) install_arch ;;
    fedora) install_fedora ;;
    *) echo -e "${RED}Unsupported distribution.${RESET}"; exit 1 ;;
esac

options=("Catppuccin" "Nord" "Exit")
THEME=$(printf "%s\n" "${options[@]}" | fzf --prompt="Select a theme: " --height=10 --layout=reverse --border)

if [[ -z "$THEME" || "$THEME" == "Exit" ]]; then
    echo -e "${RED}Exiting...${RESET}"
    exit 0
fi

echo -e "${GREEN}You selected $THEME theme.${RESET}"

if [[ $THEME == "Catppuccin" ]]; then
    STARSHIP_CONFIG_URL="https://raw.githubusercontent.com/harilvfs/i3wmdotfiles/refs/heads/catppuccin/starship/starship.toml"
else
    STARSHIP_CONFIG_URL="https://raw.githubusercontent.com/harilvfs/i3wmdotfiles/refs/heads/nord/starship/starship.toml"
fi

if ! command -v starship &>/dev/null; then
    echo -e "${CYAN}Starship not found. Installing...${RESET}"
    case "$distro" in
        arch) sudo pacman -S --noconfirm starship || curl -sS https://starship.rs/install.sh | sh ;;
        fedora) curl -sS https://starship.rs/install.sh | sh ;;
    esac
fi

STARSHIP_CONFIG="$HOME/.config/starship.toml"
if [[ -f "$STARSHIP_CONFIG" ]]; then
    backup_options=("Yes" "No")
    backup=$(printf "%s\n" "${backup_options[@]}" | fzf --prompt="Starship configuration found. Do you want to back it up? " --height=10 --layout=reverse --border)
    if [[ "$backup" == "Yes" ]]; then
        mv "$STARSHIP_CONFIG" "$STARSHIP_CONFIG.bak"
        echo -e "${GREEN}Backup created: $STARSHIP_CONFIG.bak${RESET}"
    fi
fi

mkdir -p "$HOME/.config"
echo -e "${CYAN}Applying $THEME theme for Starship...${RESET}"
curl -fsSL "$STARSHIP_CONFIG_URL" -o "$STARSHIP_CONFIG"
echo -e "${GREEN}Applied $THEME theme for Starship.${RESET}"

if ! command -v zoxide &>/dev/null; then
    echo -e "${CYAN}Installing zoxide...${RESET}"
    if [[ "$distro" == "arch" ]]; then
        sudo pacman -S --noconfirm zoxide
    elif [[ "$distro" == "fedora" ]]; then
        sudo dnf install -y zoxide
    fi
fi

BASHRC="$HOME/.bashrc"
if [[ -f "$BASHRC" ]]; then
    bashrc_options=("Yes" "No")
    replace_bashrc=$(printf "%s\n" "${bashrc_options[@]}" | fzf --prompt=".bashrc already exists. Use the recommended version? " --height=10 --layout=reverse --border)
    if [[ "$replace_bashrc" == "Yes" ]]; then
        curl -fsSL "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/.bashrc" -o "$BASHRC"
        echo -e "${GREEN}Applied recommended .bashrc.${RESET}"
    fi
fi

install_pokemon_colorscripts() {
    case "$distro" in
        arch)
            if command -v yay &>/dev/null; then
                AUR_HELPER="yay"
            elif command -v paru &>/dev/null; then
                AUR_HELPER="paru"
            else
                echo -e "${CYAN}No AUR helper found. Installing yay...${RESET}"
                
                echo -e "${CYAN}Installing dependencies...${RESET}"
                sudo pacman -S --needed --noconfirm git base-devel
                
                TEMP_DIR=$(mktemp -d)
                cd "$TEMP_DIR" || exit 1
                
                echo -e "${CYAN}Cloning yay repository...${RESET}"
                git clone https://aur.archlinux.org/yay.git
                cd yay || exit 1
                echo -e "${CYAN}Building yay...${RESET}"
                makepkg -si --noconfirm
                
                cd "$HOME" || exit 1
                rm -rf "$TEMP_DIR"
                AUR_HELPER="yay"
                
                echo -e "${GREEN}Successfully installed yay!${RESET}"
            fi
            
            echo -e "${CYAN}Installing Pokémon Color Scripts (AUR)...${RESET}"
            $AUR_HELPER -S --noconfirm pokemon-colorscripts-git
            ;;

        fedora)
            if [[ -d "$HOME/pokemon-colorscripts" ]]; then
                echo -e "${YELLOW}⚠ Found existing Pokémon Color Scripts directory. Removing...${RESET}"
                rm -rf "$HOME/pokemon-colorscripts"
            fi

            echo -e "${CYAN}Installing dependencies...${RESET}"
            sudo dnf install -y git
            
            echo -e "${CYAN}Cloning Pokémon Color Scripts...${RESET}"
            git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git "$HOME/pokemon-colorscripts"
            
            if [[ -d "$HOME/pokemon-colorscripts" ]]; then
                cd "$HOME/pokemon-colorscripts" || { 
                    echo -e "${RED}Failed to change directory to pokemon-colorscripts!${RESET}"; 
                    return 1; 
                }
                
                echo -e "${CYAN}Installing Pokémon Color Scripts...${RESET}"
                sudo ./install.sh
                
                cd - > /dev/null || true
            else
                echo -e "${RED}Failed to clone pokemon-colorscripts repository!${RESET}"
                return 1
            fi
            ;;
    esac
}

install_pokemon_colorscripts

echo -e "${BLUE}Setup completed successfully! 🎉${RESET}"
