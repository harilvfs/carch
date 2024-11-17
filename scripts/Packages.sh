#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE="\e[34m"
ENDCOLOR="\e[0m"
RESET='\033[0m'

install_paru() {
    if ! command -v paru &> /dev/null; then
        echo -e "${RED}Paru not found. Installing...${RESET}"
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
        echo -e "${GREEN}Paru is already installed.${RESET}"
    fi
}

install_communication() {
    install_paru
    while true; do
        comm_choice=$(gum choose "Discord" "Signal" "Telegram" "Keybase" "Exit")

        case $comm_choice in
            "Discord") paru -S discord ;;
            "Signal") paru -S signal-desktop ;;
            "Telegram") paru -S telegram-desktop ;;
            "Keybase") paru -s keybase-bin ;;
            "Exit") break ;;
        esac
    done
}

install_streaming() {
    while true; do
        stream_choice=$(gum choose "OBS Studio" "Exit")

        case $stream_choice in
            "OBS Studio") sudo pacman -S obs-studio ;;
            "Exit") break ;;
        esac
    done
}

install_editing() {
    while true; do
        edit_choice=$(gum choose "GIMP (Image)" "Kdenlive (Videos)" "Exit")

        case $edit_choice in
            "GIMP (Image)") sudo pacman -S gimp ;;
            "Kdenlive (Videos)") sudo pacman -S kdenlive ;;
            "Exit") break ;;
        esac
    done
}

install_browsers() {
    install_paru
    while true; do
        browser_choice=$(gum choose "Brave" "Firefox" "Google Chrome" "Chromium" "Qute Browser" "Zen Browser" "Thorium Browser" "Tor Browser" "Exit")

        case $browser_choice in
            "Brave") paru -S brave-bin ;;
            "Firefox") sudo pacman -S firefox ;;
            "Google Chrome") paru -S google-chrome ;;
            "Chromium") sudo pacman -S chromium ;;
            "Qute Browser") sudo pacman -S qutebrowser ;;
            "Zen Browser") paru -S zen-browser-bin ;;
            "Thorium Browser") paru -S thorium-browser-bin ;;
            "Tor Browser") paru -S tor-browser-bin ;;
            "Exit") break ;;
        esac
    done
}

install_filemanagers() {
    while true; do
        fm_choice=$(gum choose "Nemo" "Thunar" "Dolphin" "LF (Terminal File Manager)" "Ranger" "Nautilus" "Exit")

        case $fm_choice in
            "Nemo") sudo pacman -S nemo ;;
            "Thunar") sudo pacman -S thunar ;;
            "Dolphin") sudo pacman -S dolphin ;;
            "LF (Terminal File Manager)") sudo pacman -S lf ;;
            "Ranger") sudo pacman -S ranger ;;
            "Nautilus") sudo pacman -S nautilus ;;
            "Exit") break ;;
        esac
    done
}

install_music() {
    install_paru
    while true; do
        music_choice=$(gum choose "Youtube-Music" "Spotube" "Spotify" "Rhythmbox" "Exit")

        case $music_choice in
            "Youtube-Music") paru -S youtube-music-bin ;;
            "Spotube") paru -S spotube ;;
            "Spotify") paru -S spotify ;;
            "Rhythmbox") paru -S rhythmbox ;;
            "Exit") break ;;
        esac
    done
}

install_texteditor() {
    install_paru
    while true; do
        texteditor_choice=$(gum choose "Cursor (AI Code Editor)" "Visual Studio Code (VSCODE)" "Vscodium" "ZED Editor" "Neovim" "Vim" "Code-OSS" "Exit")

        case $texteditor_choice in
            "Cursor (AI Code Editor)") paru -S cursor-bin ;;
            "Visual Studio Code (VSCODE)") paru -S visual-studio-code-bin ;;
            "Vscodium") paru -S vscodium-bin ;;
            "ZED Editor") paru -S zed-preview-bin ;;
            "Neovim") paru -S neovim ;;
            "Vim") paru -S vim ;;
            "Code-OSS") paru -S coder-oss ;;
            "Exit") break ;;
        esac
    done
}

install_multimedia() {
    install_paru
    while true; do
        multimedia_choice=$(gum choose "VLC" "Netflix[Unoffical]" "Exit")

        case $multimedia_choice in
            "VLC") paru -S vlc ;;
            "Netflix[Unoffical]") paru -S netflix ;;
            "Exit") break ;;
        esac
    done
}

install_github() {
    install_paru
    while true; do
        github_choice=$(gum choose "Git" "Github" "Exit")

        case $github_choice in        
            "Git") paru -S git ;;
            "Github") paru -S github-desktop-bin ;;
            "Exit") break ;;
        esac
    done
}

install_thunarpreview() {
    install_paru
    while true; do
        echo -e "${BLUE}This package enables thumbnail previews in the Thunar file manager.${RESET}"
        echo -e "${YELLOW}-------------------------------------------------------------------${RESET}"
        thunarpreview_choice=$(gum choose "Tumbler" "Exit")

        case $thunarpreview_choice in
            "Tumbler") paru -S tumbler ;;
            "Exit") break ;;
        esac
    done
}

install_andriod() {
    install_paru
    while true; do
        echo -e "${BLUE}Android debloat and subsystem packages.${RESET}"
        echo -e "${YELLOW}---------------------------------------${RESET}"
        andriod_choice=$(gum choose "Gvfs-MTP [Displays Android phones via USB]" "ADB" "Exit")

        case $andriod_choice in
            "Gvfs-MTP [Displays Android phones via USB]") paru -S gvfs-mtp ;;
            "ADB") paru -S adb ;;
            "Exit") break ;;
        esac
    done
}

    
while true; do
    clear 
    echo -e "${BLUE}"
    cat <<"EOF"
----------------------------------------------------------------------------------------------------------------------------
 
██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗         ██████╗  █████╗  ██████╗██╗  ██╗ █████╗  ██████╗ ███████╗███████╗
██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║         ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔════╝ ██╔════╝██╔════╝
██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║         ██████╔╝███████║██║     █████╔╝ ███████║██║  ███╗█████╗  ███████╗
██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║         ██╔═══╝ ██╔══██║██║     ██╔═██╗ ██╔══██║██║   ██║██╔══╝  ╚════██║
██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗    ██║     ██║  ██║╚██████╗██║  ██╗██║  ██║╚██████╔╝███████╗███████║
╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚══════╝╚══════╝       ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝
                                                                                                                           
----------------------------------------------------------------------------------------------------------------------------
EOF
echo -e "${ENDCOLOR}"
    main_choice=$(gum choose "Communication & Chatting" "Live Streaming/Recording" "Editing" "Browsers" "File Managers" "Music" "Coding & Text Editor" "Multimedia" "Github" "Thunar " "Andriod" "Exit")

    case $main_choice in
        "Communication & Chatting") install_communication ;;
        "Live Streaming/Recording") install_streaming ;;
        "Editing") install_editing ;;
        "Browsers") install_browsers ;;
        "File Managers") install_filemanagers ;;
        "Music") install_music ;;
        "Coding & Text Editor") install_texteditor ;;
        "Multimedia") install_multimedia ;;
        "Github") install_github ;;
        "Thunar ") install_thunarpreview ;;
        "Andriod") install_andriod ;;
        "Exit") exit ;;
    esac
done
