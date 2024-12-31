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

install_texteditor_app() {
    install_paru
    case $1 in
        "Cursor (AI Code Editor)")
            gum spin --spinner dot --title "Installing Cursor (AI Code Editor)..." -- paru -S cursor-bin --noconfirm &>/dev/null
            version=$(paru -Qi cursor-bin | grep Version | awk '{print $3}')
            gum format "🎉 **Cursor installed successfully! Version: $version**"
            ;;
        "Visual Studio Code (VSCODE)")
            gum spin --spinner dot --title "Installing Visual Studio Code..." -- paru -S visual-studio-code-bin --noconfirm &>/dev/null
            version=$(paru -Qi visual-studio-code-bin | grep Version | awk '{print $3}')
            gum format "🎉 **Visual Studio Code installed successfully! Version: $version**"
            ;;
        "Vscodium")
            gum spin --spinner dot --title "Installing Vscodium..." -- paru -S vscodium-bin --noconfirm &>/dev/null
            version=$(paru -Qi vscodium-bin | grep Version | awk '{print $3}')
            gum format "🎉 **Vscodium installed successfully! Version: $version**"
            ;;
        "ZED Editor")
            gum spin --spinner dot --title "Installing ZED Editor..." -- paru -S zed-preview-bin --noconfirm &>/dev/null
            version=$(paru -Qi zed-preview-bin | grep Version | awk '{print $3}')
            gum format "🎉 **ZED Editor installed successfully! Version: $version**"
            ;;
        "Neovim")
            gum spin --spinner dot --title "Installing Neovim..." -- paru -S neovim --noconfirm &>/dev/null
            version=$(paru -Qi neovim | grep Version | awk '{print $3}')
            gum format "🎉 **Neovim installed successfully! Version: $version**"
            ;;
        "Vim")
            gum spin --spinner dot --title "Installing Vim..." -- paru -S vim --noconfirm &>/dev/null
            version=$(paru -Qi vim | grep Version | awk '{print $3}')
            gum format "🎉 **Vim installed successfully! Version: $version**"
            ;;
        "Code-OSS")
            gum spin --spinner dot --title "Installing Code-OSS..." -- paru -S coder-oss --noconfirm &>/dev/null
            version=$(paru -Qi coder-oss | grep Version | awk '{print $3}')
            gum format "🎉 **Code-OSS installed successfully! Version: $version**"
            ;;
        *)
            gum format "❌ **Invalid choice. Please try again.**"
            ;;
    esac
}

install_texteditor() {
    echo -e "Select a text editor to install:"
    echo -e "1) Cursor (AI Code Editor)"
    echo -e "2) Visual Studio Code (VSCODE)"
    echo -e "3) Vscodium"
    echo -e "4) ZED Editor"
    echo -e "5) Neovim"
    echo -e "6) Vim"
    echo -e "7) Code-OSS"
    echo -e "8) Exit"

    read -p "Enter your choice (1-8): " choice
    case $choice in
        1) install_texteditor_app "Cursor (AI Code Editor)" ;;
        2) install_texteditor_app "Visual Studio Code (VSCODE)" ;;
        3) install_texteditor_app "Vscodium" ;;
        4) install_texteditor_app "ZED Editor" ;;
        5) install_texteditor_app "Neovim" ;;
        6) install_texteditor_app "Vim" ;;
        7) install_texteditor_app "Code-OSS" ;;
        8) echo "Exiting..."; exit 0 ;;
        *) gum format "❌ **Invalid choice. Please try again.**" ;;
    esac
}

install_texteditor

