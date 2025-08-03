#!/usr/bin/env bash

install_texteditor() {
    case "$DISTRO" in
        "Arch")
            install_aur_helper
            pkg_manager_aur="$AUR_HELPER -S --noconfirm"
            pkg_manager="sudo pacman -S --noconfirm"
            ;;
        "Fedora")
            install_flatpak
            pkg_manager="sudo dnf install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            ;;
        "openSUSE")
            install_flatpak
            pkg_manager="sudo zypper install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            ;;
        *)
            exit 1
            ;;
    esac

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
                        $pkg_manager_aur cursor-bin
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
                        $pkg_manager_aur visual-studio-code-bin
                        ;;
                    "Fedora")
                        $flatpak_cmd com.visualstudio.code
                        ;;
                    "openSUSE")
                        sudo zypper ar -cf https://download.opensuse.org/repositories/devel:/tools:/ide:/vscode/openSUSE_Tumbleweed devel_tools_ide_vscode
                        sudo zypper install -y code
                        ;;
                esac
                ;;

            "Vscodium")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur vscodium-bin
                        ;;
                    *)
                        $flatpak_cmd com.vscodium.codium
                        ;;
                esac
                ;;

            "ZED Editor")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur zed-preview-bin
                        ;;
                    "Fedora")
                        $flatpak_cmd dev.zed.Zed
                        ;;
                    "openSUSE")
                        sudo zypper addrepo https://download.opensuse.org/repositories/home:hennevogel/openSUSE_Tumbleweed/home:hennevogel.repo
                        sudo zypper install -y zed
                        ;;
                esac
                ;;

            "Neovim")
                clear
                $pkg_manager neovim
                ;;

            "Vim")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE")
                        $pkg_manager vim
                        ;;
                    "Fedora")
                        $pkg_manager vim-enhanced
                        ;;
                esac
                ;;

            "Code-OSS")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager code
                        ;;
                    *)
                        $flatpak_cmd com.visualstudio.code-oss
                        ;;
                esac
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
