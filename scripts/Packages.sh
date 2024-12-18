#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE="\e[34m"
ENDCOLOR="\e[0m"
RESET='\033[0m'

install_paru() {
    if ! command -v paru &> /dev/null; then
        echo -e "${RED}Paru not found. Installing...${RESET}"
        sudo pacman -S --needed base-devel

        temp_dir=$(mktemp -d)
        cd "$temp_dir" || { echo -e "${RED}Failed to create temp directory${RESET}"; exit 1; }

        git clone https://aur.archlinux.org/paru.git
        cd paru || { echo -e "${RED}Failed to enter paru directory${RESET}"; exit 1; }
        makepkg -si
        
        cd ..
        rm -rf "$temp_dir"
        echo -e "${GREEN}Paru installed successfully.${RESET}"
    else
        echo -e "${GREEN}Paru is already installed.${RESET}"
    fi
}

install_communication() {
    install_paru
    while true; do
        comm_choice=$(gum choose "Discord" "Signal" "Telegram" "Keybase" "Exit")

        case $comm_choice in
            "Discord")
                gum spin --spinner dot --title "Installing Discord..." -- paru -S --noconfirm discord && \
                version=$(pacman -Qi discord | grep Version | awk '{print $3}') && \
                gum format "🎉 **Discord installed successfully! Version: $version**"
                ;;
            "Signal")
                gum spin --spinner dot --title "Installing Signal..." -- paru -S --noconfirm signal-desktop && \
                version=$(pacman -Qi signal-desktop | grep Version | awk '{print $3}') && \
                gum format "🎉 **Signal installed successfully! Version: $version**"
                ;;
            "Telegram")
                gum spin --spinner dot --title "Installing Telegram..." -- paru -S --noconfirm telegram-desktop && \
                version=$(pacman -Qi telegram-desktop | grep Version | awk '{print $3}') && \
                gum format "🎉 **Telegram installed successfully! Version: $version**"
                ;;
            "Keybase")
                gum spin --spinner dot --title "Installing Keybase..." -- paru -S --noconfirm keybase-bin && \
                version=$(pacman -Qi keybase-bin | grep Version | awk '{print $3}') && \
                gum format "🎉 **Keybase installed successfully! Version: $version**"
                ;;
            "Exit")
                break
                ;;
        esac
    done
}

install_streaming() {
    while true; do
        stream_choice=$(gum choose "OBS Studio" "Exit")

        case $stream_choice in
            "OBS Studio")
                gum spin --spinner dot --title "Installing OBS Studio..." -- sudo pacman -S --noconfirm obs-studio && \
                version=$(pacman -Qi obs-studio | grep Version | awk '{print $3}') && \
                gum format "🎉 **OBS Studio installed successfully! Version: $version**"
                ;;
            "Exit") break ;;
        esac
    done
}

install_editing() {
    while true; do
        edit_choice=$(gum choose "GIMP (Image)" "Kdenlive (Videos)" "Exit")

        case $edit_choice in
            "GIMP (Image)")
                gum spin --spinner dot --title "Installing GIMP..." -- sudo pacman -S --noconfirm gimp && \
                version=$(pacman -Qi gimp | grep Version | awk '{print $3}') && \
                gum format "🎉 **GIMP installed successfully! Version: $version**"
                ;;
            "Kdenlive (Videos)")
                gum spin --spinner dot --title "Installing Kdenlive..." -- sudo pacman -S --noconfirm kdenlive && \
                version=$(pacman -Qi kdenlive | grep Version | awk '{print $3}') && \
                gum format "🎉 **Kdenlive installed successfully! Version: $version**"
                ;;
            "Exit")
                break
                ;;
        esac
    done
}

