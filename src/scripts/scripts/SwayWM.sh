#!/bin/bash

clear

GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m"

print_message() {
    echo -e "${1}${2}${NC}"
}

command_exists() {
    command -v "$1" &>/dev/null
}

install_aur_helper() {
    if [ -f /etc/arch-release ]; then
        if ! command_exists yay && ! command_exists paru; then
            print_message $GREEN "Installing yay as AUR helper..."
            git clone https://aur.archlinux.org/yay.git /tmp/yay
            cd /tmp/yay || exit
            makepkg -si --noconfirm
            cd ..
            rm -rf /tmp/yay
        else
            print_message $YELLOW "AUR helper (yay or paru) already installed."
        fi
    fi
}

install_arch_packages() {
    local packages=("$@")
    local missing_pkgs=()

    for pkg in "${packages[@]}"; do
        if ! pacman -Qq "$pkg" &>/dev/null; then
            missing_pkgs+=("$pkg")
        fi
    done

    if [ ${#missing_pkgs[@]} -ne 0 ]; then
        print_message $GREEN "Installing missing packages: ${missing_pkgs[*]}"
        sudo pacman -S --noconfirm "${missing_pkgs[@]}"
    else
        print_message $YELLOW "All required packages are already installed."
    fi
}

install_fedora_packages() {
    local packages=("$@")
    local missing_pkgs=()

    for pkg in "${packages[@]}"; do
        if ! rpm -q "$pkg" &>/dev/null; then
            missing_pkgs+=("$pkg")
        fi
    done

    if [ ${#missing_pkgs[@]} -ne 0 ]; then
        print_message $GREEN "Installing missing packages: ${missing_pkgs[*]}"
        sudo dnf install -y "${missing_pkgs[@]}"
    else
        print_message $YELLOW "All required packages are already installed."
    fi
}

install_aur_packages() {
    local packages=("$@")
    local missing_pkgs=()

    for pkg in "${packages[@]}"; do
        if ! yay -Qq "$pkg" &>/dev/null; then
            missing_pkgs+=("$pkg")
        fi
    done

    if [ ${#missing_pkgs[@]} -ne 0 ]; then
        print_message $GREEN "Installing missing AUR packages: ${missing_pkgs[*]}"
        yay -S --noconfirm "${missing_pkgs[@]}"
    else
        print_message $YELLOW "All required AUR packages are already installed."
    fi
}

install_copr_packages() {
    local repos=("$@")
    
    for repo in "${repos[@]}"; do
        print_message $GREEN "Enabling COPR repository: $repo"
        sudo dnf copr enable -y "$repo"
    done
}

build_from_source() {
    local package_name="$1"
    local repo_url="$2"
    local build_dir="/tmp/build_$package_name"
    
    if command_exists "$package_name"; then
        print_message $YELLOW "$package_name is already installed."
        return
    fi
    
    print_message $GREEN "Building $package_name from source..."
    mkdir -p "$build_dir"
    git clone "$repo_url" "$build_dir"
    cd "$build_dir" || exit
    
    if [ -f "meson.build" ]; then
        meson setup build
        ninja -C build
        sudo ninja -C build install
    elif [ -f "CMakeLists.txt" ]; then
        mkdir -p build
        cd build || exit
        cmake ..
        make
        sudo make install
    else
        ./autogen.sh 2>/dev/null || true
        ./configure 2>/dev/null || true
        make
        sudo make install
    fi
    
    cd /tmp || exit
    rm -rf "$build_dir"
    print_message $GREEN "$package_name built and installed successfully."
}

manage_dotfiles() {
    local repo_url="$1"
    local repo_dir="$2"
    local backup_dir="$3"

    if ! command_exists gum; then
        if [ -f /etc/fedora-release ]; then
            sudo dnf install -y gum
        elif [ -f /etc/arch-release ]; then
            sudo pacman -S --noconfirm gum
        fi
    fi

    if [ -d "$repo_dir" ]; then
        if gum confirm "Existing dotfiles detected. Overwrite?"; then
            rm -rf "$repo_dir"
        else
            print_message $YELLOW "Skipping dotfiles cloning."
            return
        fi
    fi

    git clone "$repo_url" "$repo_dir"

    mkdir -p "$backup_dir"

    for config in "$repo_dir"/*; do
        local config_name=$(basename "$config")
        if [ -e "$HOME/.config/$config_name" ]; then
            if gum confirm "Existing config $config_name detected. Backup?"; then
                mv "$HOME/.config/$config_name" "$backup_dir/"
            fi
        fi
        cp -r "$config" "$HOME/.config/"
    done

    cp -r "$repo_dir"/.azotebg "$HOME/"
    cp -r "$repo_dir"/.gtkrc-2.0 "$HOME/"
    cp -r "$repo_dir"/.profile "$HOME/"

    if [ -d "$repo_dir/usr/share" ]; then
        print_message $GREEN "Copying system-wide files..."
        sudo cp -r "$repo_dir/usr/share" /usr/
    fi
}

manage_themes_icons() {
    local repo_url="$1"
    local target_dir="$2"
    local repo_name=$(basename "$repo_url" .git)

    if [ -d "$target_dir/$repo_name" ]; then
        if gum confirm "Existing $repo_name detected. Overwrite?"; then
            rm -rf "$target_dir/$repo_name"
        else
            print_message $YELLOW "Skipping $repo_name cloning."
            return
        fi
    fi

    git clone "$repo_url" "$target_dir/$repo_name"
}

print_message $BLUE "$(figlet -f slant "SwayWM")"

print_message "    "

print_message $BLUE "If the setup fails, please manually use the dotfiles from:
https://github.com/harilvfs/swaydotfiles"

print_message "    "

if ! command_exists figlet; then
    if [ -f /etc/fedora-release ]; then
        sudo dnf install -y figlet
    elif [ -f /etc/arch-release ]; then
        sudo pacman -S --noconfirm figlet
    fi
    print_message $BLUE "$(figlet -f slant "SwayWM")"
fi

if ! command_exists gum; then
    if [ -f /etc/fedora-release ]; then
        sudo dnf install -y gum
    elif [ -f /etc/arch-release ]; then
        sudo pacman -S --noconfirm gum
    fi
fi

if ! gum confirm "Continue with Sway setup?"; then
    print_message $RED "Setup aborted by the user."
    exit 1
fi

if [ -f /etc/fedora-release ]; then
    print_message $GREEN "Fedora Linux detected. Proceeding with setup..."
    
    if ! rpm -q rpmfusion-free-release &>/dev/null; then
        print_message $GREEN "Enabling RPM Fusion Free repository..."
        sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    fi
    
    if ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
        print_message $GREEN "Enabling RPM Fusion NonFree repository..."
        sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    fi
    
    COPR_REPOS=("erikreider/SwayFX" "alebastr/sway-extras" "solopasha/hyprland")
    install_copr_packages "${COPR_REPOS[@]}"
    
    FEDORA_BASE_PKGS=(git make gcc gcc-c++ meson ninja-build pkgconf-pkg-config cmake autoconf automake libtool)
    install_fedora_packages "${FEDORA_BASE_PKGS[@]}"
    
    FEDORA_DEV_PKGS=(
        wayland-devel wayland-protocols-devel libinput-devel libevdev-devel libxkbcommon-devel
        wlroots-devel cairo-devel pango-devel gdk-pixbuf2-devel json-c-devel scdoc pcre2-devel
        gtk3-devel libsigc++20-devel jsoncpp-devel libdbusmenu-gtk3-devel libxkbcommon-devel
        fmt-devel spdlog-devel glibmm2.4-devel gtkmm30-devel alsa-lib-devel pipewire-devel
        libnl3-devel iw gtk-layer-shell-devel
    )
    install_fedora_packages "${FEDORA_DEV_PKGS[@]}"
    
    FEDORA_SWAY_PKGS=(
        swayfx fastfetch fish foot nwg-drawer swappy swaylock waybar
        jetbrains-mono-fonts fontawesome-fonts
        alsa-utils pipewire-pulseaudio bluez bluez-tools blueman
        wob swaybg swayidle fuzzel wl-clipboard grim slurp mako
        blueberry pamixer pavucontrol polkit-gnome xdg-desktop-portal-wlr
        xorg-x11-server-Xwayland dex qt5-qtwayland qt6-qtwayland
        alacritty
    )
    install_fedora_packages "${FEDORA_SWAY_PKGS[@]}"
    
    if ! rpm -q wf-recorder &>/dev/null; then
        print_message $GREEN "Building wf-recorder from source..."
        build_from_source "wf-recorder" "https://github.com/ammen99/wf-recorder.git"
    fi
    
    if ! rpm -q nwg-hello &>/dev/null; then
        print_message $GREEN "Building nwg-hello from source..."
        build_from_source "nwg-hello" "https://github.com/nwg-piotr/nwg-hello.git"
    fi
    
    if ! rpm -q waybar-module-pacman-updates &>/dev/null; then
        print_message $GREEN "Building waybar-module-pacman-updates from source..."
        sudo dnf install -y waybar-devel
        build_from_source "waybar-module-pacman-updates" "https://github.com/axeel/waybar-module-pacman-updates.git"
    fi
    
    if ! command_exists autotiling; then
        print_message $GREEN "Installing autotiling via pip in a virtual environment..."
        sudo dnf install -y python3-pip python3-virtualenv
        mkdir -p ~/.local/venvs
        python3 -m venv ~/.local/venvs/sway-tools
        source ~/.local/venvs/sway-tools/bin/activate
        pip install autotiling
        deactivate

        sudo ln -sf ~/.local/venvs/sway-tools/bin/autotiling /usr/local/bin/autotiling
    fi
    
    if ! rpm -q cliphist &>/dev/null; then
        print_message $GREEN "Installing cliphist via go..."
        sudo dnf install -y golang
        go install go.senan.xyz/cliphist@latest
        sudo cp ~/go/bin/cliphist /usr/local/bin/
    fi
    
    if ! rpm -q gtklock &>/dev/null; then
        print_message $GREEN "Building gtklock from source..."
        build_from_source "gtklock" "https://github.com/jovanlanik/gtklock.git"
    fi
    
    if ! rpm -q kvantum &>/dev/null; then
    print_message $GREEN "Installing Kvantum from repositories..."
    sudo dnf install -y kvantum
    fi
    
elif [ -f /etc/arch-release ]; then
    print_message $GREEN "Arch Linux detected. Proceeding with setup..."
    
    REQUIRED_PKGS=(git base-devel make less)
    install_arch_packages "${REQUIRED_PKGS[@]}"

    install_aur_helper

    PACMAN_PKGS=(fastfetch fish foot nwg-drawer bluetui ttf-jetbrains-mono ttf-jetbrains-mono-nerd swappy swaylock waybar pango cairo gdk-pixbuf2 json-c scdoc meson ninja pcre2 gtk-layer-shell jsoncpp libsigc++ libdbusmenu-gtk3 libxkbcommon fmt spdlog glibmm gtkmm3 alsa-utils pipewire-pulse libnl iw wob swaybg swayidle fuzzel otf-font-awesome ttf-jetbrains-mono ttf-nerd-fonts-symbols ttf-ubuntu-font-family wl-clipboard grim slurp mako blueberry pamixer pavucontrol gnome-keyring polkit-gnome cliphist wl-clipboard autotiling gtklock swayidle xdg-desktop-portal xdg-desktop-portal-wlr xorg-xhost sddm kvantum qt5-wayland qt6-wayland dex wf-recorder nwg-hello blueman bluez bluez-libs bluez-qt bluez-qt5 bluez-tools bluez-utils alacritty kitty)
    install_arch_packages "${PACMAN_PKGS[@]}"

    YAY_PKGS=(swayfx waybar-module-pacman-updates-git wlroots-git)
    install_aur_packages "${YAY_PKGS[@]}"
else
    print_message $RED "Unsupported distribution. Exiting."
    exit 1
fi

DOTFILES_REPO="https://github.com/harilvfs/swaydotfiles"
DOTFILES_DIR="$HOME/swaydotfiles"
BACKUP_DIR="$HOME/.swaydotfiles/backup"
manage_dotfiles "$DOTFILES_REPO" "$DOTFILES_DIR" "$BACKUP_DIR"

THEME_REPO="https://github.com/harilvfs/themes"
ICON_REPO="https://github.com/harilvfs/icons"
THEME_DIR="$HOME/.themes"
ICON_DIR="$HOME/.icons"
manage_themes_icons "$THEME_REPO" "$THEME_DIR"
manage_themes_icons "$ICON_REPO" "$ICON_DIR"

if gum confirm "Do you want additional wallpapers?"; then
    WALLPAPER_REPO="https://github.com/harilvfs/wallpapers"
    WALLPAPER_DIR="$HOME/Pictures/wallpapers"
    manage_themes_icons "$WALLPAPER_REPO" "$WALLPAPER_DIR"
    print_message $GREEN "Wallpapers are located in $WALLPAPER_DIR. Apply them using azote."
fi

is_sddm_installed() {
    if command -v sddm &> /dev/null; then
        return 0 
    else
        return 1
    fi
}

install_sddm() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case $ID in
            arch*)
                sudo pacman -S --noconfirm sddm
                ;;
            fedora*)
                sudo dnf install -y sddm
                ;;
            *)
                echo "Unsupported distribution."
                exit 1
                ;;
        esac
    fi
}

apply_sddm_theme() {
    theme_dir="/usr/share/sddm/themes/catppuccin-mocha"

if [ -d "$theme_dir" ]; then
    print_message "$YELLOW" "$theme_dir already exists."
    if gum confirm "Do you want to remove the existing theme and continue?"; then
        sudo rm -rf "$theme_dir"
        print_message "$GREEN" "$theme_dir removed."
    else
        print_message "$RED" "$theme_dir not removed, exiting."
        exit 1
    fi
fi

    temp_dir=$(mktemp -d)
    echo "Downloading Catppuccin Mocha theme..."
    wget https://github.com/catppuccin/sddm/releases/download/v1.0.0/catppuccin-mocha.zip -O "$temp_dir/catppuccin-mocha.zip"
    
    unzip "$temp_dir/catppuccin-mocha.zip" -d "$temp_dir"
    
    cd "$temp_dir/catppuccin-mocha" || exit 
    
    echo "Copying the theme to /usr/share/sddm/themes..."
    sudo cp -r "$temp_dir/catppuccin-mocha" /usr/share/sddm/themes/
    
    rm -rf "$temp_dir"
}

configure_sddm_theme() {
    echo "Configuring sddm.conf to use the Catppuccin Mocha theme..."
    
    if [ ! -f /etc/sddm.conf ]; then
        sudo touch /etc/sddm.conf
    fi

    if ! grep -q "\[Theme\]" /etc/sddm.conf; then
        echo "[Theme]" | sudo tee -a /etc/sddm.conf > /dev/null
    fi
    
    sudo sed -i '/\[Theme\]/a Current=catppuccin-mocha' /etc/sddm.conf
}

enable_start_sddm() {
    echo "Checking for existing display managers..."

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
    fi

    if command -v gdm &> /dev/null; then
        echo "GDM detected. Removing GDM..."
        sudo systemctl stop gdm
        sudo systemctl disable gdm --now
        if [[ "$ID" == "arch" || "$ID_LIKE" == *"arch"* ]]; then
            sudo pacman -Rns --noconfirm gdm
        elif [[ "$ID" == "fedora" ]]; then
            sudo dnf remove -y gdm
        fi
    fi

    if command -v lightdm &> /dev/null; then
        echo "LightDM detected. Removing LightDM..."
        sudo systemctl stop lightdm
        sudo systemctl disable lightdm --now
        if [[ "$ID" == "arch" || "$ID_LIKE" == *"arch"* ]]; then
            sudo pacman -Rns --noconfirm lightdm
        elif [[ "$ID" == "fedora" ]]; then
            sudo dnf remove -y lightdm
        fi
    fi

    echo "Enabling and starting the sddm service..."
    sudo systemctl enable sddm --now
}

if [ -f /etc/fedora-release ]; then
    print_message $GREEN "Installing additional Fedora dependencies..."
    
    if ! command -exists azote; then
        print_message $GREEN "Installing azote..."
        sudo dnf install azote
    fi
    
    install_fedora_packages "wget unzip"
fi

if ! is_sddm_installed; then
    install_sddm
else
    echo "Sddm is already installed, skipping installation."
fi

apply_sddm_theme

configure_sddm_theme

enable_start_sddm

if [ -f /etc/fedora-release ]; then
    print_message $GREEN "Setting up Wayland environment for Fedora..."
    
    if [ ! -f /usr/share/wayland-sessions/sway.desktop ]; then
        sudo mkdir -p /usr/share/wayland-sessions
        cat << EOF | sudo tee /usr/share/wayland-sessions/sway.desktop > /dev/null
[Desktop Entry]
Name=Sway
Comment=An i3-compatible Wayland compositor
Exec=sway
Type=Application
EOF
    fi
    
    cat << EOF | sudo tee /etc/environment.d/wayland.conf > /dev/null
# Wayland environment variables
MOZ_ENABLE_WAYLAND=1
QT_QPA_PLATFORM=wayland
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
XDG_CURRENT_DESKTOP=sway
XDG_SESSION_TYPE=wayland
GDK_BACKEND=wayland
CLUTTER_BACKEND=wayland
SDL_VIDEODRIVER=wayland
_JAVA_AWT_WM_NONREPARENTING=1
EOF
fi

print_message $BLUE "Default keybindings: Super+Enter (Terminal), Super+D (App Launcher)"
print_message $GREEN "SwayWM setup complete!"
