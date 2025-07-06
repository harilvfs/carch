#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

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
    local dependencies=("git" "wget" "curl" "trash-cli")
    local missing=()

    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -ne 0 ]]; then
        echo "Please wait, installing required dependencies..."

        case "$distro" in
            arch) sudo pacman -S --noconfirm "${missing[@]}" > /dev/null 2>&1 ;;
            fedora) sudo dnf install -y "${missing[@]}" > /dev/null 2>&1 ;;
            *)
                echo -e "${RED}Unsupported distribution.${NC}"
                                                                  exit 1
                                                                         ;;
        esac
    fi
}

check_fzf() {
    if ! command -v fzf &> /dev/null; then
        echo -e "${RED}${BOLD}Error: fzf is not installed${NC}"
        echo -e "${YELLOW}Please install fzf before running this script:${NC}"
        echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install fzf"
        echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S fzf"
        exit 1
    fi
}

install_eza() {
    if command -v eza &> /dev/null; then
        echo -e "${GREEN}eza is already installed.${NC}"
        return 0
    fi

    echo -e "${CYAN}Installing eza...${NC}"
    case "$distro" in
        arch)
            sudo pacman -S --noconfirm eza
            ;;
        fedora)
            echo -e "${CYAN}Installing eza manually for Fedora...${NC}"
            local tmp_dir=$(mktemp -d)
            cd "$tmp_dir" || exit 1
            echo -e "${CYAN}Fetching latest eza release...${NC}"
            local latest_url=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep -o "https://github.com/eza-community/eza/releases/download/.*/eza_x86_64-unknown-linux-gnu.zip" | head -1)
            if [ -z "$latest_url" ]; then
                echo -e "${YELLOW}Could not determine latest version, using fallback version...${NC}"
                latest_url="https://github.com/eza-community/eza/releases/download/v0.21.1/eza_x86_64-unknown-linux-gnu.zip"
            fi
            echo -e "${CYAN}Downloading eza from: $latest_url${NC}"
            if ! curl -L -o eza.zip "$latest_url"; then
                echo -e "${RED}Failed to download eza. Continuing without it...${NC}"
                cd "$HOME" || exit
                rm -rf "$tmp_dir"
                return 1
            fi
            echo -e "${CYAN}Extracting eza...${NC}"
            if ! unzip -q eza.zip; then
                echo -e "${RED}Failed to extract eza. Continuing without it...${NC}"
                cd "$HOME" || exit
                rm -rf "$tmp_dir"
                return 1
            fi
            echo -e "${CYAN}Installing eza to /usr/bin...${NC}"
            sudo cp eza /usr/bin/
            sudo chmod +x /usr/bin/eza
            cd "$HOME" || exit
            rm -rf "$tmp_dir"
            echo -e "${GREEN}eza installed successfully!${NC}"
            ;;
        *)
            echo -e "${RED}Unsupported distribution for eza installation.${NC}"
            return 1
            ;;
    esac
}

check_default_shell() {
    local current_shell=$(basename "$SHELL")

    if [[ "$current_shell" != "bash" ]]; then
        echo -e "${YELLOW}Current default shell: $current_shell${NC}"

        shell_options=("Yes" "No")
        change_shell=$(printf "%s\n" "${shell_options[@]}" | fzf ${FZF_COMMON} \
                                                            --height=40% \
                                                            --prompt="Bash is not your default shell. Do you want to change it to bash? " \
                                                            --header="Default Shell Check" \
                                                            --pointer="➤" \
                                                            --color='fg:white,fg+:yellow,bg+:black,pointer:yellow')

        if [[ "$change_shell" == "Yes" ]]; then
            echo -e "${CYAN}Changing default shell to bash...${NC}"
            chsh -s /bin/bash
            echo -e "${GREEN}Default shell changed to bash. Please log out and log back in for the change to take effect.${NC}"
        else
            echo -e "${TEAL}Keeping current shell: $current_shell${NC}"
        fi
    else
        echo -e "${GREEN}Bash is already your default shell.${NC}"
    fi
}

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

detect_distro
check_essential_dependencies
check_fzf

echo -e "${TEAL}Nerd Font Are Recommended${NC}"

echo -e "${CYAN}Detected distribution: $distro${NC}"

install_arch() {
    if ! command -v bash &> /dev/null; then
        echo -e "${CYAN}Installing Bash...${NC}"
        sudo pacman -S --noconfirm bash
    fi
    if ! pacman -Q bash-completion &> /dev/null; then
        echo -e "${CYAN}Installing bash-completion...${NC}"
        sudo pacman -S --noconfirm bash-completion
    fi
}

install_fedora() {
    echo -e "${CYAN}Reinstalling Bash and bash-completion to avoid errors...${NC}"
    sudo dnf install -y bash bash-completion
}

case "$distro" in
    arch) install_arch ;;
    fedora) install_fedora ;;
    *)
        echo -e "${RED}Unsupported distribution.${NC}"
                                                          exit 1
                                                                 ;;
esac

install_eza