install_terminals() {
    install_paru
    while true; do
        echo -e "${BLUE}If you're unsure what to choose, Kitty or Alacritty are great options.${RESET}"
        echo -e "${YELLOW}----------------------------------------------------------------------${RESET}"

        terminal_choice=$(gum choose "Alacritty" "Kitty" "GNOME Terminal" "Konsole" \
    "Xfce Terminal" "LXTerminal" "MATE Terminal" "xterm" \
    "urxvt (rxvt-unicode)" "Tilix" "Terminator" "Guake" "Yakuake" \
    "Tilda" "Cool Retro Term" "Sakura" "st (Simple Terminal)" "Eterm" \
    "WezTerm" "Deepin Terminal" "Zellij" "Termite" "fbterm" "Exit")

        case $terminal_choice in
            "Alacritty") sudo pacman -S alacritty ;;
            "Kitty") sudo pacman -S kitty ;;
            "GNOME Terminal") sudo pacman -S gnome-terminal ;;
            "Konsole") sudo pacman -S konsole ;;
            "Xfce Terminal") sudo pacman -S xfce4-terminal ;;
            "LXTerminal") sudo pacman -S lxterminal ;;
            "MATE Terminal") sudo pacman -S mate-terminal ;;
            "xterm") sudo pacman -S xterm ;;
            "urxvt (rxvt-unicode)") sudo pacman -S rxvt-unicode ;;
            "Tilix") sudo pacman -S tilix ;;
            "Terminator") sudo pacman -S terminator ;;
            "Guake") sudo pacman -S guake ;;
            "Yakuake") sudo pacman -S yakuake ;;
            "Tilda") sudo pacman -S tilda ;;
            "Cool Retro Term") sudo pacman -S cool-retro-term ;;
            "Sakura") sudo pacman -S sakura ;;
            "st (Simple Terminal)") paru -S st ;;
            "Eterm") paru -S eterm ;;
            "WezTerm") sudo pacman -S wezterm ;;
            "Deepin Terminal") sudo pacman -S deepin-terminal ;;
            "Zellij") sudo pacman -S zellij ;;
            "Termite") paru -S termite ;;
            "fbterm") paru -S fbterm ;;
            "Exit") break ;;
        esac
    done
}

install_browsers() {
    install_paru
    while true; do
        browser_choice=$(gum choose "Brave" "Firefox" "Google Chrome" "Chromium" "Qute Browser" "Zen Browser" "Thorium Browser" "Tor Browser" "Exit")

        case $browser_choice in
            "Brave")
                gum spin --spinner dot --title "Installing Brave Browser..." -- paru -S --noconfirm brave-bin && \
                version=$(pacman -Qi brave-bin | grep Version | awk '{print $3}') && \
                gum format "🎉 **Brave Browser installed successfully! Version: $version**"
                ;;
            "Firefox")
                gum spin --spinner dot --title "Installing Firefox..." -- sudo pacman -S --noconfirm firefox && \
                version=$(pacman -Qi firefox | grep Version | awk '{print $3}') && \
                gum format "🎉 **Firefox installed successfully! Version: $version**"
                ;;
            "Google Chrome")
                gum spin --spinner dot --title "Installing Google Chrome..." -- paru -S --noconfirm google-chrome && \
                version=$(pacman -Qi google-chrome | grep Version | awk '{print $3}') && \
                gum format "🎉 **Google Chrome installed successfully! Version: $version**"
                ;;
            "Chromium")
                gum spin --spinner dot --title "Installing Chromium..." -- sudo pacman -S --noconfirm chromium && \
                version=$(pacman -Qi chromium | grep Version | awk '{print $3}') && \
                gum format "🎉 **Chromium installed successfully! Version: $version**"
                ;;
            "Qute Browser")
                gum spin --spinner dot --title "Installing Qute Browser..." -- sudo pacman -S --noconfirm qutebrowser && \
                version=$(pacman -Qi qutebrowser | grep Version | awk '{print $3}') && \
                gum format "🎉 **Qute Browser installed successfully! Version: $version**"
                ;;
            "Zen Browser")
                gum spin --spinner dot --title "Installing Zen Browser..." -- paru -S --noconfirm zen-browser-bin && \
                version=$(pacman -Qi zen-browser-bin | grep Version | awk '{print $3}') && \
                gum format "🎉 **Zen Browser installed successfully! Version: $version**"
                ;;
            "Thorium Browser")
                gum spin --spinner dot --title "Installing Thorium Browser..." -- paru -S --noconfirm thorium-browser-bin && \
                version=$(pacman -Qi thorium-browser-bin | grep Version | awk '{print $3}') && \
                gum format "🎉 **Thorium Browser installed successfully! Version: $version**"
                ;;
            "Tor Browser")
                gum spin --spinner dot --title "Installing Tor Browser..." -- paru -S --noconfirm tor-browser-bin && \
                version=$(pacman -Qi tor-browser-bin | grep Version | awk '{print $3}') && \
                gum format "🎉 **Tor Browser installed successfully! Version: $version**"
                ;;
            "Exit")
                break
                ;;
        esac
    done
}

