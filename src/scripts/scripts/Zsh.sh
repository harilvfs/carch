#!/usr/bin/env bash

sudo -v

RED="\033[1;31m"
GREEN="\033[1;32m"
CYAN="\033[1;36m"
BLUE="\033[1;34m"
RESET="\033[0m"

print_message() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${RESET}"
}

fzf_confirm() {
    local prompt="$1"
    local options=("Yes" "No")
    local selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="$prompt " --height=10 --layout=reverse --border)
    
    if [[ "$selected" == "Yes" ]]; then
        return 0
    else
        return 1
    fi
}

check_aur_helper() {
    if command -v yay &>/dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &>/dev/null; then
        AUR_HELPER="paru"
    else
        print_message "$CYAN" "No AUR helper found. Installing yay..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git
        cd yay || exit
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
        AUR_HELPER="yay"
    fi
    print_message "$GREEN" "Using AUR helper: ${AUR_HELPER}"
}

detect_distro() {
    if command -v pacman &>/dev/null; then
        DISTRO="arch"
    elif command -v dnf &>/dev/null; then
        DISTRO="fedora"
    else
        print_message "$RED" "Unable to detect your Linux distribution."
        exit 1
    fi
    print_message "$CYAN" "Detected distribution: $DISTRO"
}

install_fzf() {
    if ! command -v fzf &>/dev/null; then
        print_message "$CYAN" "Installing fzf..."
        if command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm fzf
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y fzf
        fi
    fi
}

clear

echo -e "${BLUE}"
if command -v figlet &>/dev/null; then
    figlet -f slant "Zsh"
else
    echo "========== Zsh Setup =========="
fi
echo -e "${RESET}"

detect_distro

install_fzf

if ! fzf_confirm "This script will configure Zsh with Powerlevel10k, Oh My Zsh, and more. Nerd Font is recommended. Continue?"; then
    print_message "$RED" "Setup aborted by the user. Exiting..."
    exit 1
fi

install_zsh_dependencies() {
    print_message "$CYAN" "Installing Zsh dependencies..."
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm git zsh zsh-autosuggestions zsh-completions eza zsh-syntax-highlighting
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y git zsh zsh-autosuggestions zsh-syntax-highlighting eza
    fi
}

install_powerlevel10k() {
    print_message "$CYAN" "Installing Powerlevel10k..."
    if command -v pacman &>/dev/null; then
        $AUR_HELPER -S --noconfirm zsh-theme-powerlevel10k-git
        echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
    elif command -v dnf &>/dev/null; then
        sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/zsh-theme-powerlevel10k
        echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
    fi
}

install_ohmyzsh() {
    if [[ ! -d /usr/share/oh-my-zsh ]]; then
        print_message "$CYAN" "Cloning Oh My Zsh..."
        sudo git clone https://github.com/ohmyzsh/ohmyzsh /usr/share/oh-my-zsh
    fi
}

install_ohmyzsh_plugins() {
    PLUGIN_DIR="/usr/share/oh-my-zsh/plugins"

    print_message "$CYAN" "Installing Zsh plugins..."
    cd "$PLUGIN_DIR" || exit 1
    [[ ! -d zsh-syntax-highlighting ]] && sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
    [[ ! -d zsh-256color ]] && sudo git clone https://github.com/chrissicool/zsh-256color.git
    [[ ! -d zsh-autosuggestions ]] && sudo git clone https://github.com/zsh-users/zsh-autosuggestions.git
}

config_zsh() {
    P10K_CONFIG="$HOME/.p10k.zsh"
    if [[ -f "$P10K_CONFIG" ]]; then
        if fzf_confirm ".p10k.zsh found. Do you want to back it up?"; then
            mv "$P10K_CONFIG" "$P10K_CONFIG.bak"
            print_message "$GREEN" "Backup created: $P10K_CONFIG.bak"
        fi
    fi

    print_message "$CYAN" "Applying Powerlevel10k configuration..."
    curl -fsSL "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/.p10k.zsh" -o "$P10K_CONFIG"

    ZSHRC="$HOME/.zshrc"
    if [[ -f "$ZSHRC" ]]; then
        if fzf_confirm ".zshrc already exists. Use the recommended version?"; then
            curl -fsSL "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/.zshrc" -o "$ZSHRC"
            print_message "$GREEN" "Applied recommended .zshrc."
        fi
    fi
    
    if ! grep -q '[ -f ~/.p10k.zsh ] && source ~/.p10k.zsh' "$ZSHRC"; then
        echo '[ -f ~/.p10k.zsh ] && source ~/.p10k.zsh' >> "$ZSHRC"
    fi
}

install_pokemon_colorscripts() {
    print_message "$CYAN" "Installing Pokémon Color Scripts..."
    if command -v pacman &>/dev/null; then
        $AUR_HELPER -S --noconfirm pokemon-colorscripts-git
    elif command -v dnf &>/dev/null; then
        POKEMON_DIR="$HOME/pokemon-colorscripts"

        [[ -d "$POKEMON_DIR" ]] && rm -rf "$POKEMON_DIR"
        git clone --depth=1 https://gitlab.com/phoneybadger/pokemon-colorscripts.git "$POKEMON_DIR"
        
        if [[ -d "$POKEMON_DIR" ]]; then
            cd "$POKEMON_DIR" || exit
            sudo ./install.sh
            cd ..
            rm -rf "$POKEMON_DIR"
        else
            print_message "$RED" "Error: Pokémon Color Scripts failed to clone!"
            exit 1
        fi
    fi
}

install_zoxide() {
    print_message "$CYAN" "Installing zoxide..."
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm zoxide
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y zoxide
    fi
}

if command -v pacman &> /dev/null; then
    check_aur_helper
fi

install_zsh_dependencies
install_powerlevel10k
install_ohmyzsh
install_ohmyzsh_plugins
config_zsh
install_pokemon_colorscripts
install_zoxide

print_message "$BLUE" "Zsh setup completed successfully! 🎉"