options=("Catppuccin" "Nord" "Tokyo Night" "Exit")
THEME=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                             --height=40% \
                                             --prompt="Select a theme: " \
                                             --header="Theme Selection" \
                                             --pointer="➤" \
                                             --color='fg:white,fg+:blue,bg+:black,pointer:blue')

if [[ -z "$THEME" || "$THEME" == "Exit" ]]; then
    echo -e "${RED}Exiting...${NC}"
    exit 0
fi

echo -e "${GREEN}You selected $THEME theme.${NC}"

case "$THEME" in
    "Catppuccin")
        STARSHIP_CONFIG_URL="https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/starship/starship.toml"
        ;;
    "Nord")
        STARSHIP_CONFIG_URL="https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/starship/nord-theme/starship.toml"
        ;;
    "Tokyo Night")
        STARSHIP_CONFIG_URL="https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/starship/tokyo-preset/starship.toml"
        ;;
    *)
        echo -e "${RED}Invalid theme selection. Exiting...${NC}"
        exit 1
        ;;
esac

if ! command -v starship &> /dev/null; then
    echo -e "${CYAN}Starship not found. Installing...${NC}"
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
        echo -e "${GREEN}Backup created: $STARSHIP_CONFIG.bak${NC}"
    fi
fi

mkdir -p "$HOME/.config"
echo -e "${CYAN}Applying $THEME theme for Starship...${NC}"
curl -fsSL "$STARSHIP_CONFIG_URL" -o "$STARSHIP_CONFIG"
echo -e "${GREEN}Applied $THEME theme for Starship.${NC}"

if ! command -v zoxide &> /dev/null; then
    echo -e "${CYAN}Installing zoxide...${NC}"
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
        echo -e "${GREEN}Applied recommended .bashrc.${NC}"
    fi
fi

install_pokemon_colorscripts() {
    case "$distro" in
        arch)
            AUR_HELPERS=("yay" "paru")
            AUR_HELPER=""

            for helper in "${AUR_HELPERS[@]}"; do
                if command -v "$helper" &> /dev/null; then
                    AUR_HELPER="$helper"
                    echo -e "${GREEN}Found AUR helper: $AUR_HELPER${NC}"
                    break
                fi
            done

            if [[ -z "$AUR_HELPER" ]]; then
                echo -e "${CYAN}No AUR helper found. Installing yay...${NC}"

                echo -e "${CYAN}Installing dependencies...${NC}"
                sudo pacman -S --needed --noconfirm git base-devel

                TEMP_DIR=$(mktemp -d)
                cd "$TEMP_DIR" || {
                    echo -e "${RED}Failed to create temporary directory${NC}"
                    exit 1
                }

                echo -e "${CYAN}Cloning yay repository...${NC}"
                git clone https://aur.archlinux.org/yay.git || {
                    echo -e "${RED}Failed to clone yay repository${NC}"
                    cd "$HOME" || exit 1
                    rm -rf "$TEMP_DIR"
                    exit 1
                }

                cd yay || {
                    echo -e "${RED}Failed to enter yay directory${NC}"
                    cd "$HOME" || exit 1
                    rm -rf "$TEMP_DIR"
                    exit 1
                }

                echo -e "${CYAN}Building yay...${NC}"
                makepkg -si --noconfirm || {
                    echo -e "${RED}Failed to build yay${NC}"
                    cd "$HOME" || exit 1
                    rm -rf "$TEMP_DIR"
                    exit 1
                }

                cd "$HOME" || exit 1
                rm -rf "$TEMP_DIR"
                AUR_HELPER="yay"

                echo -e "${GREEN}Successfully installed yay!${NC}"
            fi

            echo -e "${CYAN}Installing Pokémon Color Scripts (AUR)...${NC}"
            $AUR_HELPER -S --noconfirm pokemon-colorscripts-git || {
                echo -e "${RED}Failed to install pokemon-colorscripts-git${NC}"
                exit 1
            }
            ;;

        fedora)
            if [[ -d "$HOME/pokemon-colorscripts" ]]; then
                echo -e "${YELLOW}Found existing Pokémon Color Scripts directory. Removing...${NC}"
                rm -rf "$HOME/pokemon-colorscripts"
            fi

            echo -e "${CYAN}Installing dependencies...${NC}"
            sudo dnf install -y git

            echo -e "${CYAN}Cloning Pokémon Color Scripts...${NC}"
            git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git "$HOME/pokemon-colorscripts"

            if [[ -d "$HOME/pokemon-colorscripts" ]]; then
                cd "$HOME/pokemon-colorscripts" || {
                    echo -e "${RED}Failed to change directory to pokemon-colorscripts!${NC}"
                    return 1
                }

                echo -e "${CYAN}Installing Pokémon Color Scripts...${NC}"
                sudo ./install.sh

                cd - > /dev/null || true
            else
                echo -e "${RED}Failed to clone pokemon-colorscripts repository!${NC}"
                return 1
            fi
            ;;
    esac
}

install_pokemon_colorscripts

check_default_shell

echo -e "${TEAL}Setup completed successfully!${NC}"
