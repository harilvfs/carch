#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

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
    local zip_file="/tmp/${font_name}.zip"

    echo -e "${CYAN}:: Downloading $font_name version ${latest_version} to /tmp...${NC}"
    curl -L "$font_url" -o "$zip_file"

    echo -e "${CYAN}:: Extracting $font_name...${NC}"
    mkdir -p "$FONTS_DIR"
    unzip -q "$zip_file" -d "$FONTS_DIR"

    echo -e "${CYAN}:: Cleaning up temporary files...${NC}"
    rm -f "$zip_file"

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

install_font_opensuse() {
    local font_name="$1"
    local latest_version=$(get_latest_release)
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${latest_version}/${font_name}.zip"
    local zip_file="/tmp/${font_name}.zip"

    echo -e "${CYAN}:: Downloading $font_name version ${latest_version} to /tmp...${NC}"
    curl -L "$font_url" -o "$zip_file"

    echo -e "${CYAN}:: Extracting $font_name...${NC}"
    mkdir -p "$FONTS_DIR"
    unzip -q "$zip_file" -d "$FONTS_DIR"

    echo -e "${CYAN}:: Cleaning up temporary files...${NC}"
    rm -f "$zip_file"

    echo -e "${CYAN}:: Refreshing font cache...${NC}"
    fc-cache -vf

    echo -e "${GREEN}$font_name installed successfully in $FONTS_DIR!${NC}"
}

install_opensuse_system_fonts() {
    local font_pkg="$@"
    echo -e "${CYAN}:: Installing $font_pkg via zypper...${NC}"
    sudo zypper install -y $font_pkg
    echo -e "${GREEN}$font_pkg installed successfully!${NC}"
}

check_aur_helper() {
    if command -v paru &> /dev/null; then
        echo -e "$GREEN" "AUR helper paru is already installed."
        aur_helper="paru"
        return 0
    elif command -v yay &> /dev/null; then
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

        FONT_SELECTION=$(fzf_select_fonts "FiraCode" "Meslo" "JetBrainsMono" "Hack" "CascadiaMono" "Terminus" "Noto" "DejaVu" "JoyPixels" "FontAwesome" "Exit")

        if [[ "$FONT_SELECTION" == *"Exit"* ]]; then
            echo -e "${GREEN}Exiting...${NC}"
            return
        fi

        for font in $FONT_SELECTION; do
            case "$font" in
                "FiraCode")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "ttf-firacode-nerd"
                    elif [[ "$OS_TYPE" == "opensuse" ]]; then
                        install_opensuse_system_fonts "fira-code-fonts"
                    else
                        install_font_fedora "FiraCode"
                    fi
                    ;;

                "Meslo")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "ttf-meslo-nerd"
                    elif [[ "$OS_TYPE" == "opensuse" ]]; then
                        install_opensuse_system_fonts "meslo-lg-fonts"
                    else
                        install_font_fedora "Meslo"
                    fi
                    ;;

                "JetBrainsMono")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch ttf-jetbrains-mono-nerd ttf-jetbrains-mono
                    elif [[ "$OS_TYPE" == "opensuse" ]]; then
                        install_opensuse_system_fonts "jetbrains-mono-fonts"
                    else
                        install_font_fedora "JetBrainsMono"
                    fi
                    ;;

                "Hack")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "ttf-hack-nerd"
                    elif [[ "$OS_TYPE" == "opensuse" ]]; then
                        install_opensuse_system_fonts "hack-fonts"
                    else
                        install_font_fedora "Hack"
                    fi
                    ;;

                "CascadiaMono")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch ttf-cascadia-mono-nerd ttf-cascadia-code-nerd
                    elif [[ "$OS_TYPE" == "opensuse" ]]; then
                        install_font_opensuse "CascadiaMono"
                    else
                        install_font_fedora "CascadiaMono"
                    fi
                    ;;

                "Terminus")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch "terminus-font"
                    elif [[ "$OS_TYPE" == "opensuse" ]]; then
                        install_font_opensuse "Terminus"
                    else
                        install_font_fedora "Terminus"
                    fi
                    ;;

                "Noto")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch noto-fonts noto-fonts-emoji noto-fonts-cjk noto-fonts-extra
                    elif [[ "$OS_TYPE" == "opensuse" ]]; then
                        install_opensuse_system_fonts google-noto-fonts noto-coloremoji-fonts
                    else
                        install_fedora_system_fonts google-noto-fonts google-noto-emoji-fonts
                    fi
                    ;;

                "DejaVu")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        install_font_arch ttf-dejavu
                    elif [[ "$OS_TYPE" == "opensuse" ]]; then
                        install_opensuse_system_fonts "dejavu-fonts"
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
                    elif [[ "$OS_TYPE" == "opensuse" ]]; then
                        echo -e "${CYAN}:: Downloading JoyPixels font...${NC}"
                        mkdir -p "$HOME/.fonts"
                        curl -L "https://cdn.joypixels.com/arch-linux/font/8.0.0/joypixels-android.ttf" -o "$HOME/.fonts/joypixels-android.ttf"
                        echo -e "${CYAN}:: Refreshing font cache...${NC}"
                        fc-cache -vf "$HOME/.fonts"
                        echo -e "${GREEN}JoyPixels installed successfully to ~/.fonts!${NC}"
                    else
                        echo -e "${CYAN}:: Downloading JoyPixels font...${NC}"
                        mkdir -p "$HOME/.fonts"
                        curl -L "https://cdn.joypixels.com/arch-linux/font/8.0.0/joypixels-android.ttf" -o "$HOME/.fonts/joypixels-android.ttf"
                        echo -e "${CYAN}:: Refreshing font cache...${NC}"
                        fc-cache -vf "$HOME/.fonts"
                        echo -e "${GREEN}JoyPixels installed successfully to ~/.fonts!${NC}"
                    fi
                    ;;

                "FontAwesome")
                    if [[ "$OS_TYPE" == "arch" ]]; then
                        check_aur_helper
                        echo -e "${CYAN}:: Installing Font Awesome (ttf-font-awesome) via $aur_helper...${NC}"
                        $aur_helper -S --noconfirm ttf-font-awesome
                        echo -e "${GREEN}Font Awesome installed successfully!${NC}"
                    elif [[ "$OS_TYPE" == "opensuse" ]]; then
                        install_opensuse_system_fonts "fontawesome-fonts"
                    else
                        install_fedora_system_fonts fontawesome-fonts-all
                    fi
                    ;;
            esac
        done

        echo -e "${GREEN}All selected fonts installed successfully!${NC}"
        read -rp "Press Enter to return to menu..."
    done
}

detect_os() {
    if command -v pacman &> /dev/null; then
        OS_TYPE="arch"
    elif command -v dnf &> /dev/null; then
        OS_TYPE="fedora"
    elif command -v zypper &> /dev/null; then
        OS_TYPE="opensuse"
    else
        echo -e "${RED}Unsupported OS. Please install fonts manually.${NC}"
        exit 1
    fi
}

check_dependencies() {
    local failed=0
    local deps=("fzf" "curl" "unzip")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo -e "${RED}${BOLD}Error: ${dep} is not installed.${NC}"
            echo -e "${YELLOW}Please install ${dep} before running this script:${NC}"
            echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install ${dep}"
            echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S ${dep}"
            echo -e "${CYAN}  • openSUSE: ${NC}sudo zypper install ${dep}"
            failed=1
        fi
    done
    if [ "$failed" -eq 1 ]; then
        exit 1
    else
        return 0
    fi
}

main() {
    check_dependencies
    detect_os
    choose_fonts
}

main
