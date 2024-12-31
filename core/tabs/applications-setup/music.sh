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

install_music_app() {
    install_paru
    case $1 in
        "Youtube-Music")
            gum spin --spinner dot --title "Installing Youtube-Music..." -- paru -S youtube-music-bin --noconfirm &>/dev/null
            version=$(paru -Qi youtube-music-bin | grep Version | awk '{print $3}')
            gum format "🎉 **Youtube-Music installed successfully! Version: $version**"
            ;;
        "Spotube")
            gum spin --spinner dot --title "Installing Spotube..." -- paru -S spotube --noconfirm &>/dev/null
            version=$(paru -Qi spotube | grep Version | awk '{print $3}')
            gum format "🎉 **Spotube installed successfully! Version: $version**"
            ;;
        "Spotify")
            gum spin --spinner dot --title "Installing Spotify..." -- paru -S spotify --noconfirm &>/dev/null
            version=$(paru -Qi spotify | grep Version | awk '{print $3}')
            gum format "🎉 **Spotify installed successfully! Version: $version**"
            ;;
        "Rhythmbox")
            gum spin --spinner dot --title "Installing Rhythmbox..." -- paru -S rhythmbox --noconfirm &>/dev/null
            version=$(paru -Qi rhythmbox | grep Version | awk '{print $3}')
            gum format "🎉 **Rhythmbox installed successfully! Version: $version**"
            ;;
        *)
            gum format "❌ **Invalid choice. Please try again.**"
            ;;
    esac
}

install_music() {
    echo -e "Select a music app to install:"
    echo -e "1) Youtube-Music"
    echo -e "2) Spotube"
    echo -e "3) Spotify"
    echo -e "4) Rhythmbox"
    echo -e "5) Exit"

    read -p "Enter your choice (1-5): " choice
    case $choice in
        1) install_music_app "Youtube-Music" ;;
        2) install_music_app "Spotube" ;;
        3) install_music_app "Spotify" ;;
        4) install_music_app "Rhythmbox" ;;
        5) echo "Exiting..."; exit 0 ;;
        *) gum format "❌ **Invalid choice. Please try again.**" ;;
    esac
}

install_music

