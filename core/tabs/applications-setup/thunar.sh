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

install_thunarpreview_app() {
    install_paru
    case $1 in
        "Tumbler")
            gum spin --spinner dot --title "Installing Tumbler..." -- paru -S tumbler --noconfirm &>/dev/null
            version=$(paru -Qi tumbler | grep Version | awk '{print $3}')
            gum format "🎉 **Tumbler installed successfully! Version: $version**"
            ;;
        *)
            gum format "❌ **Invalid choice. Please try again.**"
            ;;
    esac
}

install_thunarpreview() {
    echo -e "Select an application to install for Thunar preview:"
    echo -e "1) Tumbler"
    echo -e "2) Exit"

    read -p "Enter your choice (1-2): " choice
    case $choice in
        1) install_thunarpreview_app "Tumbler" ;;
        2) echo "Exiting..."; exit 0 ;;
        *) gum format "❌ **Invalid choice. Please try again.**" ;;
    esac
}

install_thunarpreview