install_filemanagers() {
    while true; do
        fm_choice=$(gum choose "Nemo" "Thunar" "Dolphin" "LF (Terminal File Manager)" "Ranger" "Nautilus" "Yazi" "Exit")

        case $fm_choice in
            "Nemo")
                gum spin --spinner dot --title "Installing Nemo..." -- sudo pacman -S --noconfirm nemo && \
                version=$(pacman -Qi nemo | grep Version | awk '{print $3}') && \
                gum format "🎉 **Nemo installed successfully! Version: $version**"
                ;;
            "Thunar")
                gum spin --spinner dot --title "Installing Thunar..." -- sudo pacman -S --noconfirm thunar && \
                version=$(pacman -Qi thunar | grep Version | awk '{print $3}') && \
                gum format "🎉 **Thunar installed successfully! Version: $version**"
                ;;
            "Dolphin")
                gum spin --spinner dot --title "Installing Dolphin..." -- sudo pacman -S --noconfirm dolphin && \
                version=$(pacman -Qi dolphin | grep Version | awk '{print $3}') && \
                gum format "🎉 **Dolphin installed successfully! Version: $version**"
                ;;
            "LF (Terminal File Manager)")
                gum spin --spinner dot --title "Installing LF..." -- sudo pacman -S --noconfirm lf && \
                version=$(pacman -Qi lf | grep Version | awk '{print $3}') && \
                gum format "🎉 **LF installed successfully! Version: $version**"
                ;;
            "Ranger")
                gum spin --spinner dot --title "Installing Ranger..." -- sudo pacman -S --noconfirm ranger && \
                version=$(pacman -Qi ranger | grep Version | awk '{print $3}') && \
                gum format "🎉 **Ranger installed successfully! Version: $version**"
                ;;
            "Nautilus")
                gum spin --spinner dot --title "Installing Nautilus..." -- sudo pacman -S --noconfirm nautilus && \
                version=$(pacman -Qi nautilus | grep Version | awk '{print $3}') && \
                gum format "🎉 **Nautilus installed successfully! Version: $version**"
                ;;
            "Yazi")
                gum spin --spinner dot --title "Installing Yazi..." -- sudo pacman -S --noconfirm yazi && \
                version=$(pacman -Qi yazi | grep Version | awk '{print $3}') && \
                gum format "🎉 **Yazi installed successfully! Version: $version**"
                ;;
            "Exit")
                break
                ;;
        esac
    done
}

