#!/usr/bin/env bash

install_texteditor() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        install_flatpak
        pkg_manager="sudo dnf install -y"
        flatpak_cmd="flatpak install -y --noninteractive flathub"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${RESET}"
        return
    fi

    while true; do
        clear

        options=("Cursor (AI Code Editor)" "Visual Studio Code (VSCODE)" "Vscodium" "ZED Editor" "Neovim" "Vim" "Code-OSS" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
                "Cursor (AI Code Editor)")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur cursor-bin
                        version=$(get_version cursor-bin)
                    else
                        echo "Cursor is not available in Fedora repositories."
                        echo "Download AppImage from:** [Cursor Official Site](https://www.cursor.com/)"
                        echo "To Run: chmod +x Cursor.AppImage && ./Cursor.AppImage"
                        version="(Manual installation required)"
                    fi
                    echo "Cursor installed successfully! Version: $version"
                    ;;

                "Visual Studio Code (VSCODE)")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur visual-studio-code-bin
                        version=$(get_version visual-studio-code-bin)
                    else
                        $flatpak_cmd com.visualstudio.code
                        version="(Flatpak version installed)"
                    fi
                    echo "VS Code installed successfully! Version: $version"
                    ;;

                "Vscodium")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur vscodium-bin
                        version=$(get_version vscodium-bin)
                    else
                        $flatpak_cmd com.vscodium.codium
                        version="(Flatpak version installed)"
                    fi
                    echo "Vscodium installed successfully! Version: $version"
                    ;;

                "ZED Editor")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur zed-preview-bin
                        version=$(get_version zed-preview-bin)
                    else
                        $flatpak_cmd dev.zed.Zed
                        version="(Flatpak version installed)"
                    fi
                    echo "ZED installed successfully! Version: $version"
                    ;;

                "Neovim")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur neovim
                        version=$(get_version neovim)
                    else
                        $pkg_manager neovim
                        version=$(get_version neovim)
                    fi
                    echo "Neovim installed successfully! Version: $version"
                    ;;

                "Vim")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur vim
                        version=$(get_version vim)
                    else
                        $flatpak_cmd org.vim.Vim
                        version="(Flatpak version installed)"
                    fi
                    echo "Vim installed successfully! Version: $version"
                    ;;

                "Code-OSS")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur code-oss
                        version=$(get_version code-oss)
                    else
                        $flatpak_cmd com.visualstudio.code-oss
                        version="(Flatpak version installed)"
                    fi
                    echo "Code-OSS installed successfully! Version: $version"
                    ;;

            esac
        done

        echo "All selected Text Editors have been installed."
        read -rp "Press Enter to continue..."
    done
}
