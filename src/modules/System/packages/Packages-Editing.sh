#!/usr/bin/env bash

install_editing() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        pkg_manager="sudo pacman -S --noconfirm"
    elif [[ $distro -eq 1 ]]; then
        pkg_manager="sudo dnf install -y"
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
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager gimp
                        version=$(pacman -Qi gimp | grep Version | awk '{print $3}')
                    else
                        $pkg_manager gimp
                        version=$(rpm -q gimp)
                    fi
                    echo "GIMP installed successfully! Version: $version"
                    ;;

                "Kdenlive (Videos)")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager kdenlive
                        version=$(pacman -Qi kdenlive | grep Version | awk '{print $3}')
                        echo "Kdenlive installed successfully! Version: $version"
                    else
                        $pkg_manager kdenlive
                        version=$(rpm -q kdenlive)
                        echo "Kdenlive installed successfully! Version: $version"
                    fi
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
                    else
                        $pkg_manager blender
                        version=$(get_version blender)
                    fi
                    echo "Blender installed successfully! Version: $version"
                    ;;

                "Inkscape")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur inkscape
                        version=$(get_version inkscape)
                    else
                        $pkg_manager inkscape
                        version=$(get_version inkscape)
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
                        echo "DaVinci Resolve is not directly available in Fedora repositories."
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
