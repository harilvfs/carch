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

if ! command -v gum &>/dev/null; then
    echo -e "\033[1;31m[GUM MISSING]\033[0m Installing gum..."
    detect_distro
    case "$distro" in
        arch) sudo pacman -S --noconfirm gum ;;
        fedora) sudo dnf install -y gum ;;
        *) echo -e "\033[1;31m[ERROR]\033[0m Unsupported distribution."; exit 1 ;;
    esac
fi

clear

RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
RESET="\033[0m"

echo -e "${BLUE}"
figlet -f slant "Bash"
echo -e "${RESET}"

echo -e "${BLUE}Nerd Font Are Recommended${RESET}"

detect_distro
gum style --foreground "$CYAN" --bold "Detected distribution: $distro"

install_arch() {
    if ! command -v bash &>/dev/null; then
        gum spin --title "Installing Bash..." -- sudo pacman -S --noconfirm bash
    fi
    if ! pacman -Q bash-completion &>/dev/null; then
        gum spin --title "Installing bash-completion..." -- sudo pacman -S --noconfirm bash-completion
    fi
}

install_fedora() {
    gum spin --title "Reinstalling Bash and bash-completion to avoid errors..." -- sudo dnf install -y bash bash-completion
}

case "$distro" in
    arch) install_arch ;;
    fedora) install_fedora ;;
    *) echo -e "${RED}Unsupported distribution.${RESET}"; exit 1 ;;
esac

THEME=$(gum choose "Catppuccin" "Nord" "Exit")

if [[ $THEME == "Exit" ]]; then
    gum style --foreground "$RED" "Exiting..."
    exit 0
fi

gum style --foreground "$GREEN" --bold "You selected $THEME theme."

if [[ $THEME == "Catppuccin" ]]; then
    STARSHIP_CONFIG_URL="https://raw.githubusercontent.com/harilvfs/i3wmdotfiles/refs/heads/catppuccin/starship/starship.toml"
else
    STARSHIP_CONFIG_URL="https://raw.githubusercontent.com/harilvfs/i3wmdotfiles/refs/heads/nord/starship/starship.toml"
fi

if ! command -v starship &>/dev/null; then
    gum style --foreground "$CYAN" "Starship not found. Installing..."
    case "$distro" in
        arch) sudo pacman -S --noconfirm starship || curl -sS https://starship.rs/install.sh | sh ;;
        fedora) curl -sS https://starship.rs/install.sh | sh ;;
    esac
fi

STARSHIP_CONFIG="$HOME/.config/starship.toml"
if [[ -f "$STARSHIP_CONFIG" ]]; then
    gum confirm "Starship configuration found. Do you want to back it up?" && mv "$STARSHIP_CONFIG" "$STARSHIP_CONFIG.bak"
    gum style --foreground "$GREEN" "Backup created: $STARSHIP_CONFIG.bak"
fi

mkdir -p "$HOME/.config"
gum spin --title "Applying $THEME theme for Starship..." -- curl -fsSL "$STARSHIP_CONFIG_URL" -o "$STARSHIP_CONFIG"
gum style --foreground "$GREEN" "Applied $THEME theme for Starship."

if ! command -v zoxide &>/dev/null; then
    gum style --foreground "$CYAN" "Installing zoxide..."
    if [[ "$distro" == "arch" ]]; then
        sudo pacman -S --noconfirm zoxide
    elif [[ "$distro" == "fedora" ]]; then
        sudo dnf install -y zoxide
    fi
fi

BASHRC="$HOME/.bashrc"
if [[ -f "$BASHRC" ]]; then
    gum confirm ".bashrc already exists. Use the recommended version?" && curl -fsSL "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/.bashrc" -o "$BASHRC"
    gum style --foreground "$GREEN" "Applied recommended .bashrc."
fi

install_pokemon_colorscripts() {
    case "$distro" in
        arch)
            if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
                gum style --foreground "$CYAN" "No AUR helper found. Installing yay..."
                sudo pacman -S --needed --noconfirm git base-devel
                git clone https://aur.archlinux.org/yay.git "$HOME/yay"
                cd "$HOME/yay" || exit
                makepkg -si --noconfirm
                cd ..
                rm -rf "$HOME/yay"
            fi
            gum spin --title "Installing Pokémon Color Scripts (AUR)..." -- yay -S --noconfirm pokemon-colorscripts-git
            ;;

        fedora)
            if [[ -d "$HOME/pokemon-colorscripts" ]]; then
                gum style --foreground "$YELLOW" "⚠ Found existing Pokémon Color Scripts directory. Removing..."
                rm -rf "$HOME/pokemon-colorscripts"
            fi

            gum spin --title "Cloning Pokémon Color Scripts..." -- git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git "$HOME/pokemon-colorscripts"
            cd "$HOME/pokemon-colorscripts" || exit

            gum spin --title "Installing Pokémon Color Scripts..." -- sudo ./install.sh
            ;;
    esac
}

install_pokemon_colorscripts

gum style --foreground "$BLUE" --bold "Setup completed successfully! 🎉"

