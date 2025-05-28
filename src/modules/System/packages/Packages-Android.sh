install_android() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        pkg_manager="sudo dnf install -y"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${RESET}"
        return
    fi

    while true; do
        clear

        options=("Gvfs-MTP [Displays Android phones via USB]" "ADB" "Back to Main Menu")
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
                "Gvfs-MTP [Displays Android phones via USB]")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur gvfs-mtp
                        version=$(get_version gvfs-mtp)
                    else
                        $pkg_manager gvfs-mtp
                        version=$(get_version gvfs-mtp)
                    fi
                    echo "Gvfs-MTP installed successfully! Version: $version"
                    ;;

                "ADB")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur android-tools
                        version=$(get_version android-tools)
                    else
                        $pkg_manager android-tools
                        version=$(get_version android-tools)
                    fi
                    echo "ADB installed successfully! Version: $version"
                    ;;
            esac
        done

        echo "All selected Android tools have been installed."
        read -rp "Press Enter to continue..."
    done
}
