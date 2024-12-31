#!/bin/bash

install_gimp() {
    gum spin --spinner dot --title "Installing GIMP..." -- sudo pacman -S --noconfirm gimp
    version=$(pacman -Qi gimp | grep Version | awk '{print $3}')
    gum format "🎉 **GIMP installed successfully! Version: $version**"
}

install_kdenlive() {
    gum spin --spinner dot --title "Installing Kdenlive..." -- sudo pacman -S --noconfirm kdenlive
    version=$(pacman -Qi kdenlive | grep Version | awk '{print $3}')
    gum format "🎉 **Kdenlive installed successfully! Version: $version**"
}

install_editing() {
    echo -e "Select editing tools to install:"
    echo -e "1) GIMP (Image)"
    echo -e "2) Kdenlive (Videos)"
    echo -e "3) Exit"

    read -p "Enter your choice (1/2/3): " choice

    case $choice in
        1) install_gimp ;;
        2) install_kdenlive ;;
        3) echo "Exiting..."; exit 0 ;;
        *) echo -e "Invalid choice. Exiting..."; exit 1 ;;
    esac
}

install_editing

