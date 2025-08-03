#!/usr/bin/env bash

install_editing() {
    case "$DISTRO" in
        "Arch")
            pkg_manager="sudo pacman -S --noconfirm"
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

        local options=("GIMP (Image)" "Kdenlive (Videos)" "Krita" "Blender" "Inkscape" "Audacity" "DaVinci Resolve" "Back to Main Menu")

        show_menu "Editing Tools Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "GIMP (Image)")
                clear
                $pkg_manager gimp
                ;;

            "Kdenlive (Videos)")
                clear
                $pkg_manager kdenlive
                ;;

            "Krita")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur krita
                        ;;
                    *)
                        $pkg_manager krita
                        ;;
                esac
                ;;

            "Blender")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur blender
                        ;;
                    "Fedora")
                        $pkg_manager blender
                        ;;
                    "openSUSE")
                        $flatpak_cmd org.blender.Blender
                        ;;
                esac
                ;;

            "Inkscape")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur inkscape
                        ;;
                    "Fedora")
                        $pkg_manager inkscape
                        ;;
                    "openSUSE")
                        $flatpak_cmd org.inkscape.Inkscape
                        ;;
                esac
                ;;

            "Audacity")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur audacity
                        ;;
                    *)
                        $pkg_manager audacity
                        ;;
                esac
                ;;

            "DaVinci Resolve")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur davinci-resolve
                        ;;
                    *)
                        echo "DaVinci Resolve is not directly available in official repositories."
                        echo "Download from: [Blackmagic Design Website](https://www.blackmagicdesign.com/products/davinciresolve/)"
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
