#!/usr/bin/env bash

install_texteditor() {
    while true; do
        clear
        local options=("Cursor (AI Code Editor)" "Visual Studio Code (VSCODE)" "Vscodium" "ZED Editor" "Neovim" "Vim" "Code-OSS" "Back to Main Menu")

        show_menu "Text Editor Installation" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Cursor (AI Code Editor)")
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
                ;;

            "Visual Studio Code (VSCODE)")
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
                ;;

            "Vscodium")
                clear
                install_package "vscodium-bin" "com.vscodium.codium"
                ;;

            "ZED Editor")
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
                ;;

            "Neovim")
                clear
                install_package "neovim" ""
                ;;

            "Vim")
                clear
                local pkg_name="vim"
                if [ "$DISTRO" == "Fedora" ]; then
                    pkg_name="vim-enhanced"
                fi
                install_package "$pkg_name" ""
                ;;

            "Code-OSS")
                clear
                install_package "code" "com.visualstudio.code-oss"
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
