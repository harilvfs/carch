#!/usr/bin/env bash

# Configures a stylish Zsh prompt with added functionalities like syntax highlighting, auto-completion, and custom themes for a more efficient shell experience.

RED="\033[1;31m"
GREEN="\033[1;32m"
CYAN="\033[1;36m"
BLUE="\033[1;34m"
RESET="\033[0m"

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

print_message() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${RESET}"
}

fzf_confirm() {
    local prompt="$1"
    local options=("Yes" "No")
    local selected=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                     --height=40% \
                                                     --prompt="$prompt " \
                                                     --header="Confirm" \
                                                     --pointer="➤" \
                                                     --color='fg:white,fg+:green,bg+:black,pointer:green')
    
    if [[ "$selected" == "Yes" ]]; then
        return 0
    else
        return 1
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
        
        if command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm "${missing[@]}" > /dev/null 2>&1
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y "${missing[@]}" > /dev/null 2>&1
        else
            print_message "$RED" "Unsupported package manager. Install dependencies manually."
            exit 1
        fi
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

detect_distro

check_essential_dependencies

install_fzf

if command -v pacman &> /dev/null; then
    check_aur_helper
fi

install_zsh_dependencies() {
    print_message "$CYAN" "Installing Zsh dependencies..."
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm git zsh zsh-autosuggestions zsh-completions eza zsh-syntax-highlighting
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y git zsh zsh-autosuggestions zsh-syntax-highlighting unzip
        
        # due to eza is no longer available on fedora 42 installing manually
        print_message "$CYAN" "Installing eza manually for Fedora..."
        
        if command -v eza &>/dev/null; then
            print_message "$GREEN" "eza is already installed."
        else
            local tmp_dir=$(mktemp -d)
            cd "$tmp_dir" || exit 1
            
            print_message "$CYAN" "Fetching latest eza release..."
            local latest_url=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep -o "https://github.com/eza-community/eza/releases/download/.*/eza_x86_64-unknown-linux-gnu.zip" | head -1)
            
            if [ -z "$latest_url" ]; then
                print_message "$YELLOW" "Could not determine latest version, using fallback version..."
                latest_url="https://github.com/eza-community/eza/releases/download/v0.21.1/eza_x86_64-unknown-linux-gnu.zip"
            fi
            
            print_message "$CYAN" "Downloading eza from: $latest_url"
            if ! curl -L -o eza.zip "$latest_url"; then
                print_message "$RED" "Failed to download eza. Exiting..."
                cd "$HOME" || exit
                rm -rf "$tmp_dir"
                exit 1
            fi
            
            print_message "$CYAN" "Extracting eza..."
            unzip -q eza.zip
            
            print_message "$CYAN" "Installing eza to /usr/bin..."
            sudo cp eza /usr/bin/
            sudo chmod +x /usr/bin/eza
            
            cd "$HOME" || exit
            rm -rf "$tmp_dir"
            
            print_message "$GREEN" "eza installed successfully!"
        fi
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

install_zsh_dependencies
install_powerlevel10k
install_ohmyzsh
install_ohmyzsh_plugins
config_zsh
install_pokemon_colorscripts
install_zoxide

print_message "$BLUE" "Zsh setup completed successfully! 🎉"
