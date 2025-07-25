#!/usr/bin/env bash

install_filemanagers() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        pkg_manager="sudo pacman -S --noconfirm"
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

        local options=("Nemo" "Thunar" "Dolphin" "LF (Terminal File Manager)" "Ranger" "Nautilus" "Yazi" "Back to Main Menu")

        show_menu "File Manager Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Nemo")
                clear
                $pkg_manager nemo
                version=$(get_version nemo)
                echo "Nemo installed successfully! Version: $version"
                ;;

            "Thunar")
                clear
                $pkg_manager thunar
                version=$(get_version thunar)
                echo "Thunar installed successfully! Version: $version"
                ;;

            "Dolphin")
                clear
                $pkg_manager dolphin
                version=$(get_version dolphin)
                echo "Dolphin installed successfully! Version: $version"
                ;;

            "LF (Terminal File Manager)")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager lf
                elif [[ $distro -eq 1 ]]; then
                    sudo dnf copr enable lsevcik/lf -y
                    $pkg_manager lf
                else
                    $pkg_manager lf
                fi
                version=$(get_version lf)
                echo "LF installed successfully! Version: $version"
                ;;

            "Ranger")
                clear
                $pkg_manager ranger
                version=$(get_version ranger)
                echo "Ranger installed successfully! Version: $version"
                ;;

            "Nautilus")
                clear
                $pkg_manager nautilus
                version=$(get_version nautilus)
                echo "Nautilus installed successfully! Version: $version"
                ;;

            "Yazi")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager yazi
                elif [[ $distro -eq 1 ]]; then
                    sudo dnf copr enable varlad/yazi -y
                    $pkg_manager yazi
                else
                    $pkg_manager yazi
                fi
                version=$(get_version yazi)
                echo "Yazi installed successfully! Version: $version"
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
