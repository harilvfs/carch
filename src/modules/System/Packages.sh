#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

source "$(dirname "$0")/packages/Packages-Android.sh"
source "$(dirname "$0")/packages/Packages-Browsers.sh"
source "$(dirname "$0")/packages/Packages-Communication.sh"
source "$(dirname "$0")/packages/Packages-Development.sh"
source "$(dirname "$0")/packages/Packages-Editing.sh"
source "$(dirname "$0")/packages/Packages-FileManagers.sh"
source "$(dirname "$0")/packages/Packages-FM-Tools.sh"
source "$(dirname "$0")/packages/Packages-Gaming.sh"
source "$(dirname "$0")/packages/Packages-GitHub.sh"
source "$(dirname "$0")/packages/Packages-Multimedia.sh"
source "$(dirname "$0")/packages/Packages-Music.sh"
source "$(dirname "$0")/packages/Packages-Productivity.sh"
source "$(dirname "$0")/packages/Packages-Streaming.sh"
source "$(dirname "$0")/packages/Packages-Terminals.sh"
source "$(dirname "$0")/packages/Packages-TextEditors.sh"
source "$(dirname "$0")/packages/Packages-Virtualization.sh"
source "$(dirname "$0")/packages/Packages-Crypto-Tools.sh"

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

if [ "$(id -u)" = 0 ]; then
    echo -e "${RED}This script should not be run as root.${NC}"
    exit 1
fi

AUR_HELPER=""

detect_distro() {
    if command -v pacman &> /dev/null; then
        return 0
    elif command -v dnf &> /dev/null; then
        return 1
    elif command -v zypper &> /dev/null; then
        return 2
    else
        echo -e "${RED}:: Unsupported distribution detected. Exiting...${NC}"
        exit 1
    fi
}

detect_aur_helper() {
    for helper in paru yay; do
        if command -v $helper &> /dev/null; then
            AUR_HELPER=$helper
            return 0
        fi
    done

    echo -e "${YELLOW}:: No AUR helper found.${NC}"
    return 1
}

install_aur_helper() {
    detect_distro
    case $? in
        1 | 2) return ;;
    esac

    detect_aur_helper
    if [ $? -eq 0 ]; then
        return
    fi

    echo -e "${RED}:: No AUR helper found. Installing yay...${NC}"

    sudo pacman -S --needed git base-devel

    temp_dir=$(mktemp -d)
    cd "$temp_dir" || {
                        echo -e "${RED}Failed to create temp directory${NC}"
                                                                                 exit 1
    }

    git clone https://aur.archlinux.org/yay.git
    cd yay || {
                echo -e "${RED}Failed to enter yay directory${NC}"
                                                                       exit 1
    }
    makepkg -si

    cd ..
    rm -rf "$temp_dir"
    AUR_HELPER="yay"
    echo -e "${GREEN}:: Yay installed successfully and set as AUR helper.${NC}"
}

install_flatpak() {
    detect_distro
    distro=$?

    if ! command -v flatpak &> /dev/null; then
        echo -e "${YELLOW}:: Flatpak not found. Installing...${NC}"

        if [[ $distro -eq 1 ]]; then
            sudo dnf install -y flatpak
        elif [[ $distro -eq 2 ]]; then
            sudo zypper install -y flatpak
        elif [[ $distro -eq 0 ]]; then
            sudo pacman -S --noconfirm flatpak
        else
            echo -e "${RED}:: Flatpak installation not supported for this distribution${NC}"
            return 1
        fi
    fi

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

install_fedora_package() {
    package_name="$1"
    flatpak_id="$2"

    if sudo dnf list --available | grep -q "^$package_name"; then
        sudo dnf install -y "$package_name"
    else
        echo -e "${YELLOW}:: $package_name not found in DNF. Falling back to Flatpak.${NC}"
        flatpak install -y flathub "$flatpak_id"
    fi
}

install_opensuse_package() {
    package_name="$1"
    flatpak_id="$2"

    if sudo zypper search --installed-only "$package_name" &> /dev/null || sudo zypper search --available "$package_name" &> /dev/null; then
        sudo zypper install -y "$package_name"
    else
        echo -e "${YELLOW}:: $package_name not found in zypper. Falling back to Flatpak.${NC}"
        flatpak install -y flathub "$flatpak_id"
    fi
}

while true; do

    clear

    if ! command -v fzf &> /dev/null; then
        echo -e "${RED}${BOLD}Error: fzf is not installed${NC}"
        echo -e "${YELLOW}Please install fzf before running this script:${NC}"
        echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install fzf"
        echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S fzf"
        echo -e "${CYAN}  • OpenSUSE: ${NC}sudo zypper install fzf"
        exit 1
    fi

    options=("Android Tools" "Browsers" "Communication Apps" "Development Tools" "Editing Tools" "File Managers" "FM Tools" "Gaming" "GitHub" "Multimedia" "Music Apps" "Productivity Apps" "Streaming Tools" "Terminals" "Text Editors" "Virtualization" "Crypto Tools" "Exit")
    selected=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                        --height=70% \
                                                        --prompt="Choose an option: " \
                                                        --header="Package Selection" \
                                                        --pointer="➤" \
                                                        --color='fg:white,fg+:blue,bg+:black,pointer:blue')

    case $selected in
        "Android Tools") install_android ;;
        "Browsers") install_browsers ;;
        "Communication Apps") install_communication ;;
        "Development Tools") install_development ;;
        "Editing Tools") install_editing ;;
        "File Managers") install_filemanagers ;;
        "FM Tools") install_fm_tools ;;
        "Gaming") install_gaming ;;
        "GitHub") install_github ;;
        "Multimedia") install_multimedia ;;
        "Music Apps") install_music ;;
        "Productivity Apps") install_productivity ;;
        "Streaming Tools") install_streaming ;;
        "Terminals") install_terminals ;;
        "Text Editors") install_texteditor ;;
        "Virtualization") install_virtualization ;;
        "Crypto Tools") install_crypto_tools ;;
        "Exit")
            echo -e "${GREEN}Exiting...${NC}"
            exit
            ;;
    esac
done
