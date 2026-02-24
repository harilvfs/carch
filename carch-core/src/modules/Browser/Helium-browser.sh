#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_helium() {
    clear
    print_message "$YELLOW" "Fetching latest Helium browser release..."

    local appimage_dir="$HOME/Applications"
    mkdir -p "$appimage_dir"

    local api_url="https://api.github.com/repos/imputnet/helium-linux/releases/latest"
    local appimage_url
    appimage_url=$(curl -s $api_url | jq -r '.assets[] | select(.name | contains("x86_64") and endswith(".AppImage")) | .browser_download_url' | head -1)

    # fallback if anything goes wrong
    if [[ -z "$appimage_url" ]]; then
        print_message "$RED" "Failed to fetch latest release URL"
        print_message "$YELLOW" "Falling back to version 0.9.3.1..."
        appimage_url="https://github.com/imputnet/helium-linux/releases/download/0.9.3.1/helium-0.9.3.1-x86_64.AppImage"
    fi

    local filename=$(basename "$appimage_url")
    local appimage_path="$appimage_dir/$filename"

    print_message "$YELLOW" "Downloading $filename..."

    curl -L "$appimage_url" -o "$appimage_path"

    if [[ $? -eq 0 ]]; then
        chmod +x "$appimage_path"

        if [[ -d "/usr/local/bin" && -w "/usr/local/bin" ]]; then
            sudo ln -sf "$appimage_path" /usr/local/bin/helium-browser 2> /dev/null
        else
            mkdir -p "$HOME/.local/bin"
            ln -sf "$appimage_path" "$HOME/.local/bin/helium-browser" 2> /dev/null

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

        print_message "$GREEN" "Helium browser downloaded successfully"
        print_message "$GREEN" "Location: $appimage_path"

        create_helium_desktop_entry "$appimage_path"

        print_message "$CYAN" "Run Helium browser by typing: helium-browser"
        print_message "$CYAN" "Or run directly: $appimage_path"
        print_message "$CYAN" "Note: Helium is currently in beta (check GitHub for updates)"

    else
        print_message "$RED" "Failed to download Helium browser AppImage"
        print_message "$YELLOW" "Download manually from: https://github.com/imputnet/helium-linux/releases"
    fi
}

create_helium_desktop_entry() {
    local appimage_path="$1"
    local desktop_entry="$HOME/.local/share/applications/helium-browser.desktop"

    mkdir -p "$HOME/.local/share/applications"
    mkdir -p "$HOME/.local/share/icons"

    local icon_path="$HOME/.local/share/icons/helium-browser.png"
    curl -s "https://raw.githubusercontent.com/imputnet/helium/refs/heads/main/resources/branding/app_icon/raw.png" -o "$icon_path" 2> /dev/null

    cat > "$desktop_entry" << EOF
[Desktop Entry]
Name=Helium Browser
Comment=A lightweight, privacy-focused browser (Beta)
Exec=$appimage_path
Icon=$icon_path
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;
StartupWMClass=helium
EOF

    chmod +x "$desktop_entry"
    print_message "$GREEN" "Desktop entry created"
}

install_helium
