#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_gimp() {
    clear
    install_package "gimp" "org.gimp.GIMP"
}

install_kdenlive() {
    clear
    install_package "kdenlive" "org.kde.kdenlive"
}

install_krita() {
    clear
    install_package "krita" "org.kde.krita"
}

install_blender() {
    clear
    install_package "blender" "org.blender.Blender"
}

install_inkscape() {
    clear
    install_package "inkscape" "org.inkscape.Inkscape"
}

install_audacity() {
    clear
    install_package "audacity" "org.audacityteam.Audacity"
}

install_davinci_resolve() {
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
}

main() {
    while true; do
        clear
        local options=("GIMP (Image)" "Kdenlive (Videos)" "Krita" "Blender" "Inkscape" "Audacity" "DaVinci Resolve" "Exit")

        show_menu "Editing Tools Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "GIMP (Image)") install_gimp ;;
            "Kdenlive (Videos)") install_kdenlive ;;
            "Krita") install_krita ;;
            "Blender") install_blender ;;
            "Inkscape") install_inkscape ;;
            "Audacity") install_audacity ;;
            "DaVinci Resolve") install_davinci_resolve ;;
            "Exit") exit 0 ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
