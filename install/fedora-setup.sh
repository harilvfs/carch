#!/bin/bash

clear

COLOR_RESET="\e[0m"
COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_CYAN="\e[36m"
COLOR_RED="\e[31m"

VERSION="4.1.3"
TARGET_DIR="/usr/bin"
SCRIPTS_DIR="/usr/share/scripts"
DESKTOP_FILE="/usr/share/applications/carch.desktop"
MAN_PAGES_DIR="/usr/share/man/man1/carch.1"
ICON_DIR="/usr/share/icons/hicolor"

BASH_COMPLETION_DIR="/usr/share/bash-completion/completions"
ZSH_COMPLETION_DIR="/usr/share/zsh/functions/Completion/Unix"
FISH_COMPLETION_DIR="/usr/share/fish/completions"

check_dependency() {
    local dependency="$1"
    
    if ! command -v "$dependency" &>/dev/null; then
        echo -e "${COLOR_YELLOW}:: Installing missing dependency: $dependency${COLOR_RESET}"
        sudo dnf install -y "$dependency"
    fi
}

DEPENDENCIES=(
    git unzip curl wget figlet man-db man bash sed xdg-user-dirs
    google-noto-color-emoji-fonts google-noto-emoji-fonts bat
    jetbrains-mono-fonts-all tar gum bash-completion-devel
    zsh fish zsh-autosuggestions zsh-syntax-highlighting eza zip
    jetbrains-mono-fonts-all jetbrains-mono-fonts jetbrains-mono-nl-fonts
)

for pkg in "${DEPENDENCIES[@]}"; do
    check_dependency "$pkg"
done

clear

if [ -f /etc/os-release ]; then
    DISTRO=$(grep ^NAME= /etc/os-release | cut -d= -f2 | tr -d '"')
elif command -v lsb_release &>/dev/null; then
    DISTRO=$(lsb_release -d | cut -f2)
else
    DISTRO="Unknown Linux Distribution"
fi

echo -e "${COLOR_CYAN}"
figlet -f slant "Carch"
echo "Version $VERSION"
echo "Distribution: $DISTRO"
echo -e "${COLOR_RESET}"

echo -e "${COLOR_YELLOW}Select installation type:${COLOR_RESET}"
CHOICE=$(gum choose "Rolling Release" "Stable Release" "Cancel")
if [[ $CHOICE == "Cancel" ]]; then
    echo -e "${COLOR_RED}Installation canceled by the user.${COLOR_RESET}"
    exit 0
fi

echo -e "${COLOR_YELLOW}Removing existing installation...${COLOR_RESET}"
sudo rm -f "$TARGET_DIR/carch" "$DESKTOP_FILE" "$MAN_PAGES_DIR"
sudo rm -rf "$SCRIPTS_DIR"
sudo rm -f "$BASH_COMPLETION_DIR/carch"
sudo rm -f "$ZSH_COMPLETION_DIR/_carch"
sudo rm -f "$FISH_COMPLETION_DIR/carch.fish"

echo -e "${COLOR_YELLOW}Removing icons...${COLOR_RESET}"
for size in 16 24 32 48 64 128 256; do
    sudo rm -f "$ICON_DIR/${size}x${size}/apps/carch.png"
done


detect_shell() {
    local shell=$(basename "$SHELL")
    echo "$shell"
}

ensure_directories() {
    echo -e "${COLOR_YELLOW}:: Ensuring completion directories exist...${COLOR_RESET}"

    if [[ ! -d "$BASH_COMPLETION_DIR" ]]; then
        echo -e "${COLOR_CYAN}:: Creating Bash completion directory...${COLOR_RESET}"
        sudo mkdir -p "$BASH_COMPLETION_DIR" || { echo -e "${COLOR_RED}Failed to create Bash completion directory.${COLOR_RESET}"; exit 1; }
    fi

    if [[ ! -d "$ZSH_COMPLETION_DIR" ]]; then
        echo -e "${COLOR_CYAN}:: Creating Zsh completion directory...${COLOR_RESET}"
        sudo mkdir -p "$ZSH_COMPLETION_DIR" || { echo -e "${COLOR_RED}Failed to create Zsh completion directory.${COLOR_RESET}"; exit 1; }
    fi

    if [[ ! -d "$FISH_COMPLETION_DIR" ]]; then
        echo -e "${COLOR_CYAN}:: Creating Fish completion directory...${COLOR_RESET}"
        mkdir -p "$FISH_COMPLETION_DIR" || { echo -e "${COLOR_RED}Failed to create Fish completion directory.${COLOR_RESET}"; exit 1; }
    fi
}

