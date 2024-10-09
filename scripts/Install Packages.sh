#!/bin/bash

install_paru() {
    if ! command -v paru &> /dev/null; then
        echo "Paru not found. Installing..."
        sudo pacman -S --needed base-devel

        temp_dir=$(mktemp -d)
        cd "$temp_dir" || { echo "Failed to create temp directory"; exit 1; }

        git clone https://aur.archlinux.org/paru.git
        cd paru || { echo "Failed to enter paru directory"; exit 1; }
        makepkg -si
        
        cd ..
        rm -rf "$temp_dir"
        echo "Paru installed successfully."
    else
        echo "Paru is already installed."
    fi
}

install_communication() {
    while true; do
        echo "Communication Menu:"
        echo "1) Discord"
        echo "2) Signal"
        echo "3) Telegram"
        echo "4) Exit"
        read -p "Choose an option: " comm_choice

        case $comm_choice in
            1) paru -S discord ;;
            2) paru -S signal-desktop ;;
            3) paru -S telegram-desktop ;;
            4) break ;;  
            *) echo "Invalid option" ;;
        esac
    done
}

install_streaming() {
    while true; do
        echo "Live Streaming/Recording Menu:"
        echo "1) OBS Studio"
        echo "2) Exit"
        read -p "Choose an option: " stream_choice

        case $stream_choice in
            1) sudo pacman -S obs-studio ;;
            2) break ;;  
            *) echo "Invalid option" ;;
        esac
    done
}

install_editing() {
    while true; do
        echo "Editing Menu:"
        echo "1) GIMP"
        echo "2) Exit"
        read -p "Choose an option: " edit_choice

        case $edit_choice in
            1) sudo pacman -S gimp ;;
            2) break ;;  
            *) echo "Invalid option" ;;
        esac
    done
}

install_browsers() {
    install_paru
    while true; do
        echo "Browsers Menu:"
        echo "1) Brave"
        echo "2) Firefox"
        echo "3) Google Chrome"
        echo "4) Chromium"
        echo "5) Qutebrowser"
        echo "6) Zen Browser"
        echo "7) Exit"
        read -p "Choose a browser to install: " browser_choice

        case $browser_choice in
            1) paru -S brave-bin ;;
            2) sudo pacman -S firefox ;;
            3) paru -S google-chrome ;;
            4) sudo pacman -S chromium ;;
            5) sudo pacman -S qutebrowser ;;
            6) paru -S zen-browser-bin ;;
            7) break ;;  
            *) echo "Invalid option" ;;
        esac
    done
}

install_filemanagers() {
    while true; do
        echo "File Manager Menu:"
        echo "1) Nemo"
        echo "2) Thunar"
        echo "3) Dolphin"
        echo "4) LF (Terminal File Manager)"
        echo "5) Exit"
        read -p "Choose a file manager: " fm_choice

        case $fm_choice in
            1) sudo pacman -S nemo ;;
            2) sudo pacman -S thunar ;;
            3) sudo pacman -S dolphin ;;
            4) sudo pacman -S lf ;;
            5) break ;;  
            *) echo "Invalid option" ;;
        esac
    done
}

while true; do
    echo "Main Menu:"
    echo "1) Communication"
    echo "2) Live Streaming/Recording"
    echo "3) Editing"
    echo "4) Browsers"
    echo "5) File Managers"
    echo "6) Exit"
    read -p "Choose a category: " main_choice

    case $main_choice in
        1) install_communication ;;
        2) install_streaming ;;
        3) install_editing ;;
        4) install_browsers ;;
        5) install_filemanagers ;;
        6) exit ;;  
        *) echo "Invalid option" ;;
    esac
done

