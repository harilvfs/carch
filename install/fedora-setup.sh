#!/bin/bash

clear

COLOR_RESET="\e[0m"
COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_CYAN="\e[36m"
COLOR_RED="\e[31m"

VERSION="4.1.2"
TARGET_DIR="/usr/bin"
SCRIPTS_DIR="$TARGET_DIR/scripts"
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
    google-noto-color-emoji-fonts google-noto-emoji-fonts
    jetbrains-mono-fonts-all tar gum bash-completion-devel
    zsh fish zsh-autosuggestions zsh-syntax-highlighting eza zip
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

CHOICE=$(gum choose "Rolling Release" "Stable Release" "Cancel")
if [[ $CHOICE == "Cancel" ]]; then
    echo -e "${COLOR_RED}Installation canceled by the user.${COLOR_RESET}"
    exit 0
fi

echo -e "${COLOR_YELLOW}Removing existing installation...${COLOR_RESET}"
sudo rm -rf "$TARGET_DIR/carch" "$SCRIPTS_DIR"
sudo rm -f "$DESKTOP_FILE" "$MAN_PAGES_DIR"
sudo rm -f "$BASH_COMPLETION_DIR/carch" "$ZSH_COMPLETION_DIR/_carch" "$FISH_COMPLETION_DIR/carch.fish"
echo -e "${COLOR_YELLOW}Removing icons...${COLOR_RESET}"
for size in 16 24 32 48 64 128 256; do
    sudo rm -f "$ICON_DIR/${size}x${size}/apps/carch.png"
done

if [[ $CHOICE == "Rolling Release" ]]; then
    echo -e "${COLOR_YELLOW}:: Cloning and building Rolling Release...${COLOR_RESET}"
    rm -rf /tmp/carch-build
    git clone --depth=1 https://github.com/harilvfs/carch.git /tmp/carch-build &>/dev/null
    cd /tmp/carch-build &>/dev/null

    echo -e "${COLOR_YELLOW}:: Installing binaries...${COLOR_RESET}"
    sudo mv build/carch "$TARGET_DIR/"

elif [[ $CHOICE == "Stable Release" ]]; then
    echo -e "${COLOR_YELLOW}Downloading and installing Stable Release...${COLOR_RESET}"
    sudo curl -L "https://github.com/harilvfs/carch/releases/latest/download/carch" -o "$TARGET_DIR/carch"
    sudo chmod +x "$TARGET_DIR/carch"
fi

echo -e "${COLOR_YELLOW}:: Downloading and installing scripts...${COLOR_RESET}"
sudo mkdir -p "$SCRIPTS_DIR"
SCRIPT_URL="https://github.com/harilvfs/carch/releases/latest/download/scripts.zip"
[[ $CHOICE == "Rolling Release" ]] && SCRIPT_URL="https://github.com/harilvfs/carch/raw/main/source/zip/scripts.zip"
curl -L "$SCRIPT_URL" -o /tmp/scripts.zip
sudo unzip -q /tmp/scripts.zip -d "$SCRIPTS_DIR"
sudo chmod +x "$SCRIPTS_DIR"/*.sh
rm /tmp/scripts.zip

echo -e "${COLOR_YELLOW}:: Installing man pages...${COLOR_RESET}"
curl -L "https://raw.githubusercontent.com/harilvfs/carch/main/man/carch.1" -o /tmp/carch.1
sudo mv /tmp/carch.1 "$MAN_PAGES_DIR"
sudo mandb &>/dev/null

detect_shell() {
    echo "$(basename "$SHELL")"
}

ensure_directories() {
    local shell="$1"
    local dir=""

    case "$shell" in
        bash)
            dir="$BASH_COMPLETION_DIR"
            ;;
        zsh)
            dir="$ZSH_COMPLETION_DIR"
            ;;
        fish)
            dir="$FISH_COMPLETION_DIR"
            ;;
        *)
            echo -e "${COLOR_RED}Unsupported shell: $shell. Skipping completion setup.${COLOR_RESET}"
            return
            ;;
    esac

    if [[ ! -d "$dir" ]]; then
        echo -e "${COLOR_CYAN}:: Creating completion directory for $shell...${COLOR_RESET}"
        sudo mkdir -p "$dir" || { echo -e "${COLOR_RED}Failed to create $shell completion directory.${COLOR_RESET}"; exit 1; }
    else
        echo -e "${COLOR_GREEN}Completion directory for $shell already exists.${COLOR_RESET}"
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

current_shell=$(detect_shell)
ensure_directories "$current_shell"
install_completions "$current_shell"

echo -e "${COLOR_YELLOW}:: Installing icons...${COLOR_RESET}"
for size in 16 24 32 48 64 128 256; do
    icon_path="$ICON_DIR/${size}x${size}/apps"
    if [[ -n "$icon_path" ]]; then
        sudo mkdir -p "$icon_path" || { echo "Failed to create $icon_path"; exit 1; }
        sudo curl -L "https://raw.githubusercontent.com/harilvfs/carch/main/source/logo/product_logo_${size}.png" -o "$icon_path/carch.png" &>/dev/null
    fi
done

echo -e "${COLOR_YELLOW}:: Creating desktop entry...${COLOR_RESET}"
sudo tee "$DESKTOP_FILE" > /dev/null <<EOL
[Desktop Entry]
Name=Carch
Comment=An automated script for quick & easy Fedora system setup.
Exec=$TARGET_DIR/carch
Icon=carch
Type=Application
Terminal=true
Categories=Utility;
EOL

display_message() {
    gum style --border "normal" --width 50 --padding 1 --foreground "white" --background "blue" --align "center" "Carch installed successfully!
  Use 'carch' or 'carch --tui' to run the script.
For help, type 'carch --help'."
}

display_message