install_completions() {
    local shell="$1"
    echo -e "${COLOR_YELLOW}:: Installing completion files for $shell...${COLOR_RESET}"

    case "$shell" in
        bash)
            sudo curl -L "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/completions/bash/carch" \
                -o "$BASH_COMPLETION_DIR/carch" &>/dev/null
            echo -e "${COLOR_GREEN}:: Bash completion installed in:${COLOR_CYAN} $BASH_COMPLETION_DIR${COLOR_RESET}"
            ;;
        zsh)
            sudo curl -L "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/completions/zsh/_carch" \
                -o "$ZSH_COMPLETION_DIR/_carch" &>/dev/null
            echo -e "${COLOR_GREEN}:: Zsh completion installed in:${COLOR_CYAN} $ZSH_COMPLETION_DIR${COLOR_RESET}"
            ;;
        fish)
            sudo curl -L "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/completions/fish/carch.fish" \
                -o "$FISH_COMPLETION_DIR/carch.fish" &>/dev/null
            echo -e "${COLOR_GREEN}:: Fish completion installed in:${COLOR_CYAN} $FISH_COMPLETION_DIR${COLOR_RESET}"
            ;;
        *)
            echo -e "${COLOR_RED}Unknown shell: $shell. Skipping completion installation.${COLOR_RESET}"
            ;;
    esac
}

download_and_install() {
    local url="$1"
    local output="$2"
    local is_executable="$3"
    echo -e "${COLOR_YELLOW}:: Downloading $(basename "$output")...${COLOR_RESET}"
    sudo curl -L "$url" --output "$output" &>/dev/null
    if [[ $is_executable == "true" ]]; then
        sudo chmod +x "$output"
    fi
}

download_scripts() {
    sudo mkdir -p "$SCRIPTS_DIR"
    download_and_install "$1" "$SCRIPTS_DIR/scripts.zip" false
    echo -e "${COLOR_YELLOW}:: Extracting scripts.zip...${COLOR_RESET}"
    
    sudo unzip -q "$SCRIPTS_DIR/scripts.zip" -d "$SCRIPTS_DIR"
    
    if [ -d "$SCRIPTS_DIR/scripts" ]; then
        sudo mv "$SCRIPTS_DIR/scripts/"* "$SCRIPTS_DIR/"
        sudo rmdir "$SCRIPTS_DIR/scripts"
    fi

    sudo chmod +x "$SCRIPTS_DIR"/*.sh
    sudo rm "$SCRIPTS_DIR/scripts.zip"
}

install_man_page() {
    download_and_install "$1" "$MAN_PAGES_DIR" false
    echo -e "${COLOR_YELLOW}:: Updating man database...${COLOR_RESET}"
    sudo mandb &>/dev/null
}

install_icons() {
    local icon_sizes=("16" "24" "32" "48" "64" "128" "256")
    local base_url="https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/source/logo"
    local icon_dir="/usr/share/icons/hicolor"

    echo -e "${COLOR_YELLOW}:: Downloading and installing icons...${COLOR_RESET}"
    for size in "${icon_sizes[@]}"; do
        local icon_path="$icon_dir/${size}x${size}/apps"
        sudo mkdir -p "$icon_path"
        sudo curl -L "$base_url/product_logo_${size}.png" --output "$icon_path/carch.png" &>/dev/null
    done
}

if [[ $CHOICE == "Rolling Release" ]]; then
    echo -e "${COLOR_YELLOW}:: Installing Rolling Release...${COLOR_RESET}"
    download_and_install "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/build/carch" "$TARGET_DIR/carch" true
    download_scripts "https://github.com/harilvfs/carch/raw/refs/heads/main/source/zip/scripts.zip"
elif [[ $CHOICE == "Stable Release" ]]; then
    echo -e "${COLOR_YELLOW}:: Installing Stable Release...${COLOR_RESET}"
    download_and_install "https://github.com/harilvfs/carch/releases/latest/download/carch" "$TARGET_DIR/carch" true
    download_scripts "https://github.com/harilvfs/carch/releases/latest/download/scripts.zip"
fi

install_man_page "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/man/carch.1"
install_icons
current_shell=$(detect_shell)
ensure_directories
install_completions "$current_shell"

echo -e "${COLOR_YELLOW}:: Creating Carch Desktop Entry...${COLOR_RESET}"
sudo tee "$DESKTOP_FILE" > /dev/null <<EOL
[Desktop Entry]
Name=Carch
Comment=An automated script for quick & easy Arch Linux system setup.
Exec=$TARGET_DIR/carch
Icon=carch
Type=Application
Terminal=true
Categories=Utility;
EOL

echo -e "${COLOR_GREEN}Carch Desktop Entry created successfully!${COLOR_RESET}"

display_message() {
    gum style --border "normal" --width 50 --padding 1 --foreground "white" --background "blue" --align "center" "Carch installed successfully!
  Use 'carch' or 'carch --tui' to run the script.
For help, type 'carch --help'."
}

display_message

