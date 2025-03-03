#!/bin/bash

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' 
BLUE="\e[34m"
ENDCOLOR="\e[0m"

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

check_dependencies() {
    local missing_deps=()
    
    echo -e "${CYAN}:: Checking for required dependencies...${NC}"
    
    if ! command -v git &>/dev/null; then
        missing_deps+=("git")
    else
        echo -e "${GREEN}✓ Git is installed${NC}"
    fi
    
    if ! command -v make &>/dev/null; then
        missing_deps+=("make")
    else
        echo -e "${GREEN}✓ Make is installed${NC}"
    fi
    
    if ! command -v less &>/dev/null; then
        missing_deps+=("less")
    else
        echo -e "${GREEN}✓ Less is installed${NC}"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${YELLOW}The following dependencies need to be installed: ${missing_deps[*]}${NC}"
        
        if command -v gum &>/dev/null; then
            if ! gum confirm "Install missing dependencies?"; then
                echo -e "${RED}Cannot proceed without required dependencies. Exiting...${NC}"
                read -p "Press Enter to continue..." dummy
                return 1
            fi
        else
            read -p "Install missing dependencies? [Y/n] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                echo -e "${RED}Cannot proceed without required dependencies. Exiting...${NC}"
                read -p "Press Enter to continue..." dummy
                return 1
            fi
        fi
        
        echo -e "${CYAN}:: Installing missing dependencies...${NC}"
        sudo pacman -S --needed "${missing_deps[@]}"
        
        local failed=false
        for dep in "${missing_deps[@]}"; do
            if ! command -v "$dep" &>/dev/null; then
                echo -e "${RED}Failed to install $dep${NC}"
                failed=true
            else
                echo -e "${GREEN}✓ $dep installed successfully${NC}"
            fi
        done
        
        if $failed; then
            echo -e "${RED}Some dependencies failed to install. Cannot proceed.${NC}"
            read -p "Press Enter to continue..." dummy
            return 1
        fi
    fi
    
    echo -e "${GREEN}All required dependencies are installed.${NC}"
    return 0
}

install_paru() {
    if command -v paru &>/dev/null; then
        echo -e "${GREEN}Paru is already installed on this system.${NC}"
        echo -e "$(paru --version | head -n 1)"
        read -p "Press Enter to continue..." dummy
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
    read -p "Press Enter to continue..." dummy
}

install_yay() {
    if command -v yay &>/dev/null; then
        echo -e "${GREEN}Yay is already installed on this system.${NC}"
        echo -e "$(yay --version | head -n 1)"
        read -p "Press Enter to continue..." dummy
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
        return 1
    fi
}

echo -e "${BLUE}"
figlet -f slant "Aur"
echo -e "${ENDCOLOR}"

detect_distro

if [ "$distro" == "fedora" ]; then
    echo -e "${YELLOW}⚠️  NOTICE:${NC} This system is detected as ${RED}Fedora${NC}."
    echo -e "${RED}AUR helpers (Paru/Yay) are specifically for Arch-based distributions and are not compatible with Fedora.${NC}"
    echo -e "${YELLOW}These tools will not work on your system.${NC}"
    exit 1
fi

if [ "$distro" == "unsupported" ]; then
    echo -e "${YELLOW}⚠️  NOTICE:${NC} Your distribution could not be detected."
    echo -e "${RED}AUR helpers (Paru/Yay) are specifically for Arch-based distributions.${NC}"
    echo -e "${YELLOW}Please verify that you are using an Arch-based distribution before continuing.${NC}"
    
    if ! command -v gum &>/dev/null; then
        read -p "Do you want to continue anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${RED}Exiting...${NC}"
            exit 1
        fi
    else
        if ! gum confirm "Do you want to continue anyway?"; then
            echo -e "${RED}Exiting...${NC}"
            exit 1
        fi
    fi
fi

check_existing_helpers

while true; do
    clear
    echo -e "${BLUE}"
    figlet -f slant "Aur"
    echo -e "${ENDCOLOR}"
    echo -e "${CYAN}:: AUR Setup Menu [ For Arch Only ]${NC}"
    
    check_existing_helpers
    
    if command -v gum &>/dev/null; then
        choice=$(gum choose "Install Paru" "Install Yay" "Exit")
    else
        echo ""
        echo "1) Install Paru"
        echo "2) Install Yay"
        echo "3) Exit"
        read -p "Enter your choice: " choice_num
        case $choice_num in
            1) choice="Install Paru" ;;
            2) choice="Install Yay" ;;
            3) choice="Exit" ;;
            *) echo -e "${RED}Invalid choice${NC}"; sleep 1; continue ;;
        esac
    fi
    
    case $choice in
        "Install Paru") install_paru ;;
        "Install Yay") install_yay ;;
        "Exit") exit ;;  
    esac
done
