#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

distro=""

print_message() {
    local color="$1"
    local message="$2"
    printf "%b%s%b\n" "$color" "$message" "$ENDCOLOR"
}

confirm() {
    while true; do
        read -p "$(printf "%b%s%b" "$CYAN" "$1 [y/N]: " "$RC")" answer
        case ${answer,,} in
            y | yes) return 0 ;;
            n | no | "") return 1 ;;
            *) print_message "$YELLOW" "Please answer with y/yes or n/no." ;;
        esac
    done
}

show_menu() {
    local title="$1"
    shift
    local options=("$@")

    echo
    print_message "$CYAN" "=== $title ==="
    echo

    for i in "${!options[@]}"; do
        printf "%b[%d]%b %s\n" "$GREEN" "$((i + 1))" "$ENDCOLOR" "${options[$i]}"
    done
    echo
}

get_choice() {
    local max_option="$1"
    local choice

    while true; do
        read -p "$(printf "%b%s%b" "$YELLOW" "Enter your choice (1-$max_option): " "$ENDCOLOR")" choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$max_option" ]; then
            return "$choice"
        else
            print_message "$RED" "Invalid choice. Please enter a number between 1 and $max_option."
        fi
    done
}

detect_distro() {
    if command -v pacman &> /dev/null; then
        distro="arch"
    elif command -v dnf &> /dev/null; then
        distro="fedora"
    elif command -v zypper &> /dev/null; then
        distro="opensuse"
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
        print_message "$YELLOW" "Please wait, installing required dependencies..."

        case "$distro" in
            arch) sudo pacman -S --noconfirm "${missing[@]}" > /dev/null 2>&1 ;;
            fedora) sudo dnf install -y "${missing[@]}" > /dev/null 2>&1 ;;
            opensuse) sudo zypper install -y "${missing[@]}" > /dev/null 2>&1 ;;
            *)
                print_message "$RED" "Unsupported distribution."
                exit 1
                ;;
        esac
    fi
}

install_eza() {
    if command -v eza &> /dev/null; then
        print_message "$GREEN" "eza is already installed."
        return 0
    fi

    print_message "$CYAN" "Installing eza..."
    case "$distro" in
        arch)
            sudo pacman -S --noconfirm eza
            ;;
        fedora)
            print_message "$CYAN" "Installing eza manually for Fedora..."
            local tmp_dir
            tmp_dir=$(mktemp -d)
            cd "$tmp_dir" || exit 1
            print_message "$CYAN" "Fetching latest eza release..."
            local latest_url
            latest_url=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep -o "https://github.com/eza-community/eza/releases/download/.*/eza_x86_64-unknown-linux-gnu.zip" | head -1)
            if [ -z "$latest_url" ]; then
                print_message "$YELLOW" "Could not determine latest version, using fallback version..."
                latest_url="https://github.com/eza-community/eza/releases/download/v0.21.1/eza_x86_64-unknown-linux-gnu.zip"
            fi
            print_message "$CYAN" "Downloading eza from: $latest_url"
            if ! curl -L -o eza.zip "$latest_url"; then
                print_message "$RED" "Failed to download eza. Continuing without it..."
                cd "$HOME" || exit
                rm -rf "$tmp_dir"
                return 1
            fi
            print_message "$CYAN" "Extracting eza..."
            if ! unzip -q eza.zip; then
                print_message "$RED" "Failed to extract eza. Continuing without it..."
                cd "$HOME" || exit
                rm -rf "$tmp_dir"
                return 1
            fi
            print_message "$CYAN" "Installing eza to /usr/bin..."
            sudo cp eza /usr/bin/
            sudo chmod +x /usr/bin/eza
            cd "$HOME" || exit
            rm -rf "$tmp_dir"
            print_message "$GREEN" "eza installed successfully!"
            ;;
        opensuse)
            sudo zypper install eza -y
            ;;
        *)
            print_message "$RED" "Unsupported distribution for eza installation."
            return 1
            ;;
    esac
}

