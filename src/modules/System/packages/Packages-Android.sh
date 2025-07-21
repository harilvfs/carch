#!/usr/bin/env bash

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
    elif [[ $distro -eq 2 ]]; then
        pkg_manager="sudo zypper install -y"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${NC}"
        return
    fi

    while true; do
        clear
        local options=(
            "Gvfs-MTP [Displays Android phones via USB]"
            "ADB"
            "JDK (OpenJDK)"
            "Universal Android Debloater (UAD-NG)"
            "Back to Main Menu"
        )

        show_menu "Android Tools Installation" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Gvfs-MTP [Displays Android phones via USB]")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur gvfs-mtp
                    version=$(get_version gvfs-mtp)
                elif [[ $distro -eq 1 ]]; then
                    $pkg_manager gvfs-mtp
                    version=$(get_version gvfs-mtp)
                else
                    $pkg_manager mtp-tools
                    version=$(get_version mtp-tools)
                fi
                echo "Gvfs-MTP installed successfully! Version: $version"
                ;;

            "ADB")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur android-tools
                    version=$(get_version android-tools)
                elif [[ $distro -eq 1 ]]; then
                    $pkg_manager android-tools
                    version=$(get_version android-tools)
                else
                    $pkg_manager android-tools
                    version=$(get_version android-tools)
                fi
                echo "ADB installed successfully! Version: $version"
                ;;

            "JDK (OpenJDK)")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur jdk-openjdk
                    version=$(get_version jdk-openjdk)
                elif [[ $distro -eq 1 ]]; then
                    $pkg_manager java-latest-openjdk.x86_64
                    version=$(get_version java-latest-openjdk)
                else
                    $pkg_manager java-17-openjdk
                    version=$(get_version java-17-openjdk)
                fi
                echo "OpenJDK installed successfully! Version: $version"
                ;;

            "Universal Android Debloater (UAD-NG)")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur uad-ng-bin
                    version=$(get_version uad-ng-bin)
                    echo "UAD installed successfully. Version: $version"
                else
                    echo ":: Downloading UAD binary..."
                    tmp_path="/tmp/uad-ng"
                    bin_url=$(curl -s https://api.github.com/repos/Universal-Debloater-Alliance/universal-android-debloater-next-generation/releases/latest |
                        jq -r '.assets[] | select(.name | test("uad-ng-linux$")) | .browser_download_url')

                    # incase latest binary download fail fallback to v1.1.2
                    if [[ -z "$bin_url" ]]; then
                        echo ":: Failed to get latest, falling back to v1.1.2"
                        bin_url="https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/releases/download/v1.1.2/uad-ng-linux"
                    fi

                    curl -Lo "$tmp_path" "$bin_url" &&
                        chmod +x "$tmp_path" &&
                        sudo mv "$tmp_path" /usr/local/bin/uad-ng

                    if [[ $? -eq 0 ]]; then
                        echo "UAD has been installed to /usr/local/bin/uad-ng"
                        echo "⟹ Run it by typing: uad-ng"
                    else
                        echo "Failed to install UAD."
                    fi
                fi
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
