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

install_obs_studio() {
    gum spin --spinner dot --title "Installing OBS Studio..." -- sudo pacman -S --noconfirm obs-studio
    version=$(pacman -Qi obs-studio | grep Version | awk '{print $3}')
    gum format "🎉 **OBS Studio installed successfully! Version: $version**"
}

install_simplescreenrecorder() {
    gum confirm "The Git version builds from source and may take some time. Proceed?" && \
    gum spin --spinner dot --title "Installing SimpleScreenRecorder [Git]..." -- paru -S --noconfirm simplescreenrecorder-git
    version=$(pacman -Qi simplescreenrecorder-git | grep Version | awk '{print $3}')
    gum format "🎉 **SimpleScreenRecorder [Git] installed successfully! Version: $version**"
}

install_streaming() {
    install_paru

    echo -e "Select streaming tools to install:"
    echo -e "1) OBS Studio"
    echo -e "2) SimpleScreenRecorder [Git]"
    echo -e "3) Exit"

    read -p "Enter your choice (1/2/3): " choice

    case $choice in
        1) install_obs_studio ;;
        2) install_simplescreenrecorder ;;
        3) echo "Exiting..."; exit 0 ;;
        *) echo -e "Invalid choice. Exiting..."; exit 1 ;;
    esac
}

install_streaming