check_default_shell() {
    local current_shell
    current_shell=$(basename "$SHELL")

    if [[ "$current_shell" != "bash" ]]; then
        print_message "$YELLOW" "Current default shell: $current_shell"
        if confirm "Bash is not your default shell. Do you want to change it to bash?"; then
            print_message "$CYAN" "Changing default shell to bash..."
            chsh -s /bin/bash
            print_message "$GREEN" "Default shell changed to bash. Please log out and log back in for the change to take effect."
        else
            print_message "$TEAL" "Keeping current shell: $current_shell"
        fi
    else
        print_message "$GREEN" "Bash is already your default shell."
    fi
}

install_distro_packages() {
    case "$distro" in
        arch)
            if ! command -v bash &> /dev/null; then
                print_message "$CYAN" "Installing Bash..."
                sudo pacman -S --noconfirm bash
            fi
            if ! pacman -Q bash-completion &> /dev/null; then
                print_message "$CYAN" "Installing bash-completion..."
                sudo pacman -S --noconfirm bash-completion
            fi
            ;;
        fedora)
            print_message "$CYAN" "Reinstalling Bash and bash-completion to avoid errors..."
            sudo dnf install -y bash bash-completion
            ;;
        opensuse)
            print_message "$CYAN" "Reinstalling Bash and bash-completion to avoid errors..."
            sudo zypper install -y bash bash-completion
            ;;
        *)
            print_message "$RED" "Unsupported distribution."
            exit 1
            ;;
    esac
}

install_pokemon_colorscripts() {
    case "$distro" in
        arch)
            local AUR_HELPERS=("yay" "paru")
            local AUR_HELPER=""

            for helper in "${AUR_HELPERS[@]}"; do
                if command -v "$helper" &> /dev/null; then
                    AUR_HELPER="$helper"
                    print_message "$GREEN" "Found AUR helper: $AUR_HELPER"
                    break
                fi
            done

            if [[ -z "$AUR_HELPER" ]]; then
                print_message "$CYAN" "No AUR helper found. Installing yay..."
                print_message "$CYAN" "Installing dependencies..."
                sudo pacman -S --needed --noconfirm git base-devel

                local TEMP_DIR
                TEMP_DIR=$(mktemp -d)
                cd "$TEMP_DIR" || {
                                    print_message "$RED" "Failed to create temporary directory"
                                                                                                 exit 1
                }

                print_message "$CYAN" "Cloning yay repository..."
                git clone https://aur.archlinux.org/yay.git || {
                                                                 print_message "$RED" "Failed to clone yay repository"
                                                                                                                        cd "$HOME" || exit 1
                                                                                                                                              rm -rf "$TEMP_DIR"
                                                                                                                                                                  exit 1
                }

                cd yay || {
                            print_message "$RED" "Failed to enter yay directory"
                                                                                  cd "$HOME" || exit 1
                                                                                                        rm -rf "$TEMP_DIR"
                                                                                                                            exit 1
                }

                print_message "$CYAN" "Building yay..."
                makepkg -si --noconfirm || {
                                             print_message "$RED" "Failed to build yay"
                                                                                         cd "$HOME" || exit 1
                                                                                                               rm -rf "$TEMP_DIR"
                                                                                                                                   exit 1
                }

                cd "$HOME" || exit 1
                rm -rf "$TEMP_DIR"
                AUR_HELPER="yay"
                print_message "$GREEN" "Successfully installed yay!"
            fi

            print_message "$CYAN" "Installing Pokémon Color Scripts (AUR)..."
            "$AUR_HELPER" -S --noconfirm pokemon-colorscripts-git || {
                                                                       print_message "$RED" "Failed to install pokemon-colorscripts-git"
                                                                                                                                          exit 1
            }
            ;;

        fedora | opensuse)
            if [[ -d "$HOME/pokemon-colorscripts" ]]; then
                print_message "$YELLOW" "Found existing Pokémon Color Scripts directory. Removing..."
                rm -rf "$HOME/pokemon-colorscripts"
            fi

            print_message "$CYAN" "Installing dependencies..."
            if [[ "$distro" == "fedora" ]]; then
                sudo dnf install -y git
            elif [[ "$distro" == "opensuse" ]]; then
                sudo zypper install -y git
            fi

            print_message "$CYAN" "Cloning Pokémon Color Scripts..."
            git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git "$HOME/pokemon-colorscripts"

            if [[ -d "$HOME/pokemon-colorscripts" ]]; then
                cd "$HOME/pokemon-colorscripts" || {
                                                     print_message "$RED" "Failed to change directory to pokemon-colorscripts!"
                                                                                                                                 return 1
                }

                print_message "$CYAN" "Installing Pokémon Color Scripts..."
                sudo ./install.sh
                cd - > /dev/null || true
            else
                print_message "$RED" "Failed to clone pokemon-colorscripts repository!"
                return 1
            fi
            ;;
    esac
}

