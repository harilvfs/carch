#!/bin/bash

install_filemanager() {
    case $1 in
        "Nemo")
            gum spin --spinner dot --title "Installing Nemo..." -- sudo pacman -S nemo --noconfirm &>/dev/null
            version=$(pacman -Qi nemo | grep Version | awk '{print $3}')
            gum format "🎉 **Nemo installed successfully! Version: $version**"
            ;;
        "Thunar")
            gum spin --spinner dot --title "Installing Thunar..." -- sudo pacman -S thunar --noconfirm &>/dev/null
            version=$(pacman -Qi thunar | grep Version | awk '{print $3}')
            gum format "🎉 **Thunar installed successfully! Version: $version**"
            ;;
        "Dolphin")
            gum spin --spinner dot --title "Installing Dolphin..." -- sudo pacman -S dolphin --noconfirm &>/dev/null
            version=$(pacman -Qi dolphin | grep Version | awk '{print $3}')
            gum format "🎉 **Dolphin installed successfully! Version: $version**"
            ;;
        "LF (Terminal File Manager)")
            gum spin --spinner dot --title "Installing LF..." -- sudo pacman -S lf --noconfirm &>/dev/null
            version=$(pacman -Qi lf | grep Version | awk '{print $3}')
            gum format "🎉 **LF installed successfully! Version: $version**"
            ;;
        "Ranger")
            gum spin --spinner dot --title "Installing Ranger..." -- sudo pacman -S ranger --noconfirm &>/dev/null
            version=$(pacman -Qi ranger | grep Version | awk '{print $3}')
            gum format "🎉 **Ranger installed successfully! Version: $version**"
            ;;
        "Nautilus")
            gum spin --spinner dot --title "Installing Nautilus..." -- sudo pacman -S nautilus --noconfirm &>/dev/null
            version=$(pacman -Qi nautilus | grep Version | awk '{print $3}')
            gum format "🎉 **Nautilus installed successfully! Version: $version**"
            ;;
        "Yazi")
            gum spin --spinner dot --title "Installing Yazi..." -- sudo pacman -S yazi --noconfirm &>/dev/null
            version=$(pacman -Qi yazi | grep Version | awk '{print $3}')
            gum format "🎉 **Yazi installed successfully! Version: $version**"
            ;;
        *)
            gum format "❌ **Invalid choice. Please try again.**"
            ;;
    esac
}

install_filemanagers() {
    echo -e "Select a file manager to install:"
    echo -e "1) Nemo"
    echo -e "2) Thunar"
    echo -e "3) Dolphin"
    echo -e "4) LF (Terminal File Manager)"
    echo -e "5) Ranger"
    echo -e "6) Nautilus"
    echo -e "7) Yazi"
    echo -e "8) Exit"

    read -p "Enter your choice (1-8): " choice
    case $choice in
        1) install_filemanager "Nemo" ;;
        2) install_filemanager "Thunar" ;;
        3) install_filemanager "Dolphin" ;;
        4) install_filemanager "LF (Terminal File Manager)" ;;
        5) install_filemanager "Ranger" ;;
        6) install_filemanager "Nautilus" ;;
        7) install_filemanager "Yazi" ;;
        8) echo "Exiting..."; exit 0 ;;
        *) gum format "❌ **Invalid choice. Please try again.**" ;;
    esac
}

install_filemanagers

