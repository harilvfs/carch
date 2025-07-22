#!/usr/bin/env bash

install_crypto_tools() {
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
        install_flatpak
        pkg_manager="sudo zypper install -y"
        flatpak_cmd="flatpak install -y --noninteractive flathub"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${NC}"
        return
    fi

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
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur electrum
                    version=$(get_version electrum)
                    echo "Electrum installed successfully! Version: $version"
                elif [[ $distro -eq 1 ]]; then
                    $pkg_manager electrum
                    version=$(get_version electrum)
                    echo "Electrum installed successfully! Version: $version"
                else
                    $flatpak_cmd org.electrum.electrum
                    version="(Flatpak version installed)"
                    echo "Electrum installed successfully! Version: $version"
                fi
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
