#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

aur_helper=""

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

fzf_confirm() {
    local prompt="$1"
    local options=("Yes" "No")
    local selected=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                     --height=40% \
                                                     --prompt="$prompt " \
                                                     --header="Confirm" \
                                                     --pointer="➤" \
                                                     --color='fg:white,fg+:green,bg+:black,pointer:green')
    [[ "$selected" == "Yes" ]]
}

fzf_select() {
    local prompt="$1"
    shift
    local options=("$@")
    printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                      --height=40% \
                                      --prompt="$prompt " \
                                      --header="Select Option" \
                                      --pointer="➤" \
                                      --color='fg:white,fg+:blue,bg+:black,pointer:blue'
}

detect_package_manager() {
    if command -v pacman &> /dev/null; then
        pkg_manager="pacman"
    elif command -v dnf &> /dev/null; then
        pkg_manager="dnf"
    else
        echo -e "${RED}Unsupported package manager. Please install Picom manually.${ENDCOLOR}"
        exit 1
    fi
}

install_aur_helper() {
    local aur_helpers=("yay" "paru")
    for helper in "${aur_helpers[@]}"; do
        if command -v "$helper" &> /dev/null; then
            echo -e "${GREEN}:: AUR helper '$helper' is already installed. Using it.${ENDCOLOR}"
            aur_helper="$helper"
            return
        fi
    done

    echo -e "${RED}No AUR helper found. Installing yay...${ENDCOLOR}"
    sudo pacman -S --needed --noconfirm git base-devel
    temp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
    cd "$temp_dir/yay" || {
                            echo -e "${RED}Failed to enter yay directory${ENDCOLOR}"
                                                                                      exit 1
    }
    makepkg -si --noconfirm
    cd ~ || exit 1
    rm -rf "$temp_dir"
    echo -e "${GREEN}yay installed successfully.${ENDCOLOR}"
    aur_helper="yay"
}

print_source_message() {
    echo -e "${TEAL}:: This Picom build is from FT-Labs.${ENDCOLOR}"
    echo -e "${TEAL}:: Check out here: ${GREEN}https://github.com/FT-Labs/picom${ENDCOLOR}"
}

install_dependencies_normal() {
    echo -e "${GREEN}:: Installing Picom...${ENDCOLOR}"
    case "$pkg_manager" in
        pacman) sudo pacman -S --needed --noconfirm picom ;;
        dnf) sudo dnf install -y picom ;;
    esac
}

setup_picom_ftlabs() {
    echo -e "${GREEN}:: Installing Picom FT-Labs (picom-ftlabs-git) via $aur_helper...${ENDCOLOR}"
    "$aur_helper" -S --noconfirm picom-ftlabs-git
}

install_picom_ftlabs_fedora() {
    echo -e "${GREEN}:: Installing dependencies for Picom FT-Labs (Fedora)...${ENDCOLOR}"
    sudo dnf install -y dbus-devel gcc git libconfig-devel libdrm-devel libev-devel libX11-devel libX11-xcb libXext-devel libxcb-devel libGL-devel libEGL-devel libepoxy-devel meson pcre2-devel pixman-devel uthash-devel xcb-util-image-devel xcb-util-renderutil-devel xorg-x11-proto-devel xcb-util-devel cmake

    echo -e "${GREEN}:: Cloning Picom FT-Labs repository...${ENDCOLOR}"
    git clone https://github.com/FT-Labs/picom ~/.cache/picom
    cd ~/.cache/picom || {
                           echo -e "${RED}Failed to clone Picom repo.${ENDCOLOR}"
                                                                                   exit 1
    }

    echo -e "${GREEN}:: Building Picom with meson and ninja...${ENDCOLOR}"
    meson setup --buildtype=release build
    ninja -C build

    echo -e "${GREEN}:: Installing the built Picom binary...${ENDCOLOR}"
    sudo cp build/src/picom /usr/local/bin
    sudo ldconfig

    echo -e "${GREEN}Done...${ENDCOLOR}"
}

download_config() {
    local config_url="$1"
    local config_path="$HOME/.config/picom.conf"

    if [ -f "$config_path" ]; then
        if fzf_confirm "Overwrite existing picom.conf?"; then
            echo -e "${GREEN}:: Overwriting picom.conf...${ENDCOLOR}"
        else
            echo -e "${RED}:: Skipping picom.conf download...${ENDCOLOR}"
            return
        fi
    fi

    mkdir -p ~/.config
    echo -e "${GREEN}:: Downloading Picom configuration...${ENDCOLOR}"
    wget -O "$config_path" "$config_url"
}

if ! command -v fzf &> /dev/null; then
    echo -e "${RED}${BOLD}Error: fzf is not installed${NC}"
    echo -e "${YELLOW}Please install fzf before running this script:${NC}"
    echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install fzf"
    echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S fzf"
    exit 1
fi

detect_package_manager
print_source_message

choice=$(fzf_select "Choose Picom version:" "Picom with animation (FT-Labs)" "Picom normal" "Exit")

case "$choice" in
    "Picom with animation (FT-Labs)")
        case "$pkg_manager" in
            pacman)
                install_aur_helper
                setup_picom_ftlabs
                ;;
            dnf)
                install_picom_ftlabs_fedora
                ;;
        esac
        download_config "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/picom/picom.conf"
        echo -e "${GREEN}:: Picom setup completed with animations from FT-Labs!${ENDCOLOR}"
        ;;
    "Picom normal")
        install_dependencies_normal
        download_config "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/config/picom/picom.conf"
        echo -e "${GREEN}:: Picom setup completed without animations!${ENDCOLOR}"
        ;;
    "Exit")
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option. Please try again.${ENDCOLOR}"
        exit 1
        ;;
esac
