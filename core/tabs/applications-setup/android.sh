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

install_andriod_app() {
    install_paru
    case $1 in
        "Gvfs-MTP [Displays Android phones via USB]")
            gum spin --spinner dot --title "Installing Gvfs-MTP..." -- paru -S gvfs-mtp --noconfirm &>/dev/null
            version=$(paru -Qi gvfs-mtp | grep Version | awk '{print $3}')
            gum format "🎉 **Gvfs-MTP installed successfully! Version: $version**"
            ;;
        "ADB")
            gum spin --spinner dot --title "Installing ADB..." -- paru -S adb --noconfirm &>/dev/null
            version=$(paru -Qi adb | grep Version | awk '{print $3}')
            gum format "🎉 **ADB installed successfully! Version: $version**"
            ;;
        *)
            gum format "❌ **Invalid choice. Please try again.**"
            ;;
    esac
}

# Main function to select and install Android-related applications
install_andriod() {
    echo -e "Select an Android-related application to install:"
    echo -e "1) Gvfs-MTP [Displays Android phones via USB]"
    echo -e "2) ADB"
    echo -e "3) Exit"

    read -p "Enter your choice (1-3): " choice
    case $choice in
        1) install_andriod_app "Gvfs-MTP [Displays Android phones via USB]" ;;
        2) install_andriod_app "ADB" ;;
        3) echo "Exiting..."; exit 0 ;;
        *) gum format "❌ **Invalid choice. Please try again.**" ;;
    esac
}

install_andriod

