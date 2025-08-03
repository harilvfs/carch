#!/usr/bin/env bash

install_texteditor() {
    case "$DISTRO" in
        "Arch")
            install_aur_helper
            pkg_manager_aur="$AUR_HELPER -S --noconfirm"
            pkg_manager="sudo pacman -S --noconfirm"
            get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
            ;;
        "Fedora")
            install_flatpak
            pkg_manager="sudo dnf install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            get_version() { rpm -q "$1"; }
            ;;
        "openSUSE")
            install_flatpak
            pkg_manager="sudo zypper install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            get_version() { rpm -q "$1"; }
            ;;
        *)
            echo -e "${RED}:: Unsupported distribution. Exiting.${NC}"
            return
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
                        version=$(get_version cursor-bin)
                        ;;
                    *)
                        echo "Cursor is not available in Fedora/openSUSE repositories."
                        echo "Download AppImage from: [Cursor Official Site](https://www.cursor.com/)"
                        echo "To Run: chmod +x Cursor.AppImage && ./Cursor.AppImage"
                        version="(Manual installation required)"
                        ;;
                esac
                echo "Cursor installed successfully! Version: $version"
                ;;

            "Visual Studio Code (VSCODE)")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur visual-studio-code-bin
                        version=$(get_version visual-studio-code-bin)
                        ;;
                    "Fedora")
                        $flatpak_cmd com.visualstudio.code
                        version="(Flatpak version installed)"
                        ;;
                    "openSUSE")
                        sudo zypper ar -cf https://download.opensuse.org/repositories/devel:/tools:/ide:/vscode/openSUSE_Tumbleweed devel_tools_ide_vscode
                        sudo zypper install -y code
                        version=$(get_version code)
                        ;;
                esac
                echo "VS Code installed successfully! Version: $version"
                ;;

            "Vscodium")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur vscodium-bin
                        version=$(get_version vscodium-bin)
                        ;;
                    *)
                        $flatpak_cmd com.vscodium.codium
                        version="(Flatpak version installed)"
                        ;;
                esac
                echo "Vscodium installed successfully! Version: $version"
                ;;

            "ZED Editor")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur zed-preview-bin
                        version=$(get_version zed-preview-bin)
                        ;;
                    "Fedora")
                        $flatpak_cmd dev.zed.Zed
                        version="(Flatpak version installed)"
                        ;;
                    "openSUSE")
                        sudo zypper addrepo https://download.opensuse.org/repositories/home:hennevogel/openSUSE_Tumbleweed/home:hennevogel.repo
                        sudo zypper install -y zed
                        version=$(get_version zed)
                        ;;
                esac
                echo "ZED installed successfully! Version: $version"
                ;;

            "Neovim")
                clear
                $pkg_manager neovim
                version=$(get_version neovim)
                echo "Neovim installed successfully! Version: $version"
                ;;

            "Vim")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE")
                        $pkg_manager vim
                        version=$(get_version vim)
                        ;;
                    "Fedora")
                        $pkg_manager vim-enhanced
                        version=$(get_version vim-enhanced)
                        ;;
                esac
                echo "Vim installed successfully! Version: $version"
                ;;

            "Code-OSS")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager code
                        version=$(get_version code)
                        ;;
                    *)
                        $flatpak_cmd com.visualstudio.code-oss
                        version="(Flatpak version installed)"
                        ;;
                esac
                echo "Code-OSS installed successfully! Version: $version"
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
