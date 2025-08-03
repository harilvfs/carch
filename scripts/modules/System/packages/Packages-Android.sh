#!/usr/bin/env bash

install_android() {
    case "$DISTRO" in
        "Arch")
            install_aur_helper
            pkg_manager_aur="$AUR_HELPER -S --noconfirm"
            ;;
        "Fedora")
            pkg_manager="sudo dnf install -y"
            ;;
        "openSUSE")
            pkg_manager="sudo zypper install -y"
            ;;
        *)
            exit 1
            ;;
    esac

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
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur gvfs-mtp
                        ;;
                    "Fedora")
                        $pkg_manager gvfs-mtp
                        ;;
                    "openSUSE")
                        $pkg_manager mtp-tools
                        ;;
                esac
                ;;

            "ADB")
                clear
                case "$DISTRO" in
                    "Arch" | "Fedora" | "openSUSE")
                        $pkg_manager_aur android-tools
                        ;;
                esac
                ;;

            "JDK (OpenJDK)")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur jdk-openjdk
                        ;;
                    "Fedora")
                        $pkg_manager java-latest-openjdk.x86_64
                        ;;
                    "openSUSE")
                        $pkg_manager java-17-openjdk
                        ;;
                esac
                ;;

            "Universal Android Debloater (UAD-NG)")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur uad-ng-bin
                        ;;
                    "Fedora" | "openSUSE")
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