install_music() {
    install_paru
    while true; do
        music_choice=$(gum choose "Youtube-Music" "Spotube" "Spotify" "Rhythmbox" "Exit")

        case $music_choice in
            "Youtube-Music")
                gum spin --spinner dot --title "Installing Youtube-Music..." -- paru -S --noconfirm youtube-music-bin && \
                version=$(paru -Qi youtube-music-bin | grep Version | awk '{print $3}') && \
                gum format "🎉 **Youtube-Music installed successfully! Version: $version**"
                ;;
            "Spotube")
                gum spin --spinner dot --title "Installing Spotube..." -- paru -S --noconfirm spotube && \
                version=$(paru -Qi spotube | grep Version | awk '{print $3}') && \
                gum format "🎉 **Spotube installed successfully! Version: $version**"
                ;;
            "Spotify")
                gum spin --spinner dot --title "Installing Spotify..." -- paru -S --noconfirm spotify && \
                version=$(paru -Qi spotify | grep Version | awk '{print $3}') && \
                gum format "🎉 **Spotify installed successfully! Version: $version**"
                ;;
            "Rhythmbox")
                gum spin --spinner dot --title "Installing Rhythmbox..." -- paru -S --noconfirm rhythmbox && \
                version=$(paru -Qi rhythmbox | grep Version | awk '{print $3}') && \
                gum format "🎉 **Rhythmbox installed successfully! Version: $version**"
                ;;
            "Exit")
                break
                ;;
        esac
    done
}

install_texteditor() {
    install_paru
    while true; do
        texteditor_choice=$(gum choose "Cursor (AI Code Editor)" "Visual Studio Code (VSCODE)" "Vscodium" "ZED Editor" "Neovim" "Vim" "Code-OSS" "Exit")

        case $texteditor_choice in
            "Cursor (AI Code Editor)")
                gum spin --spinner dot --title "Installing Cursor (AI Code Editor)..." -- paru -S --noconfirm cursor-bin && \
                version=$(paru -Qi cursor-bin | grep Version | awk '{print $3}') && \
                gum format "🎉 **Cursor installed successfully! Version: $version**"
                ;;
            "Visual Studio Code (VSCODE)")
                gum spin --spinner dot --title "Installing Visual Studio Code..." -- paru -S --noconfirm visual-studio-code-bin && \
                version=$(paru -Qi visual-studio-code-bin | grep Version | awk '{print $3}') && \
                gum format "🎉 **Visual Studio Code installed successfully! Version: $version**"
                ;;
            "Vscodium")
                gum spin --spinner dot --title "Installing Vscodium..." -- paru -S --noconfirm vscodium-bin && \
                version=$(paru -Qi vscodium-bin | grep Version | awk '{print $3}') && \
                gum format "🎉 **Vscodium installed successfully! Version: $version**"
                ;;
            "ZED Editor")
                gum spin --spinner dot --title "Installing ZED Editor..." -- paru -S --noconfirm zed-preview-bin && \
                version=$(paru -Qi zed-preview-bin | grep Version | awk '{print $3}') && \
                gum format "🎉 **ZED Editor installed successfully! Version: $version**"
                ;;
            "Neovim")
                gum spin --spinner dot --title "Installing Neovim..." -- paru -S --noconfirm neovim && \
                version=$(paru -Qi neovim | grep Version | awk '{print $3}') && \
                gum format "🎉 **Neovim installed successfully! Version: $version**"
                ;;
            "Vim")
                gum spin --spinner dot --title "Installing Vim..." -- paru -S --noconfirm vim && \
                version=$(paru -Qi vim | grep Version | awk '{print $3}') && \
                gum format "🎉 **Vim installed successfully! Version: $version**"
                ;;
            "Code-OSS")
                gum spin --spinner dot --title "Installing Code-OSS..." -- paru -S --noconfirm coder-oss && \
                version=$(paru -Qi coder-oss | grep Version | awk '{print $3}') && \
                gum format "🎉 **Code-OSS installed successfully! Version: $version**"
                ;;
            "Exit")
                break
                ;;
        esac
    done
}

