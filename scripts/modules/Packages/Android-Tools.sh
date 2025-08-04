#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_gvfs_mtp() {
    clear
    local pkg_name=""
    case "$DISTRO" in
        "Arch" | "Fedora")
            pkg_name="gvfs-mtp"
            ;;
        "openSUSE")
            pkg_name="mtp-tools"
            ;;
    esac
    install_package "$pkg_name" ""
}

install_adb() {
    clear
    install_package "android-tools" ""
}

install_jdk() {
    clear
    local pkg_name=""
    case "$DISTRO" in
        "Arch")
            pkg_name="jdk-openjdk"
            ;;
        "Fedora")
            pkg_name="java-latest-openjdk.x86_64"
            ;;
        "openSUSE")
            pkg_name="java-17-openjdk"
            ;;
    esac
    install_package "$pkg_name" ""
}

install_uad() {
    clear
    case "$DISTRO" in
        "Arch")
            install_package "uad-ng-bin" ""
            ;;
        "Fedora" | "openSUSE")
            print_message "$YELLOW" "Downloading UAD binary..."
            local tmp_path="/tmp/uad-ng"
            local bin_url
            bin_url=$(curl -s https://api.github.com/repos/Universal-Debloater-Alliance/universal-android-debloater-next-generation/releases/latest |
                jq -r '.assets[] | select(.name | test("uad-ng-linux$")) | .browser_download_url')

            # incase latest binary download fail fallback to v1.1.2
            if [[ -z "$bin_url" ]]; then
                print_message "$YELLOW" "Failed to get latest, falling back to v1.1.2"
                bin_url="https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/releases/download/v1.1.2/uad-ng-linux"
            fi

            curl -Lo "$tmp_path" "$bin_url" &&
                chmod +x "$tmp_path" &&
                sudo mv "$tmp_path" /usr/local/bin/uad-ng

            if [[ $? -eq 0 ]]; then
                print_message "$GREEN" "UAD has been installed to /usr/local/bin/uad-ng"
                print_message "$GREEN" "⟹ Run it by typing: uad-ng"
            else
                print_message "$RED" "Failed to install UAD."
            fi
            ;;
    esac
}

main() {
    while true; do
        clear
        local options=(
            "Gvfs-MTP [Displays Android phones via USB]"
            "ADB"
            "JDK (OpenJDK)"
            "Universal Android Debloater (UAD-NG)"
            "Exit"
        )

        show_menu "Android Tools Installation" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Gvfs-MTP [Displays Android phones via USB]")
                install_gvfs_mtp
                ;;
            "ADB")
                install_adb
                ;;
            "JDK (OpenJDK)")
                install_jdk
                ;;
            "Universal Android Debloater (UAD-NG)")
                install_uad
                ;;
            "Exit")
                exit 0
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
