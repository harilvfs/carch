#!/usr/bin/env bash

install_crypto_tools() {
    case "$DISTRO" in
        "Arch")
            install_aur_helper
            pkg_manager_aur="$AUR_HELPER -S --noconfirm"
            get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
            ;;
        "Fedora")
            pkg_manager="sudo dnf install -y"
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

        local options=("Electrum" "Back to Main Menu")

        show_menu "Crypto Tools Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Electrum")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur electrum
                        version=$(get_version electrum)
                        echo "Electrum installed successfully! Version: $version"
                        ;;
                    "Fedora")
                        $pkg_manager electrum
                        version=$(get_version electrum)
                        echo "Electrum installed successfully! Version: $version"
                        ;;
                    "openSUSE")
                        $flatpak_cmd org.electrum.electrum
                        version="(Flatpak version installed)"
                        echo "Electrum installed successfully! Version: $version"
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
