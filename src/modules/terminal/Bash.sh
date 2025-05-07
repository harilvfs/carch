#!/usr/bin/env bash

# Sets up a custom Bash prompt with useful information such as the current working directory, Git status, and system details, enhancing the command line experience.

detect_distro() {
    if command -v pacman &> /dev/null; then
        distro="arch"
    elif command -v dnf &> /dev/null; then
        distro="fedora"
    else
        distro="unsupported"
    fi
}

check_essential_dependencies() {
    local dependencies=("git" "wget" "curl")
    local missing=()

    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -ne 0 ]]; then
        echo "Please wait, installing required dependencies..."

        case "$distro" in
            arch) sudo pacman -S --noconfirm "${missing[@]}" > /dev/null 2>&1 ;;
            fedora) sudo dnf install -y "${missing[@]}" > /dev/null 2>&1 ;;
            *) echo -e "${RED}Unsupported distribution.${RESET}"; exit 1 ;;
        esac
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

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

echo -e "${BLUE}Nerd Font Are Recommended${RESET}"

detect_distro
check_essential_dependencies
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
THEME=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                             --height=40% \
                                             --prompt="Select a theme: " \
                                             --header="Theme Selection" \
                                             --pointer="➤" \
                                             --color='fg:white,fg+:blue,bg+:black,pointer:blue')

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
    backup=$(printf "%s\n" "${backup_options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Starship configuration found. Do you want to back it up? " \
                                                    --header="Confirm" \
                                                    --pointer="➤" \
                                                    --color='fg:white,fg+:green,bg+:black,pointer:green')
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
    replace_bashrc=$(printf "%s\n" "${bashrc_options[@]}" | fzf ${FZF_COMMON} \
                                                           --height=40% \
                                                           --prompt=".bashrc already exists. Use the recommended version? " \
                                                           --header="Confirm" \
                                                           --pointer="➤" \
                                                           --color='fg:white,fg+:green,bg+:black,pointer:green')
    if [[ "$replace_bashrc" == "Yes" ]]; then
        curl -fsSL "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/.bashrc" -o "$BASHRC"
        echo -e "${GREEN}Applied recommended .bashrc.${RESET}"
    fi
fi

install_pokemon_colorscripts() {
    case "$distro" in
        arch)
            AUR_HELPERS=("yay" "paru")
            AUR_HELPER=""

            for helper in "${AUR_HELPERS[@]}"; do
                if command -v "$helper" &>/dev/null; then
                    AUR_HELPER="$helper"
                    echo -e "${GREEN}Found AUR helper: $AUR_HELPER${RESET}"
                    break
                fi
            done

            if [[ -z "$AUR_HELPER" ]]; then
                echo -e "${CYAN}No AUR helper found. Installing yay...${RESET}"

                echo -e "${CYAN}Installing dependencies...${RESET}"
                sudo pacman -S --needed --noconfirm git base-devel

                TEMP_DIR=$(mktemp -d)
                cd "$TEMP_DIR" || {
                    echo -e "${RED}Failed to create temporary directory${RESET}"
                    exit 1
                }

                echo -e "${CYAN}Cloning yay repository...${RESET}"
                git clone https://aur.archlinux.org/yay.git || {
                    echo -e "${RED}Failed to clone yay repository${RESET}"
                    cd "$HOME" || exit 1
                    rm -rf "$TEMP_DIR"
                    exit 1
                }

                cd yay || {
                    echo -e "${RED}Failed to enter yay directory${RESET}"
                    cd "$HOME" || exit 1
                    rm -rf "$TEMP_DIR"
                    exit 1
                }

                echo -e "${CYAN}Building yay...${RESET}"
                makepkg -si --noconfirm || {
                    echo -e "${RED}Failed to build yay${RESET}"
                    cd "$HOME" || exit 1
                    rm -rf "$TEMP_DIR"
                    exit 1
                }

                cd "$HOME" || exit 1
                rm -rf "$TEMP_DIR"
                AUR_HELPER="yay"

                echo -e "${GREEN}Successfully installed yay!${RESET}"
            fi

            echo -e "${CYAN}Installing Pokémon Color Scripts (AUR)...${RESET}"
            $AUR_HELPER -S --noconfirm pokemon-colorscripts-git || {
                echo -e "${RED}Failed to install pokemon-colorscripts-git${RESET}"
                exit 1
            }
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