install_multimedia() {
    install_paru
    while true; do
        multimedia_choice=$(gum choose "VLC" "Netflix [Unofficial]" "Exit")

        case $multimedia_choice in
            "VLC")
                gum spin --spinner dot --title "Installing VLC..." -- paru -S --noconfirm vlc && \
                version=$(paru -Qi vlc | grep Version | awk '{print $3}') && \
                gum format "🎉 **VLC installed successfully! Version: $version**"
                ;;
            "Netflix [Unofficial]")
                gum spin --spinner dot --title "Installing Netflix [Unofficial]..." -- paru -S --noconfirm netflix && \
                version=$(paru -Qi netflix | grep Version | awk '{print $3}') && \
                gum format "🎉 **Netflix [Unofficial] installed successfully! Version: $version**"
                ;;
            "Exit")
                break
                ;;
        esac
    done
}

install_github() {
    install_paru
    while true; do
        github_choice=$(gum choose "Git" "Github" "Exit")

        case $github_choice in
            "Git")
                gum spin --spinner dot --title "Installing Git..." -- paru -S --noconfirm git && \
                version=$(paru -Qi git | grep Version | awk '{print $3}') && \
                gum format "🎉 **Git installed successfully! Version: $version**"
                ;;
            "Github")
                gum spin --spinner dot --title "Installing GitHub Desktop..." -- paru -S --noconfirm github-desktop-bin && \
                version=$(paru -Qi github-desktop-bin | grep Version | awk '{print $3}') && \
                gum format "🎉 **GitHub Desktop installed successfully! Version: $version**"
                ;;
            "Exit")
                break
                ;;
        esac
    done
}

install_thunarpreview() {
    install_paru
    while true; do
        gum format "**This package enables thumbnail previews in the Thunar file manager.**"
        gum format "----------------------------------------------------------------------"
        thunarpreview_choice=$(gum choose "Tumbler" "Exit")

        case $thunarpreview_choice in
            "Tumbler")
                gum spin --spinner dot --title "Installing Tumbler..." -- paru -S --noconfirm tumbler && \
                version=$(paru -Qi tumbler | grep Version | awk '{print $3}') && \
                gum format "🎉 **Tumbler installed successfully! Version: $version**"
                ;;
            "Exit")
                break
                ;;
        esac
    done
}

install_andriod() {
    install_paru
    while true; do
        gum format "**Android debloat and subsystem packages.**"
        gum format "---------------------------------------------"
        andriod_choice=$(gum choose "Gvfs-MTP [Displays Android phones via USB]" "ADB" "Exit")

        case $andriod_choice in
            "Gvfs-MTP [Displays Android phones via USB]")
                gum spin --spinner dot --title "Installing Gvfs-MTP..." -- paru -S --noconfirm gvfs-mtp && \
                version=$(paru -Qi gvfs-mtp | grep Version | awk '{print $3}') && \
                gum format "🎉 **Gvfs-MTP installed successfully! Version: $version**"
                ;;
            "ADB")
                gum spin --spinner dot --title "Installing ADB..." -- paru -S --noconfirm adb && \
                version=$(paru -Qi adb | grep Version | awk '{print $3}') && \
                gum format "🎉 **ADB installed successfully! Version: $version**"
                ;;
            "Exit")
                break
                ;;
        esac
    done
}
    
while true; do
    clear 
    echo -e "${BLUE}"
    figlet -f slant "Packages"
    echo -e "${ENDCOLOR}"
    main_choice=$(gum choose "Communication & Chatting" "Live Streaming/Recording" "Editing" "Terminal" "Browsers" "File Managers" "Music" "Coding & Text Editor" "Multimedia" "Github" "Thunar [Thumbnail Preview]" "Andriod" "Exit")

    case $main_choice in
        "Communication & Chatting") install_communication ;;
        "Live Streaming/Recording") install_streaming ;;
        "Editing") install_editing ;;
        "Terminal") install_terminals ;;
        "Browsers") install_browsers ;;
        "File Managers") install_filemanagers ;;
        "Music") install_music ;;
        "Coding & Text Editor") install_texteditor ;;
        "Multimedia") install_multimedia ;;
        "Github") install_github ;;
        "Thunar [Thumbnail Preview]") install_thunarpreview ;;
        "Andriod") install_andriod ;;
        "Exit") exit ;;
    esac
done
