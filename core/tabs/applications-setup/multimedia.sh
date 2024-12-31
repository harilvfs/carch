#!/bin/bash

install_paru() {
    if ! command -v paru &> /dev/null; then
        echo -e "${RED}Paru not found. :: Installing...${RESET}"
        sudo pacman -S --needed base-devel

        temp_dir=$(mktemp -d)
        cd "$temp_dir" || { echo -e "${RED}Failed to create temp directory${RESET}"; exit 1; }

        git clone https://aur.archlinux.org/paru.git
        cd paru || { echo -e "${RED}Failed to enter paru directory${RESET}"; exit 1; }
        makepkg -si
        
        cd ..
        rm -rf "$temp_dir"
        echo -e "${GREEN}Paru installed successfully.${RESET}"
    else
        echo -e "${GREEN}:: Paru is already installed.${RESET}"
    fi
}

install_multimedia_app() {
    install_paru
    case $1 in
        "VLC")
            gum spin --spinner dot --title "Installing VLC..." -- paru -S vlc --noconfirm &>/dev/null
            version=$(paru -Qi vlc | grep Version | awk '{print $3}')
            gum format "🎉 **VLC installed successfully! Version: $version**"
            ;;
        "Netflix [Unofficial]")
            gum spin --spinner dot --title "Installing Netflix [Unofficial]..." -- paru -S netflix --noconfirm &>/dev/null
            version=$(paru -Qi netflix | grep Version | awk '{print $3}')
            gum format "🎉 **Netflix [Unofficial] installed successfully! Version: $version**"
            ;;
        *)
            gum format "❌ **Invalid choice. Please try again.**"
            ;;
    esac
}

install_multimedia() {
    echo -e "Select a multimedia application to install:"
    echo -e "1) VLC"
    echo -e "2) Netflix [Unofficial]"
    echo -e "3) Exit"

    read -p "Enter your choice (1-3): " choice
    case $choice in
        1) install_multimedia_app "VLC" ;;
        2) install_multimedia_app "Netflix [Unofficial]" ;;
        3) echo "Exiting..."; exit 0 ;;
        *) gum format "❌ **Invalid choice. Please try again.**" ;;
    esac
}

install_multimedia

