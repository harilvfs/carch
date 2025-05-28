#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" >/dev/null 2>&1

detect_distro() {
    if command -v pacman &> /dev/null; then
        distro="arch"
    elif command -v dnf &> /dev/null; then
        distro="fedora"
    else
        distro="unsupported"
    fi
}

check_dependencies() {
if ! command -v fzf &> /dev/null || ! command -v git &> /dev/null || ! command -v make &> /dev/null || ! command -v less &> /dev/null; then

    echo -e "${RED}${BOLD}Error: Required command(s) not found${NC}"

    if ! command -v fzf &> /dev/null; then
        echo -e "${YELLOW}- fzf is not installed.${NC}"
        echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install fzf"
        echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S fzf"
    fi

    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}- git is not installed.${NC}"
        echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install git"
        echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S git"
    fi

    if ! command -v make &> /dev/null; then
        echo -e "${YELLOW}- make is not installed.${NC}"
        echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install make"
        echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S base-devel make"
    fi

    if ! command -v less &> /dev/null; then
        echo -e "${YELLOW}- less is not installed.${NC}"
        echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install less"
        echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S less"
    fi

    exit 1
  fi
}

install_paru() {
    if command -v paru &>/dev/null; then
        echo -e "${GREEN}Paru is already installed on this system.${NC}"
        echo -e "$(paru --version | head -n 1)"
        read -p "Press Enter to continue..."
        return
    fi

    if ! check_dependencies; then
        return
    fi

    echo -e "${CYAN}:: Installing Paru...${NC}"
    sudo pacman -S --needed base-devel git
    temp_dir=$(mktemp -d)
    cd "$temp_dir" || { echo -e "${RED}Failed to create temp directory${NC}"; exit 1; }
    git clone https://aur.archlinux.org/paru.git
    cd paru || { echo -e "${RED}Failed to enter paru directory${NC}"; exit 1; }
    makepkg -si
    cd ..
    rm -rf "$temp_dir"

    if command -v paru &>/dev/null; then
        echo -e "${GREEN}Paru installed successfully.${NC}"
    else
        echo -e "${RED}Paru installation failed.${NC}"
    fi
    read -p "Press Enter to continue..."
}

install_yay() {
    if command -v yay &>/dev/null; then
        echo -e "${GREEN}Yay is already installed on this system.${NC}"
        echo -e "$(yay --version | head -n 1)"
        read -p "Press Enter to continue..."
        return
    fi

    if ! check_dependencies; then
        return
    fi

    echo -e "${CYAN}:: Installing Yay...${NC}"
    sudo pacman -S --needed git base-devel
    temp_dir=$(mktemp -d)
    cd "$temp_dir" || { echo -e "${RED}Failed to create temp directory${NC}"; exit 1; }
    git clone https://aur.archlinux.org/yay.git
    cd yay || { echo -e "${RED}Failed to enter yay directory${NC}"; exit 1; }
    makepkg -si
    cd ..
    rm -rf "$temp_dir"

    if command -v yay &>/dev/null; then
        echo -e "${GREEN}Yay installed successfully.${NC}"
    else
        echo -e "${RED}Yay installation failed.${NC}"
    fi
    read -p "Press Enter to continue..."
}

check_existing_helpers() {
    local helpers_found=false
    local helper_list=""

    if command -v paru &>/dev/null; then
        helpers_found=true
        paru_version=$(paru --version | head -n 1)
        helper_list="${helper_list}• Paru: ${paru_version}\n"
    fi

    if command -v yay &>/dev/null; then
        helpers_found=true
        yay_version=$(yay --version | head -n 1)
        helper_list="${helper_list}• Yay: ${yay_version}\n"
    fi

    if $helpers_found; then
        echo -e "${GREEN}AUR helper(s) already installed on this system:${NC}"
        echo -e "$helper_list"
        return 0
    else
        echo -e "${YELLOW}No AUR helpers detected on this system.${NC}"
        return 1
    fi
}

detect_distro

if [ "$distro" == "fedora" ]; then
    echo -e "${YELLOW}NOTICE:${NC} This system is detected as ${RED}Fedora${NC}."
    echo -e "${RED}AUR helpers (Paru/Yay) are specifically for Arch-based distributions and are not compatible with Fedora.${NC}"
    echo -e "${YELLOW}These tools will not work on your system.${NC}"
    exit 1
fi

if [ "$distro" == "unsupported" ]; then
    echo -e "${YELLOW}NOTICE:${NC} Your distribution could not be detected."
    echo -e "${RED}AUR helpers (Paru/Yay) are specifically for Arch-based distributions.${NC}"
    echo -e "${YELLOW}Please verify that you are using an Arch-based distribution before continuing.${NC}"

    read -p "Do you want to continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Exiting...${NC}"
        exit 1
    fi
fi

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

while true; do
    clear
    check_dependencies
    echo -e "${CYAN}:: AUR Setup Menu [ For Arch Only ]${NC}"
    echo

    check_existing_helpers
    echo

        options=("Install Paru" "Install Yay" "Exit")
        selected=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                        --height=40% \
                                                        --prompt="Choose an option: " \
                                                        --header="AUR Helper Selection" \
                                                        --pointer="➤" \
                                                        --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        case $selected in
        "Install Paru") install_paru ;;
        "Install Yay") install_yay ;;
        "Exit")
            echo -e "${GREEN}Exiting...${NC}"
            exit ;;
        *) continue ;;
    esac
done
