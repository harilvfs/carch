#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_cursor() {
    clear
    case "$DISTRO" in
        "Arch")
            install_package "cursor-bin" ""
            ;;
        *)
            echo "Cursor is not available in Fedora/openSUSE repositories."
            echo "Download AppImage from: [Cursor Official Site](https://www.cursor.com/)"
            echo "To Run: chmod +x Cursor.AppImage && ./Cursor.AppImage"
            ;;
    esac
}

install_vscode() {
    clear
    case "$DISTRO" in
        "Arch")
            install_package "visual-studio-code-bin" "com.visualstudio.code"
            ;;
        "Fedora")
            install_package "" "com.visualstudio.code"
            ;;
        "openSUSE")
            sudo zypper ar -cf https://download.opensuse.org/repositories/devel:/tools:/ide:/vscode/openSUSE_Tumbleweed devel_tools_ide_vscode
            install_package "code" "com.visualstudio.code"
            ;;
    esac
}

install_vscodium() {
    clear
    install_package "vscodium-bin" "com.vscodium.codium"
}

install_zed_editor() {
    clear
    case "$DISTRO" in
        "Arch")
            install_package "zed-preview-bin" "dev.zed.Zed"
            ;;
        "Fedora")
            install_package "" "dev.zed.Zed"
            ;;
        "openSUSE")
            sudo zypper addrepo https://download.opensuse.org/repositories/home:hennevogel/openSUSE_Tumbleweed/home:hennevogel.repo
            install_package "zed" "dev.zed.Zed"
            ;;
    esac
}

install_neovim() {
    clear
    install_package "neovim" ""
}

install_vim() {
    clear
    local pkg_name="vim"
    if [ "$DISTRO" == "Fedora" ]; then
        pkg_name="vim-enhanced"
    fi
    install_package "$pkg_name" ""
}

install_code_oss() {
    clear
    install_package "code" "com.visualstudio.code-oss"
}

main() {
    while true; do
        clear
        local options=("Cursor (AI Code Editor)" "Visual Studio Code (VSCODE)" "Vscodium" "ZED Editor" "Neovim" "Vim" "Code-OSS" "Exit")

        show_menu "Text Editor Installation" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Cursor (AI Code Editor)") install_cursor ;;
            "Visual Studio Code (VSCODE)") install_vscode ;;
            "Vscodium") install_vscodium ;;
            "ZED Editor") install_zed_editor ;;
            "Neovim") install_neovim ;;
            "Vim") install_vim ;;
            "Code-OSS") install_code_oss ;;
            "Exit") exit 0 ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
