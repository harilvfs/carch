#!/usr/bin/env bash

install_editing() {
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
                install_package "gimp" "org.gimp.GIMP"
                ;;

            "Kdenlive (Videos)")
                clear
                install_package "kdenlive" "org.kde.kdenlive"
                ;;

            "Krita")
                clear
                install_package "krita" "org.kde.krita"
                ;;

            "Blender")
                clear
                install_package "blender" "org.blender.Blender"
                ;;

            "Inkscape")
                clear
                install_package "inkscape" "org.inkscape.Inkscape"
                ;;

            "Audacity")
                clear
                install_package "audacity" "org.audacityteam.Audacity"
                ;;

            "DaVinci Resolve")
                clear
                case "$DISTRO" in
                    "Arch")
                        install_package "davinci-resolve" ""
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
