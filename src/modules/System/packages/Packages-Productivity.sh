#!/usr/bin/env bash

install_productivity() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
        pkg_manager_pacman="sudo pacman -S --noconfirm"
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

        options=("LibreOffice" "OnlyOffice" "Obsidian" "Joplin" "Calibre" "Back to Main Menu")
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
                "LibreOffice")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman libreoffice-fresh
                        version=$(get_version libreoffice-fresh)
                    else
                        $pkg_manager libreoffice
                        version=$(get_version libreoffice)
                    fi
                    echo "LibreOffice installed successfully! Version: $version"
                    ;;

                "OnlyOffice")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur onlyoffice-bin
                        version=$(get_version onlyoffice-bin)
                    else
                        $flatpak_cmd org.onlyoffice.desktopeditors
                        version="(Flatpak version installed)"
                    fi
                    echo "OnlyOffice installed successfully! Version: $version"
                    ;;

                "Obsidian")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur obsidian
                        version=$(get_version obsidian)
                    else
                        $flatpak_cmd md.obsidian.Obsidian
                        version="(Flatpak version installed)"
                    fi
                    echo "Obsidian installed successfully! Version: $version"
                    ;;

                "Joplin")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur joplin-desktop
                        version=$(get_version joplin-desktop)
                    else
                        $flatpak_cmd net.cozic.joplin_desktop
                        version="(Flatpak version installed)"
                    fi
                    echo "Joplin installed successfully! Version: $version"
                    ;;

                "Calibre")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman calibre
                        version=$(get_version calibre)
                    else
                        $pkg_manager calibre
                        version=$(get_version calibre)
                    fi
                    echo "Calibre installed successfully! Version: $version"
                    ;;

            esac
        done

        echo "All selected Productivity Apps have been installed."
        read -rp "Press Enter to continue..."
    done
}
