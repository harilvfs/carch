#!/usr/bin/env bash

install_editing() {
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
            install_flatpak
            pkg_manager="sudo zypper install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            get_version() { rpm -q "$1"; }
            ;;
        *)
            echo -e "${RED}:: Unsupported system. Exiting.${NC}"
            return
            ;;
    esac

    while true; do
        clear

        local options=("GIMP (Image)" "Kdenlive (Videos)" "Krita" "Blender" "Inkscape" "Audacity" "DaVinci Resolve" "Back to Main Menu")

        show_menu "Editing Tools Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "GIMP (Image)")
                clear
                $pkg_manager gimp
                version=$(get_version gimp)
                echo "GIMP installed successfully! Version: $version"
                ;;

            "Kdenlive (Videos)")
                clear
                $pkg_manager kdenlive
                version=$(get_version kdenlive)
                echo "Kdenlive installed successfully! Version: $version"
                ;;

            "Krita")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur krita
                        version=$(get_version krita)
                        ;;
                    *)
                        $pkg_manager krita
                        version=$(get_version krita)
                        ;;
                esac
                echo "Krita installed successfully! Version: $version"
                ;;

            "Blender")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur blender
                        version=$(get_version blender)
                        ;;
                    "Fedora")
                        $pkg_manager blender
                        version=$(get_version blender)
                        ;;
                    "openSUSE")
                        $flatpak_cmd org.blender.Blender
                        version="(Flatpak version installed)"
                        ;;
                esac
                echo "Blender installed successfully! Version: $version"
                ;;

            "Inkscape")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur inkscape
                        version=$(get_version inkscape)
                        ;;
                    "Fedora")
                        $pkg_manager inkscape
                        version=$(get_version inkscape)
                        ;;
                    "openSUSE")
                        $flatpak_cmd org.inkscape.Inkscape
                        version="(Flatpak version installed)"
                        ;;
                esac
                echo "Inkscape installed successfully! Version: $version"
                ;;

            "Audacity")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur audacity
                        version=$(get_version audacity)
                        ;;
                    *)
                        $pkg_manager audacity
                        version=$(get_version audacity)
                        ;;
                esac
                echo "Audacity installed successfully! Version: $version"
                ;;

            "DaVinci Resolve")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur davinci-resolve
                        version=$(get_version davinci-resolve)
                        ;;
                    *)
                        echo "DaVinci Resolve is not directly available in official repositories."
                        echo "Download from: [Blackmagic Design Website](https://www.blackmagicdesign.com/products/davinciresolve/)"
                        version="(Manual installation required)"
                        ;;
                esac
                echo "DaVinci Resolve installation completed! Version: $version"
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