main() {
    detect_distro
    check_essential_dependencies
    install_distro_packages
    install_eza

    clear
    print_message "$TEAL" "Nerd Fonts are recommended for the best experience."
    print_message "$CYAN" "Detected distribution: $distro"

    local options=("Catppuccin" "Nord" "Tokyo Night" "Exit")
    show_menu "Select a theme for Starship:" "${options[@]}"
    get_choice "${#options[@]}"
    local choice_index=$?
    local THEME="${options[$((choice_index - 1))]}"

    if [[ -z "$THEME" || "$THEME" == "Exit" ]]; then
        exit 0
    fi

    print_message "$GREEN" "You selected $THEME theme."

    local STARSHIP_CONFIG_URL=""
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
            print_message "$RED" "Invalid theme selection. Exiting..."
            exit 1
            ;;
    esac

    if ! command -v starship &> /dev/null; then
        print_message "$CYAN" "Starship not found. Installing..."
        if ! curl -sS https://starship.rs/install.sh | sh -s -- -y; then
             print_message "$RED" "Failed to install Starship. Please try installing it manually."
        fi
    fi

    local STARSHIP_CONFIG="$HOME/.config/starship.toml"
    local backup_dir="$HOME/.config/carch/backups"
    if [[ -f "$STARSHIP_CONFIG" ]]; then
        if confirm "Starship configuration found. Do you want to back it up?"; then
            mkdir -p "$backup_dir"
            mv "$STARSHIP_CONFIG" "$backup_dir/starship.toml.bak"
            print_message "$GREEN" "Backup created: $backup_dir/starship.toml.bak"
        fi
    fi

    mkdir -p "$HOME/.config"
    print_message "$CYAN" "Applying $THEME theme for Starship..."
    curl -fsSL "$STARSHIP_CONFIG_URL" -o "$STARSHIP_CONFIG"
    print_message "$GREEN" "Applied $THEME theme for Starship."

    if ! command -v zoxide &> /dev/null; then
        print_message "$CYAN" "Installing zoxide..."
        case "$distro" in
            arch) sudo pacman -S --noconfirm zoxide ;;
            fedora) sudo dnf install -y zoxide ;;
            opensuse) sudo zypper install -y zoxide ;;
        esac
    fi

    local BASHRC="$HOME/.bashrc"
    if [[ -f "$BASHRC" ]]; then
        if confirm ".bashrc already exists. Use the recommended version?"; then
            mv "$BASHRC" "$backup_dir/.bashrc.bak"
            print_message "$GREEN" "Backup created: $backup_dir/.bashrc.bak"
            curl -fsSL "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/.bashrc" -o "$BASHRC"
            print_message "$GREEN" "Applied recommended .bashrc."
        fi
    fi

    install_pokemon_colorscripts
    check_default_shell

    print_message "$TEAL" "Setup completed successfully!"
}

main
