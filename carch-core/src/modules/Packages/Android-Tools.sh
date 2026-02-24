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

install_apkstudio() {
    clear
    print_message "$YELLOW" "Fetching latest APK Studio release..."

    local appimage_dir="$HOME/Applications"
    mkdir -p "$appimage_dir"

    local api_url="https://api.github.com/repos/vaibhavpandeyvpz/apkstudio/releases/latest"
    local appimage_url
    appimage_url=$(curl -s $api_url | jq -r '.assets[] | select(.name | endswith(".AppImage")) | .browser_download_url' | head -1)

    if [[ -z "$appimage_url" ]]; then
        print_message "$RED" "Failed to fetch latest release URL"
        print_message "$YELLOW" "Falling back to hardcoded URL..."
        appimage_url="https://github.com/vaibhavpandeyvpz/apkstudio/releases/latest/download/ApkStudio-v6.3.0-x86_64.AppImage"
    fi

    local filename=$(basename "$appimage_url")
    local appimage_path="$appimage_dir/$filename"

    print_message "$YELLOW" "Downloading $filename..."

    curl -L "$appimage_url" -o "$appimage_path"

    if [[ $? -eq 0 ]]; then
        chmod +x "$appimage_path"

        if [[ -d "/usr/local/bin" && -w "/usr/local/bin" ]]; then
            sudo ln -sf "$appimage_path" /usr/local/bin/apkstudio 2> /dev/null
        else
            mkdir -p "$HOME/.local/bin"
            ln -sf "$appimage_path" "$HOME/.local/bin/apkstudio" 2> /dev/null

            if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
                # for bash
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
                # for zsh
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc" 2> /dev/null
                # for fish
                mkdir -p "$HOME/.config/fish"
                echo 'set -gx PATH $HOME/.local/bin $PATH' >> "$HOME/.config/fish/config.fish" 2> /dev/null
            fi
        fi

        print_message "$GREEN" "APK Studio downloaded successfully"
        print_message "$GREEN" "Location: $appimage_path"

        create_apkstudio_desktop_entry "$appimage_path"

        print_message "$CYAN" "Run APK Studio by typing: apkstudio"
        print_message "$CYAN" "Or run directly: $appimage_path"
        print_message "$CYAN" "If you encounter issues, check: https://github.com/vaibhavpandeyvpz/apkstudio"

    else
        print_message "$RED" "Failed to download APK Studio AppImage"
        print_message "$YELLOW" "Download manually from: https://github.com/vaibhavpandeyvpz/apkstudio/releases"
    fi
}

create_apkstudio_desktop_entry() {
    local appimage_path="$1"
    local desktop_entry="$HOME/.local/share/applications/apkstudio.desktop"

    mkdir -p "$HOME/.local/share/applications"
    mkdir -p "$HOME/.local/share/icons"

    local icon_path="$HOME/.local/share/icons/apkstudio.png"
    curl -s "https://raw.githubusercontent.com/vaibhavpandeyvpz/apkstudio/refs/heads/master/resources/icon.png" -o "$icon_path"

    cat > "$desktop_entry" << EOF
[Desktop Entry]
Name=APK Studio
Comment=IDE for reverse-engineering Android applications
Exec=$appimage_path
Icon=$icon_path
Terminal=false
Type=Application
Categories=Development;IDE;Android;
MimeType=application/vnd.android.package-archive;
EOF

    chmod +x "$desktop_entry"
    print_message "$GREEN" "Desktop entry created"
}

main() {
    while true; do
        clear
        local options=(
            "Gvfs-MTP [Displays Android phones via USB]"
            "ADB"
            "JDK (OpenJDK)"
            "Universal Android Debloater (UAD-NG)"
            "APK Studio [Android Reverse Engineering IDE]"
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
            "APK Studio [Android Reverse Engineering IDE]")
                install_apkstudio
                ;;
            "Exit")
                exit 0
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
