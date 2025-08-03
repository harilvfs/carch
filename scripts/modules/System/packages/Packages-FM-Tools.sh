#!/usr/bin/env bash

install_fm_tools() {
    case "$DISTRO" in
        "Arch")
            pkg_manager="sudo pacman -S --noconfirm"
            get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
            ;;
        "Fedora")
            pkg_manager="sudo dnf install -y"
            get_version() { rpm -q "$1"; }
            ;;
        "openSUSE")
            pkg_manager="sudo zypper install -y"
            get_version() { rpm -q "$1"; }
            ;;
        *)
            echo -e "${RED}:: Unsupported distribution. Exiting.${NC}"
            return
            ;;
    esac

    while true; do
        clear

        local options=("Tumbler [Thumbnail Viewer]" "Trash-Cli" "Back to Main Menu")

        show_menu "FM Tools Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Tumbler [Thumbnail Viewer]")
                clear
                $pkg_manager tumbler
                version=$(get_version tumbler)
                echo "Tumbler installed successfully! Version: $version"
                ;;

            "Trash-Cli")
                clear
                $pkg_manager trash-cli
                version=$(get_version trash-cli)
                echo "Trash-Cli installed successfully! Version: $version"
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
