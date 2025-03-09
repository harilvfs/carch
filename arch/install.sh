#!/bin/bash

VERSION="4.1.7"
CONFIG_DIR="$HOME/.config/carch"
CACHE_DIR="$HOME/.cache/carch-install"
LOG_FILE="$CACHE_DIR/install.log"

mkdir -p "$CONFIG_DIR" "$CACHE_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

if [ -f /etc/os-release ]; then
    DISTRO=$(grep ^NAME= /etc/os-release | cut -d= -f2 | tr -d '"')
elif command -v lsb_release &>/dev/null; then
    DISTRO=$(lsb_release -d | cut -f2)
else
    DISTRO="Unknown Linux Distribution"
fi
ARCH=$(uname -m)

if ! pacman -Qi "gum" &>/dev/null; then
    echo "Gum is required for this script. Installing gum..."
    sudo pacman -Sy --noconfirm gum || { 
        echo "Failed to install gum. Exiting."
        exit 1
    }
fi

check_and_install() {
    local pkg="$1"
    if ! pacman -Qi "$pkg" &>/dev/null; then
        gum style --foreground 3 "Installing missing dependency: $pkg"
        gum spin --spinner dot --title "Installing $pkg..." -- sudo pacman -Sy --noconfirm "$pkg"
        if [ $? -eq 0 ]; then
            gum style --foreground 2 "✓ $pkg installed successfully"
        else
            gum style --foreground 1 "✗ Failed to install $pkg"
            return 1
        fi
    else
        gum style --foreground 2 "✓ $pkg is already installed"
    fi
    return 0
}

clear

gum style \
    --border rounded \
    --border-foreground 6 \
    --align center \
    --width 50 \
    --margin "1 2" \
    --padding "1 2" \
    "$(gum style --foreground 6 --bold "CARCH")" \
    "$(gum style --foreground 7 "Version $VERSION")" \
    "$(gum style --foreground 7 "Distribution: $DISTRO")" \
    "$(gum style --foreground 7 "Architecture: $ARCH")"

gum style \
    --border normal \
    --border-foreground 3 \
    --margin "1 0" \
    --padding "1 2" \
    "Installing dependencies..."

dependencies=("figlet" "ttf-jetbrains-mono-nerd" "ttf-jetbrains-mono" "git")
failed_deps=0

for dep in "${dependencies[@]}"; do
    check_and_install "$dep" || ((failed_deps++))
done

if [ $failed_deps -gt 0 ]; then
    gum style --foreground 1 "Some dependencies failed to install. Check the logs."
    gum confirm "Continue anyway?" || exit 1
fi

gum style \
    --foreground 2 \
    --margin "1 0" \
    --padding "0 2" \
    "NOTE: Stable Release is recommended. Binary package is also suitable for use."

gum style \
    --foreground 1 \
    --margin "1 0" \
    --padding "0 2" \
    "Git package is not fully recommended as it grabs the latest commit which may have bugs."

gum style \
    --foreground 3 \
    --bold \
    --margin "1 0" \
    --padding "0 2" \
    "Select installation type:"

CHOICE=$(gum choose \
    --height 15 \
    --cursor.foreground 6 \
    --selected.foreground 6 \
    --header "Select package version to install:" \
    "Stable Release [Recommended]" \
    "Carch-bin [Compile Binary]" \
    "Carch-git [GitHub Latest Commit]" \
    "Cancel")

if [[ $CHOICE == "Cancel" ]]; then
    gum style --foreground 1 "Installation canceled by the user."
    exit 0
fi

gum confirm "Install $CHOICE?" || {
    gum style --foreground 1 "Installation canceled by the user."
    exit 0
}

gum style --foreground 3 "Preparing installation environment..."
cd "$CACHE_DIR" || exit 1
if [ -d "pkgs" ]; then
    gum style --foreground 3 "Updating existing repository..."
    gum spin --spinner dot --title "Updating repository..." -- git -C pkgs pull
else
    gum style --foreground 3 "Cloning repository..."
    gum spin --spinner dot --title "Cloning repository..." -- git clone https://github.com/carch-org/pkgs
fi

cd pkgs || {
    gum style --foreground 1 "Failed to access repository."
    exit 1
}

case "$CHOICE" in
    "Carch-git [GitHub Latest Commit]")
        gum style --foreground 3 "Installing Git Version (Latest Commit)..."
        cd carch-git || exit 1
        ;;
    "Carch-bin [Compile Binary]")
        gum style --foreground 3 "Installing Binary Package..."
        cd carch-bin || exit 1
        ;;
    "Stable Release [Recommended]")
        gum style --foreground 3 "Installing Stable Release..."
        cd carch || exit 1
        ;;
esac

gum style --foreground 6 "Building and installing package..."
makepkg -si

if [ $? -eq 0 ]; then
    gum style \
        --border double \
        --border-foreground 2 \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "1 2" \
        "$(gum style --foreground 2 --bold "INSTALLATION COMPLETE")" \
        "$(gum style --foreground 7 "Carch has been successfully installed!")" \
        "$(gum style --foreground 7 "Run 'carch -h' to see available options")"
else
    gum style --foreground 1 "Failed to build or install package."
    exit 1
fi

gum confirm "Clean up installation files?" && {
    gum spin --spinner dot --title "Cleaning up..." -- rm -rf "$CACHE_DIR/pkgs"
    gum style --foreground 2 "Cleanup complete."
}

exit 0
