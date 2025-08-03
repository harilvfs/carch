#!/usr/bin/env bash

install_crypto_tools() {
    case "$DISTRO" in
        "Arch")
            install_aur_helper
            pkg_manager_aur="$AUR_HELPER -S --noconfirm"
            ;;
        "Fedora")
            pkg_manager="sudo dnf install -y"
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
                        ;;
                    "Fedora")
                        $pkg_manager electrum
                        ;;
                    "openSUSE")
                        $flatpak_cmd org.electrum.electrum
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
