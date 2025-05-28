#!/usr/bin/env bash

# Downloads and installs a variety of Nerd Fonts for improved readability and aesthetics in terminal applications.

clear

source "$(dirname "$0")/../colors.sh" >/dev/null 2>&1

FONTS_DIR="$HOME/.fonts"

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

get_latest_release() {
    curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"v([^"]+)".*/\1/'
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

fzf_select_fonts() {
    local options=("$@")
    printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                     --height=50% \
                                     --prompt="Select fonts (TAB to mark, ENTER to confirm): " \
                                     --header="Font Selection" \
                                     --pointer="➤" \
                                     --multi \
                                     --color='fg:white,fg+:blue,bg+:black,pointer:blue'
}

check_dependencies() {
    if ! command -v unzip &>/dev/null; then
        echo -e "${RED}Error: 'unzip' is not installed. Please install it first.${NC}"
        exit 1
    fi

    if ! command -v fzf &>/dev/null; then
        echo -e "${RED}Error: 'fzf' is not installed. Please install it first.${NC}"
        exit 1
    fi

    if ! command -v curl &>/dev/null; then
        echo -e "${RED}Error: 'curl' is not installed. Please install it first.${NC}"
        exit 1
    fi
}

install_font_arch() {
    local font_pkg="$@"
    echo -e "${CYAN}:: Installing $font_pkg via pacman...${NC}"
    sudo pacman -S --noconfirm $font_pkg
    echo -e "${GREEN}$font_pkg installed successfully!${NC}"
}

install_font_fedora() {
    local font_name="$1"
    local latest_version=$(get_latest_release)
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${latest_version}/${font_name}.zip"

    echo -e "${CYAN}:: Downloading $font_name version ${latest_version} to /tmp...${NC}"
    curl -L "$font_url" -o "/tmp/${font_name}.zip"

    echo -e "${CYAN}:: Extracting $font_name...${NC}"
    mkdir -p "$FONTS_DIR"
    unzip -q "/tmp/${font_name}.zip" -d "$FONTS_DIR"

    echo -e "${CYAN}:: Refreshing font cache...${NC}"
    fc-cache -vf

    echo -e "${GREEN}$font_name installed successfully in $FONTS_DIR!${NC}"
}

install_fedora_system_fonts() {
    local font_pkg="$@"
    echo -e "${CYAN}:: Installing $font_pkg via dnf...${NC}"
    sudo dnf install -y $font_pkg
    echo -e "${GREEN}$font_pkg installed successfully!${NC}"
}

check_aur_helper() {
    if command -v paru &>/dev/null; then
        echo -e "$GREEN" "AUR helper paru is already installed."
        aur_helper="paru"
        return 0
    elif command -v yay &>/dev/null; then
        echo -e "$GREEN" "AUR helper yay is already installed."
        aur_helper="yay"
        return 0
    fi

    echo -e "$CYAN" ":: No AUR helper found. Installing yay..."

    sudo pacman -S --needed --noconfirm git base-devel

    local temp_dir=$(mktemp -d)
    cd "$temp_dir" || exit 1

    if git clone https://aur.archlinux.org/yay.git; then
        cd yay || exit 1
        makepkg -si --noconfirm || {
            echo -e "$RED" "Failed to install yay."
            cd "$HOME" || exit
            rm -rf "$temp_dir"
            exit 1
        }
        cd "$HOME" || exit
        rm -rf "$temp_dir"
        aur_helper="yay"
        echo-e "$GREEN" "Successfully installed yay as AUR helper."
        return 0
    else
        echo-e "$RED" "Failed to clone yay repository."
        cd "$HOME" || exit
        rm -rf "$temp_dir"
        exit 1
    fi
}

choose_fonts() {
    local return_to_menu=true

    while $return_to_menu; do
        clear

        FONT_SELECTION=$(fzf_select_fonts "FiraCode" "Meslo" "JetBrainsMono" "Hack" "CascadiaMono" "Terminus" "Noto" "DejaVu" "JoyPixels" "Exit")

        if [[ "$FONT_SELECTION" == *"Exit"* ]]; then
            echo -e "${GREEN}Exiting font installation.${NC}"
            return
        fi

        for font in $FONT_SELECTION; do
            case "$font" in
                "FiraCode")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "ttf-firacode-nerd"
                    else
                        install_font_fedora "FiraCode"
                    fi
                    ;;
                "Meslo")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "ttf-meslo-nerd"
                    else
                        install_font_fedora "Meslo"
                    fi
                    ;;
                "JetBrainsMono")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch ttf-jetbrains-mono-nerd ttf-jetbrains-mono
                    else
                        install_font_fedora "JetBrainsMono"
                    fi
                    ;;
                "Hack")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "ttf-hack-nerd"
                    else
                        install_font_fedora "Hack"
                    fi
                    ;;
                "CascadiaMono")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch ttf-cascadia-mono-nerd ttf-cascadia-code-nerd
                    else
                        install_font_fedora "CascadiaMono"
                    fi
                    ;;
                "Terminus")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "terminus-font"
                    else
                        echo -e "${RED}Terminus font is not available as a Nerd Font.${NC}"
                    fi
                    ;;
                "Noto")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch noto-fonts noto-fonts-emoji noto-fonts-cjk noto-fonts-extra
                    else
                        install_fedora_system_fonts google-noto-fonts google-noto-emoji-fonts
                    fi
                    ;;
                "DejaVu")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch ttf-dejavu
                    else
                        install_fedora_system_fonts dejavu-sans-fonts
                    fi
                    ;;
                "JoyPixels")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        check_aur_helper
                        echo -e "${CYAN}:: Installing JoyPixels (ttf-joypixels) via $aur_helper...${NC}"
                        $aur_helper -S --noconfirm ttf-joypixels
                        echo -e "${GREEN}JoyPixels installed successfully!${NC}"
                    else
                        echo -e "${CYAN}:: Downloading JoyPixels font...${NC}"
                        mkdir -p "$HOME/.fonts"
                        curl -L "https://cdn.joypixels.com/arch-linux/font/8.0.0/joypixels-android.ttf" -o "$HOME/.fonts/joypixels-android.ttf"
                        echo -e "${CYAN}:: Refreshing font cache...${NC}"
                        fc-cache -vf "$HOME/.fonts"
                        echo -e "${GREEN}JoyPixels installed successfully to ~/.fonts!${NC}"
                    fi
                    ;;
            esac
        done

        echo -e "${GREEN}All selected fonts installed successfully!${NC}"
        read -rp "Press Enter to return to menu..."
    done
}

detect_os() {
    if command -v pacman &>/dev/null; then
        OS_TYPE="arch"
    elif command -v dnf &>/dev/null; then
        OS_TYPE="fedora"
    else
        echo -e "${RED}Unsupported OS. Please install fonts manually.${NC}"
        exit 1
    fi
}

main() {
    if ! command -v fzf &> /dev/null; then
        echo -e "${RED}${BOLD}Error: fzf is not installed${NC}"
        echo -e "${YELLOW}Please install fzf before running this script:${NC}"
        echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install fzf"
        echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S fzf"
        exit 1
    fi

    if ! command -v curl &> /dev/null; then
        echo -e "${RED}${BOLD}Error: curl is not installed${NC}"
        echo -e "${YELLOW}Please install curl before running this script:${NC}"
        echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install curl"
        echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S curl"
        exit 1
    fi

    check_dependencies
    detect_os
    choose_fonts
}

main
