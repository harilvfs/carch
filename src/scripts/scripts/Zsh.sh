#!/usr/bin/env bash

sudo -v

install_gum() {
    if ! command -v gum &>/dev/null; then
        echo -e "\033[1;31m[GUM MISSING]\033[0m Installing gum..."
        if [[ -f /etc/os-release ]]; then
            source /etc/os-release
            if [[ "$ID" == "arch" || "$ID_LIKE" == "arch" ]]; then
                sudo pacman -S --noconfirm gum
            elif [[ "$ID" == "fedora" || "$ID_LIKE" == "fedora" ]]; then
                sudo dnf install -y gum
            else
                echo -e "\033[1;31mUnsupported distribution for gum installation.\033[0m"
                exit 1
            fi
        fi
    fi
}

clear

RED="\033[1;31m"
GREEN="\033[1;32m"
CYAN="\033[1;36m"
BLUE="\033[1;34m"
RESET="\033[0m"

echo -e "${BLUE}"
figlet -f slant "Zsh"
echo -e "${RESET}"

if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    DISTRO=$ID
else
    echo -e "${RED}Unable to detect your Linux distribution.${RESET}"
    exit 1
fi

gum style --foreground "$CYAN" --bold "Detected distribution: $DISTRO"

gum confirm "This script will configure Zsh with Powerlevel10k, Oh My Zsh, and more. Nerd Font is recommended. Do you want to continue?" || exit 1

install_zsh_dependencies() {
    if [[ "$ID" == "arch" || "$ID_LIKE" == "arch" ]]; then
        gum spin --title "Installing Zsh dependencies..." -- sudo pacman -S --noconfirm git zsh zsh-autosuggestions zsh-completions eza zsh-syntax-highlighting
    elif [[ "$ID" == "fedora" || "$ID_LIKE" == "fedora" ]]; then
        gum spin --title "Installing Zsh dependencies (Fedora)..." -- sudo dnf install -y git zsh zsh-autosuggestions zsh-syntax-highlighting eza
    fi
}

install_powerlevel10k() {
    if [[ "$ID" == "arch" || "$ID_LIKE" == "arch" ]]; then
        gum spin --title "Installing Powerlevel10k..." -- bash -c "yay -S --noconfirm zsh-theme-powerlevel10k-git"
        echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
    elif [[ "$ID" == "fedora" || "$ID_LIKE" == "fedora" ]]; then
        gum spin --title "Cloning Powerlevel10k..." -- sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/zsh-theme-powerlevel10k
        echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
    fi
}

install_ohmyzsh() {
    if [[ ! -d /usr/share/oh-my-zsh ]]; then
        gum spin --title "Cloning Oh My Zsh..." -- sudo git clone https://github.com/ohmyzsh/ohmyzsh /usr/share/oh-my-zsh
    fi
}

install_ohmyzsh_plugins() {
    PLUGIN_DIR="/usr/share/oh-my-zsh/plugins"

    gum spin --title "Installing Zsh plugins..." -- bash -c "
        cd '$PLUGIN_DIR' || exit 1
        [[ ! -d zsh-syntax-highlighting ]] && sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
        [[ ! -d zsh-256color ]] && sudo git clone https://github.com/chrissicool/zsh-256color.git
        [[ ! -d zsh-autosuggestions ]] && sudo git clone https://github.com/zsh-users/zsh-autosuggestions.git
    "
}

config_zsh() {
P10K_CONFIG="$HOME/.p10k.zsh"
if [[ -f "$P10K_CONFIG" ]]; then
    gum confirm ".p10k.zsh found. Do you want to back it up?" && mv "$P10K_CONFIG" "$P10K_CONFIG.bak"
    gum style --foreground "$GREEN" "Backup created: $P10K_CONFIG.bak"
fi

gum spin --title "Applying Powerlevel10k configuration..." -- curl -fsSL "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/.p10k.zsh" -o "$P10K_CONFIG"

ZSHRC="$HOME/.zshrc"
if [[ -f "$ZSHRC" ]]; then
    gum confirm ".zshrc already exists. Use the recommended version?" && curl -fsSL "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/.zshrc" -o "$ZSHRC"
    echo '[ -f ~/.p10k.zsh ] && source ~/.p10k.zsh' >> "$ZSHRC"
    gum style --foreground "$GREEN" "Applied recommended .zshrc."
fi
}

install_pokemon_colorscripts() {
    if [[ "$ID" == "arch" || "$ID_LIKE" == "arch" ]]; then
        if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
            gum style --foreground "$CYAN" "No AUR helper found. Installing yay..."
            sudo pacman -S --needed --noconfirm git base-devel
            git clone https://aur.archlinux.org/yay.git
            cd yay || exit
            makepkg -si --noconfirm
            cd ..
            rm -rf yay
        fi
        gum spin --title "Installing Pokémon Color Scripts..." -- yay -S --noconfirm pokemon-colorscripts-git
    elif [[ "$ID" == "fedora" || "$ID_LIKE" == "fedora" ]]; then
        POKEMON_DIR="$HOME/pokemon-colorscripts"

        [[ -d "$POKEMON_DIR" ]] && rm -rf "$POKEMON_DIR"

        gum spin --title "Cloning Pokémon Color Scripts repository..." -- git clone --depth=1 https://gitlab.com/phoneybadger/pokemon-colorscripts.git "$POKEMON_DIR"
        
        if [[ -d "$POKEMON_DIR" ]]; then
            cd "$POKEMON_DIR" || exit
            gum spin --title "Installing Pokémon Color Scripts..." -- sudo ./install.sh
            cd ..
            rm -rf "$POKEMON_DIR"
        else
            gum style --foreground "$RED" "Error: Pokémon Color Scripts failed to clone!"
            exit 1
        fi
    fi
}

install_zoxide() {
    if [[ "$ID" == "arch" || "$ID_LIKE" == "arch" ]]; then
        gum spin --title "Installing zoxide..." -- sudo pacman -S --noconfirm zoxide
    elif [[ "$ID" == "fedora" || "$ID_LIKE" == "fedora" ]]; then
        gum spin --title "Installing zoxide..." -- sudo dnf install -y zoxide
    fi
}

install_gum
install_zsh_dependencies
install_powerlevel10k
install_ohmyzsh
install_ohmyzsh_plugins
config_zsh
install_pokemon_colorscripts
install_zoxide

gum style --foreground "$BLUE" --bold "Zsh setup completed successfully! 🎉"

