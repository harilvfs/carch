#!/usr/bin/env bash

VERSION="4.2.5"
CONFIG_DIR="$HOME/.config/carch"
CACHE_DIR="$HOME/.cache/carch-install"
LOG_FILE="$CACHE_DIR/install.log"

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"
BOLD="\033[1m"
RESET="\033[0m"

USERNAME=$(whoami)
mkdir -p "$CONFIG_DIR" "$CACHE_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

typewriter() {
    text="$1"
    color="$2"
    for ((i=0; i<${#text}; i++)); do
        echo -en "${color}${text:$i:1}${RESET}"
        sleep 0.03
    done
    echo ""
}

if command -v pacman &>/dev/null; then
    DISTRO="Arch BTW"
elif command -v dnf &>/dev/null; then
    DISTRO="Fedora"
elif command -v apt &>/dev/null; then
    DISTRO="Debian"
elif command -v zypper &>/dev/null; then
    DISTRO="openSUSE"
elif command -v emerge &>/dev/null; then
    DISTRO="Gentoo"
elif command -v xbps-install &>/dev/null; then
    DISTRO="Void Linux"
else
    DISTRO="Unknown Linux Distribution"
fi

ARCH=$(uname -m)

if ! command -v pacman &>/dev/null; then
    echo -e "${RED}Oops! You are using this script on a non-Arch based distro.${RESET}"
    echo -e "${RED}This script is for Arch Linux or Arch-based distributions.${RESET}"
    exit 1
fi

if ! pacman -Qi "fzf" &>/dev/null; then
    echo "FZF is required for this script. Installing fzf..."
    sudo pacman -Sy --noconfirm fzf || { 
        echo "Failed to install fzf. Exiting."
        exit 1
    }
fi

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

check_and_install() {
    local pkg="$1"
    if ! pacman -Qi "$pkg" &>/dev/null; then
        echo -e "${YELLOW}Installing missing dependency: $pkg${RESET}"
        echo "Installing $pkg..."
        sudo pacman -Sy --noconfirm "$pkg"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ $pkg installed successfully${RESET}"
        else
            echo -e "${RED}✗ Failed to install $pkg${RESET}"
            return 1
        fi
    else
        echo -e "${GREEN}✓ $pkg is already installed${RESET}"
    fi
    return 0
}

clear

echo ""
echo -e "${CYAN}${BOLD}CARCH${RESET}${CYAN}${RESET}"
echo -e "${CYAN}${WHITE}Version: $VERSION${RESET}${CYAN}${RESET}"
echo -e "${CYAN}${WHITE}Architecture: $ARCH${RESET}${CYAN}${RESET}"

echo ""
echo -e "${CYAN}Distribution: $DISTRO${RESET}"
sleep 1

typewriter "Hey ${USERNAME}! Thanks for choosing Carch" "${MAGENTA}${BOLD}"

echo ""
echo -e "${BLUE}This is the Carch installer for Arch Linux or Arch-based distros.${RESET}"
sleep 0.5
echo -e "${BLUE}This will install Carch with Carch PKGBUILD.${RESET}"
sleep 0.5
echo -e "${BLUE}You can choose Git or Stable release.${RESET}"
sleep 0.5
echo ""

echo -e "${YELLOW}Installing dependencies...${RESET}"
echo ""

dependencies=("figlet" "ttf-jetbrains-mono-nerd" "ttf-jetbrains-mono" "git")
failed_deps=0

for dep in "${dependencies[@]}"; do
    check_and_install "$dep" || ((failed_deps++))
done

if [ $failed_deps -gt 0 ]; then
    echo -e "${RED}Some dependencies failed to install. Check the logs.${RESET}"
    fzf_confirm "Continue anyway?" || exit 1
fi

sleep 1

clear

echo -e "${GREEN}"
cat <<"EOF"
   ____         __       ____
  /  _/__  ___ / /____ _/ / /__ ____
 _/ // _ \(_-</ __/ _ `/ / / -_) __/
/___/_//_/___/\__/\_,_/_/_/\__/_/

EOF
echo "Carch Installer for Arch or Arch based distros."
echo -e "${RESET}"
echo ""

echo -e "${GREEN}NOTE: Stable Release is recommended.${RESET}"
echo -e "${RED}Git package is not fully recommended as it grabs the latest commit which may have bugs.${RESET}"
echo -e "${YELLOW}${BOLD}Select installation type:${RESET}"

options=("Stable Release [Recommended]" "Carch-git [GitHub Latest Commit]" "Cancel")
CHOICE=$(printf "%s\n" "${options[@]}" | fzf --prompt="Select package version to install: " --height=8 --layout=reverse --border)

if [[ $CHOICE == "Cancel" ]]; then
    echo -e "${RED}Installation canceled by the user.${RESET}"
    clear
    exit 0
fi

fzf_confirm "Install $CHOICE?" || {
    echo -e "${RED}Installation canceled by the user.${RESET}"
    clear
    exit 0
}

echo -e "${YELLOW}Preparing installation environment...${RESET}"
cd "$CACHE_DIR" || exit 1
if [ -d "pkgs" ]; then
    echo -e "${YELLOW}Updating existing repository...${RESET}"
    git -C pkgs pull
else
    echo -e "${YELLOW}Cloning repository...${RESET}"
    git clone https://github.com/carch-org/pkgs
fi

cd pkgs || {
    echo -e "${RED}Failed to access repository.${RESET}"
    exit 1
}

case "$CHOICE" in
    "Carch-git [GitHub Latest Commit]")
        echo -e "${YELLOW}Installing Git Version (Latest Commit)...${RESET}"
        cd carch-git || exit 1
        ;;
    "Stable Release [Recommended]")
        echo -e "${YELLOW}Installing Stable Release...${RESET}"
        cd carch || exit 1
        ;;
esac

echo -e "${CYAN}Building and installing package...${RESET}"
makepkg -si

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}${BOLD}INSTALLATION COMPLETE${RESET}"
    sleep 0.7
    echo -e "${GREEN}Carch has been successfully installed!${RESET}"
    sleep 0.7
    echo -e "${GREEN}Run 'carch -h' to see available options${RESET}"
    sleep 1
    echo -e "${CYAN}Thank you again! If you find any bugs, feel free to submit an issue report on GitHub :)${RESET}"
else
    echo -e "${RED}Failed to build or install package.${RESET}"
    exit 1
fi

fzf_confirm "Clean up installation files?" && {
    echo "Cleaning up..."
    rm -rf "$CACHE_DIR/pkgs"
    echo -e "${GREEN}Cleanup complete.${RESET}"
}

exit 0
