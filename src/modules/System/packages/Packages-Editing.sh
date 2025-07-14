#!/usr/bin/env bash

install_editing() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        pkg_manager="sudo pacman -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        pkg_manager="sudo dnf install -y"
        get_version() { rpm -q "$1"; }
    elif [[ $distro -eq 2 ]]; then
        install_flatpak
        pkg_manager="sudo zypper install -y"
        flatpak_cmd="flatpak install -y --noninteractive flathub"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported system. Exiting.${NC}"
        return
    fi

    while true; do
        clear

        options=("GIMP (Image)" "Kdenlive (Videos)" "Krita" "Blender" "Inkscape" "Audacity" "DaVinci Resolve" "Back to Main Menu")
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
                "GIMP (Image)")
                    clear
                    $pkg_manager gimp
                    version=$(get_version gimp)
                    echo "GIMP installed successfully! Version: $version"
                    ;;

                "Kdenlive (Videos)")
                    clear
                    $pkg_manager kdenlive
                    version=$(get_version kdenlive)
                    echo "Kdenlive installed successfully! Version: $version"
                    ;;

                "Krita")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur krita
                        version=$(get_version krita)
                    else
                        $pkg_manager krita
                        version=$(get_version krita)
                    fi
                    echo "Krita installed successfully! Version: $version"
                    ;;

                "Blender")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur blender
                        version=$(get_version blender)
                    elif [[ $distro -eq 1 ]]; then
                        $pkg_manager blender
                        version=$(get_version blender)
                    else
                        $flatpak_cmd org.blender.Blender
                        version="(Flatpak version installed)"
                    fi
                    echo "Blender installed successfully! Version: $version"
                    ;;

                "Inkscape")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur inkscape
                        version=$(get_version inkscape)
                    elif [[ $distro -eq 1 ]]; then
                        $pkg_manager inkscape
                        version=$(get_version inkscape)
                    else
                        $flatpak_cmd org.inkscape.Inkscape
                        version="(Flatpak version installed)"
                    fi
                    echo "Inkscape installed successfully! Version: $version"
                    ;;

                "Audacity")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur audacity
                        version=$(get_version audacity)
                    else
                        $pkg_manager audacity
                        version=$(get_version audacity)
                    fi
                    echo "Audacity installed successfully! Version: $version"
                    ;;

                "DaVinci Resolve")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur davinci-resolve
                        version=$(get_version davinci-resolve)
                    else
                        echo "DaVinci Resolve is not directly available in official repositories."
                        echo "Download from: [Blackmagic Design Website](https://www.blackmagicdesign.com/products/davinciresolve/)"
                        version="(Manual installation required)"
                    fi
                    echo "DaVinci Resolve installation completed! Version: $version"
                    ;;

            esac
        done

        echo "All selected Editing tools have been installed."
        read -rp "Press Enter to continue..."
    done
}
