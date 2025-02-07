#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE="\e[34m"
ENDCOLOR="\e[0m"
RESET='\033[0m'

detect_distro() {
    if [[ -f "/etc/os-release" ]]; then
        . /etc/os-release
        case "$ID" in
            arch | arcolinux | endeavor | manjaro)
                echo -e "${GREEN}:: Arch-based system detected.${RESET}"
                return 0
                ;;
            fedora)
                echo -e "${YELLOW}:: Fedora detected. Skipping AUR helper installation.${RESET}"
                return 1
                ;;
            *)
                echo -e "${RED}:: Unsupported distribution detected. Proceeding cautiously...${RESET}"
                return 2
                ;;
        esac
    else
        echo -e "${RED}:: Unable to detect the distribution.${RESET}"
        return 2
    fi
}

install_yay() {
    detect_distro
    case $? in
        1) return ;; 
        2) echo -e "${YELLOW}:: Proceeding, but AUR installation may not work properly.${RESET}" ;;
    esac

    if command -v yay &>/dev/null; then
        echo -e "${GREEN}:: Yay is already installed.${RESET}"
        return
    fi

    if command -v paru &>/dev/null; then
        echo -e "${GREEN}:: Paru is installed. Using paru instead of yay.${RESET}"
        return
    fi

    echo -e "${RED}:: No AUR helper found. Installing yay...${RESET}"
    
    sudo pacman -S --needed git base-devel

    temp_dir=$(mktemp -d)
    cd "$temp_dir" || { echo -e "${RED}Failed to create temp directory${RESET}"; exit 1; }

    git clone https://aur.archlinux.org/yay.git
    cd yay || { echo -e "${RED}Failed to enter yay directory${RESET}"; exit 1; }
    makepkg -si

    cd ..
    rm -rf "$temp_dir"
    echo -e "${GREEN}:: Yay installed successfully.${RESET}"
}

install_flatpak() {
    if ! command -v flatpak &>/dev/null; then
        echo -e "${YELLOW}:: Flatpak not found. Installing...${RESET}"
        sudo dnf install -y flatpak
    fi
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

install_fedora_package() {
    package_name="$1"
    flatpak_id="$2"

    if sudo dnf list --available | grep -q "^$package_name"; then
        gum spin --spinner dot --title "Installing $package_name via DNF..." -- sudo dnf install -y "$package_name"
    else
        echo -e "${YELLOW}:: $package_name not found in DNF. Falling back to Flatpak.${RESET}"
        gum spin --spinner dot --title "Installing $package_name via Flatpak..." -- flatpak install -y flathub "$flatpak_id"
    fi
}

install_communication() {
    detect_distro
    distro=$?
    
    if [[ $distro -eq 0 ]]; then
        install_yay
        pkg_manager="yay -S --noconfirm"
    elif [[ $distro -eq 1 ]]; then
        install_flatpak
        pkg_manager="install_fedora_package"
    else
        echo -e "${RED}:: Unsupported system. Exiting.${RESET}"
        return
    fi

    while true; do
        comm_choice=$(gum choose "Discord" "Better Discord" "Signal" "Telegram" "Keybase" "Exit")

        case $comm_choice in
            "Discord")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Discord..." -- $pkg_manager discord
                else
                    $pkg_manager "discord" "com.discordapp.Discord"
                fi
                ;;
            "Better Discord")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Better Discord..." -- $pkg_manager betterdiscord-installer-bin
                else
                    echo -e "${YELLOW}:: Better Discord is not available for Fedora.${RESET}"
                fi
                ;;
            "Signal")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Signal..." -- $pkg_manager signal-desktop
                else
                    $pkg_manager "signal-desktop" "org.signal.Signal"
                fi
                ;;
            "Telegram")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Telegram..." -- $pkg_manager telegram-desktop
                else
                    $pkg_manager "telegram-desktop" "org.telegram.desktop"
                fi
                ;;
            "Keybase")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Keybase..." -- $pkg_manager keybase-bin
                else
                    gum spin --spinner dot --title "Installing Keybase via RPM..." -- sudo dnf install -y https://prerelease.keybase.io/keybase_amd64.rpm
                    run_keybase
                fi
                ;;
            "Exit")
                break
                ;;
        esac
    done
}

install_streaming() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_yay
        pkg_manager="sudo pacman -S --noconfirm"
    elif [[ $distro -eq 1 ]]; then
        pkg_manager="sudo dnf install -y"
    else
        echo -e "${RED}:: Unsupported system. Exiting.${RESET}"
        return
    fi

    while true; do
        stream_choice=$(gum choose "OBS Studio" "SimpleScreenRecorder [Git]" "Exit")

        case $stream_choice in
            "OBS Studio")
                gum spin --spinner dot --title "Installing OBS Studio..." -- $pkg_manager obs-studio
                version=$([[ $distro -eq 0 ]] && pacman -Qi obs-studio | grep Version | awk '{print $3}' || rpm -q obs-studio)
                gum format "🎉 **OBS Studio installed successfully! Version: $version**"
                ;;
            "SimpleScreenRecorder [Git]")
                if [[ $distro -eq 0 ]]; then
                    gum confirm "The Git version builds from source and may take some time. Proceed?" && \
                    gum spin --spinner dot --title "Installing SimpleScreenRecorder [Git]..." -- yay -S --noconfirm simplescreenrecorder-git && \
                    version=$(pacman -Qi simplescreenrecorder-git | grep Version | awk '{print $3}')
                    gum format "🎉 **SimpleScreenRecorder [Git] installed successfully! Version: $version**"
                else
                    echo -e "${YELLOW}:: SimpleScreenRecorder [Git] is not available on Fedora.${RESET}"
                fi
                ;;
            "Exit")
                break
                ;;
        esac
    done
}

install_editing() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        pkg_manager="sudo pacman -S --noconfirm"
    elif [[ $distro -eq 1 ]]; then
        pkg_manager="sudo dnf install -y"
    else
        echo -e "${RED}:: Unsupported system. Exiting.${RESET}"
        return
    fi

    while true; do
        edit_choice=$(gum choose "GIMP (Image)" "Kdenlive (Videos)" "Exit")

        case $edit_choice in
            "GIMP (Image)")
                gum spin --spinner dot --title "Installing GIMP..." -- $pkg_manager gimp
                version=$([[ $distro -eq 0 ]] && pacman -Qi gimp | grep Version | awk '{print $3}' || rpm -q gimp)
                gum format "🎉 **GIMP installed successfully! Version: $version**"
                ;;
            "Kdenlive (Videos)")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Kdenlive..." -- $pkg_manager kdenlive
                    version=$(pacman -Qi kdenlive | grep Version | awk '{print $3}')
                    gum format "🎉 **Kdenlive installed successfully! Version: $version**"
                else
                    gum spin --spinner dot --title "Installing Kdenlive on Fedora..." -- $pkg_manager kdenlive
                    version=$(rpm -q kdenlive)
                    gum format "🎉 **Kdenlive installed successfully! Version: $version**"
                fi
                ;;
            "Exit")
                break
                ;;
        esac
    done
}


install_terminals() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        pkg_manager="sudo pacman -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        install_flatpak
        pkg_manager="sudo dnf install -y"
        flatpak_cmd="flatpak install -y --noninteractive flathub"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${RESET}"
        return
    fi

    while true; do
        echo -e "${BLUE}If you're unsure what to choose, Kitty or Alacritty are great options.${RESET}"
        echo -e "${YELLOW}----------------------------------------------------------------------${RESET}"

        terminal_choice=$(gum choose "Alacritty" "Kitty" "GNOME Terminal" "Konsole" "WezTerm" "Ghostty" "Exit")

        case $terminal_choice in
            "Alacritty")
                gum spin --spinner dot --title "Installing Alacritty..." -- $pkg_manager alacritty
                version=$(get_version alacritty)
                gum format "🎉 **Alacritty installed successfully! Version: $version**"
                ;;
            "Kitty")
                gum spin --spinner dot --title "Installing Kitty..." -- $pkg_manager kitty
                version=$(get_version kitty)
                gum format "🎉 **Kitty installed successfully! Version: $version**"
                ;;
            "GNOME Terminal")
                gum spin --spinner dot --title "Installing GNOME Terminal..." -- $pkg_manager gnome-terminal
                version=$(get_version gnome-terminal)
                gum format "🎉 **GNOME Terminal installed successfully! Version: $version**"
                ;;
            "Konsole")
                gum spin --spinner dot --title "Installing Konsole..." -- $pkg_manager konsole
                version=$(get_version konsole)
                gum format "🎉 **Konsole installed successfully! Version: $version**"
                ;;
            "WezTerm")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing WezTerm..." -- $pkg_manager wezterm
                    version=$(get_version wezterm)
                    gum format "🎉 **WezTerm installed successfully! Version: $version**"
                elif [[ $distro -eq 1 ]]; then
                    if sudo dnf list --installed wezterm &>/dev/null; then
                        version=$(get_version wezterm)
                        gum format "🎉 **WezTerm is already installed! Version: $version**"
                    else
                        gum spin --spinner dot --title "Installing WezTerm from DNF..." -- sudo dnf install -y wezterm
                        if [[ $? -ne 0 ]]; then
                            gum spin --spinner dot --title "WezTerm not found in DNF, falling back to Flatpak..." -- $flatpak_cmd org.wezfurlong.wezterm
                            version="(Flatpak version installed)"
                        else
                            version=$(get_version wezterm)
                        fi
                        gum format "🎉 **WezTerm installed successfully! Version: $version**"
                    fi
                fi
                ;;
            "Ghostty")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Ghostty..." -- $pkg_manager ghostty
                elif [[ $distro -eq 1 ]]; then
                    gum spin --spinner dot --title "Enabling Ghostty repository..." -- sudo dnf copr enable pgdev/ghostty -y
                    gum spin --spinner dot --title "Installing Ghostty..." -- sudo dnf install -y ghostty
                fi
                version=$(get_version ghostty)
                gum format "🎉 **Ghostty installed successfully! Version: $version**"
                ;;
            "Exit")
                break
                ;;
        esac
    done
}

install_browsers() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_yay
        pkg_manager_aur="yay -S --noconfirm"
        pkg_manager_pacman="sudo pacman -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        install_flatpak
        pkg_manager="sudo dnf install -y"
        flatpak_cmd="flatpak install -y --noninteractive flathub"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${RESET}"
        return
    fi

    while true; do
        browser_choice=$(gum choose "Brave" "Firefox" "Libre Wolf" "Google Chrome" "Chromium" "Vivaldi" "Qute Browser" "Zen Browser" "Thorium Browser" "Tor Browser" "Exit")

        case $browser_choice in
            "Brave")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Brave Browser..." -- $pkg_manager_aur brave-bin
                    version=$(get_version brave-bin)
                else
                    gum spin --spinner dot --title "Installing Brave Browser via Flatpak..." -- $flatpak_cmd com.brave.Browser
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Brave Browser installed successfully! Version: $version**"
                ;;
            "Firefox")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Firefox..." -- $pkg_manager_pacman firefox
                    version=$(get_version firefox)
                else
                    gum spin --spinner dot --title "Installing Firefox via DNF..." -- $pkg_manager firefox
                    version=$(get_version firefox)
                fi
                gum format "🎉 **Firefox installed successfully! Version: $version**"
                ;;
            "Libre Wolf")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Libre Wolf..." -- $pkg_manager_aur librewolf-bin
                    version=$(get_version librewolf-bin)
                else
                    gum spin --spinner dot --title "Installing Libre Wolf via Flatpak..." -- $flatpak_cmd io.gitlab.librewolf-community
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Libre Wolf installed successfully! Version: $version**"
                ;;
            "Google Chrome")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Google Chrome..." -- $pkg_manager_aur google-chrome
                    version=$(get_version google-chrome)
                else
                    gum spin --spinner dot --title "Installing Google Chrome via Flatpak..." -- $flatpak_cmd com.google.Chrome
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Google Chrome installed successfully! Version: $version**"
                ;;
            "Chromium")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Chromium..." -- $pkg_manager_pacman chromium
                    version=$(get_version chromium)
                else
                    gum spin --spinner dot --title "Installing Chromium via Flatpak..." -- $flatpak_cmd org.chromium.Chromium
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Chromium installed successfully! Version: $version**"
                ;;
            "Vivaldi")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Vivaldi..." -- $pkg_manager_pacman vivaldi
                    version=$(get_version vivaldi)
                else
                    gum spin --spinner dot --title "Installing Vivaldi via Flatpak..." -- $flatpak_cmd com.vivaldi.Vivaldi
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Vivaldi installed successfully! Version: $version**"
                ;;
            "Qute Browser")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Qute Browser..." -- $pkg_manager_pacman qutebrowser
                    version=$(get_version qutebrowser)
                else
                    gum spin --spinner dot --title "Installing Qute Browser via Flatpak..." -- $flatpak_cmd org.qutebrowser.qutebrowser
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Qute Browser installed successfully! Version: $version**"
                ;;
            "Zen Browser")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Zen Browser..." -- $pkg_manager_aur zen-browser-bin
                    version=$(get_version zen-browser-bin)
                else
                    gum spin --spinner dot --title "Installing Zen Browser via Flatpak..." -- $flatpak_cmd app.zen_browser.zen
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Zen Browser installed successfully! Version: $version**"
                ;;
            "Thorium Browser")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Thorium Browser..." -- $pkg_manager_aur thorium-browser-bin
                    version=$(get_version thorium-browser-bin)
                    gum format "🎉 **Thorium Browser installed successfully! Version: $version**"
                else
                    gum format "❌ **Thorium Browser is not available on Fedora repositories or Flatpak. Visit [Thorium Website](https://thorium.rocks/) for installation instructions.**"
                fi
                ;;
            "Tor Browser")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Tor Browser..." -- $pkg_manager_aur tor-browser-bin
                    version=$(get_version tor-browser-bin)
                else
                    gum spin --spinner dot --title "Installing Tor Browser via Flatpak..." -- $flatpak_cmd org.torproject.torbrowser-launcher
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Tor Browser installed successfully! Version: $version**"
                ;;
            "Exit")
                break
                ;;
        esac
    done
}

install_filemanagers() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        pkg_manager="sudo pacman -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        pkg_manager="sudo dnf install -y"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${RESET}"
        return
    fi

    while true; do
        fm_choice=$(gum choose "Nemo" "Thunar" "Dolphin" "LF (Terminal File Manager)" "Ranger" "Nautilus" "Yazi" "Exit")

        case $fm_choice in
            "Nemo")
                gum spin --spinner dot --title "Installing Nemo..." -- $pkg_manager nemo
                version=$(get_version nemo)
                gum format "🎉 **Nemo installed successfully! Version: $version**"
                ;;
            "Thunar")
                gum spin --spinner dot --title "Installing Thunar..." -- $pkg_manager thunar
                version=$(get_version thunar)
                gum format "🎉 **Thunar installed successfully! Version: $version**"
                ;;
            "Dolphin")
                gum spin --spinner dot --title "Installing Dolphin..." -- $pkg_manager dolphin
                version=$(get_version dolphin)
                gum format "🎉 **Dolphin installed successfully! Version: $version**"
                ;;
            "LF (Terminal File Manager)")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing LF..." -- $pkg_manager lf
                    version=$(get_version lf)
                else
                    gum spin --spinner dot --title "Enabling LF COPR repository..." -- sudo dnf copr enable lsevcik/lf -y
                    gum spin --spinner dot --title "Installing LF..." -- sudo dnf install -y lf
                    version=$(get_version lf)
                fi
                gum format "🎉 **LF installed successfully! Version: $version**"
                ;;
            "Ranger")
                gum spin --spinner dot --title "Installing Ranger..." -- $pkg_manager ranger
                version=$(get_version ranger)
                gum format "🎉 **Ranger installed successfully! Version: $version**"
                ;;
            "Nautilus")
                gum spin --spinner dot --title "Installing Nautilus..." -- $pkg_manager nautilus
                version=$(get_version nautilus)
                gum format "🎉 **Nautilus installed successfully! Version: $version**"
                ;;
            "Yazi")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Yazi..." -- $pkg_manager yazi
                    version=$(get_version yazi)
                else
                    gum spin --spinner dot --title "Adding Yazi repository..." -- sudo dnf copr enable varlad/yazi -y
                    gum spin --spinner dot --title "Installing Yazi..." -- sudo dnf install -y yazi
                    version=$(get_version yazi)
                fi
                gum format "🎉 **Yazi installed successfully! Version: $version**"
                ;;
            "Exit")
                break
                ;;
        esac
    done
}

install_music() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_yay
        pkg_manager="yay -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        install_flatpak
        pkg_manager="sudo dnf install -y"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${RESET}"
        return
    fi

    while true; do
        music_choice=$(gum choose "Youtube-Music" "Spotube" "Spotify" "Rhythmbox" "Exit")

        case $music_choice in
            "Youtube-Music")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Youtube-Music..." -- $pkg_manager youtube-music-bin
                    version=$(get_version youtube-music-bin)
                    gum format "🎉 **Youtube-Music installed successfully! Version: $version**"
                else
                    gum format "⚠️ **Youtube-Music is not available for Fedora.**"
                fi
                ;;
            "Spotube")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Spotube..." -- $pkg_manager spotube
                    version=$(get_version spotube)
                else
                    gum spin --spinner dot --title "Installing Spotube via Flatpak..." -- flatpak install -y flathub com.github.KRTirtho.Spotube
                    version="Flatpak Version"
                fi
                gum format "🎉 **Spotube installed successfully! Version: $version**"
                ;;
            "Spotify")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Spotify..." -- $pkg_manager spotify
                    version=$(get_version spotify)
                else
                    gum spin --spinner dot --title "Installing Spotify via Flatpak..." -- flatpak install -y flathub com.spotify.Client
                    version="Flatpak Version"
                fi
                gum format "🎉 **Spotify installed successfully! Version: $version**"
                ;;
            "Rhythmbox")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Rhythmbox..." -- $pkg_manager rhythmbox
                else
                    gum spin --spinner dot --title "Installing Rhythmbox on Fedora..." -- $pkg_manager rhythmbox
                fi
                version=$(get_version rhythmbox)
                gum format "🎉 **Rhythmbox installed successfully! Version: $version**"
                ;;
            "Exit")
                break
                ;;
        esac
    done
}

install_texteditor() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_yay
        pkg_manager_aur="yay -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        install_flatpak
        pkg_manager="sudo dnf install -y"
        flatpak_cmd="flatpak install -y --noninteractive flathub"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${RESET}"
        return
    fi

    while true; do
        texteditor_choice=$(gum choose "Cursor (AI Code Editor)" "Visual Studio Code (VSCODE)" "Vscodium" "ZED Editor" "Neovim" "Vim" "Code-OSS" "Exit")

        case $texteditor_choice in
            "Cursor (AI Code Editor)")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Cursor..." -- $pkg_manager_aur cursor-bin
                    version=$(get_version cursor-bin)
                else
                    gum format "📝 **Cursor is not available in Fedora repositories.**"
                    gum format "🔗 **Download AppImage from:** [Cursor Official Site](https://www.cursor.com/)"
                    gum format "🚀 **To Run:** \`chmod +x Cursor.AppImage && ./Cursor.AppImage\`"
                    version="(Manual installation required)"
                fi
                gum format "🎉 **Cursor installed successfully! Version: $version**"
                ;;

            "Visual Studio Code (VSCODE)")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing VS Code..." -- $pkg_manager_aur visual-studio-code-bin
                    version=$(get_version visual-studio-code-bin)
                else
                    gum spin --spinner dot --title "Installing VS Code via Flatpak..." -- $flatpak_cmd com.visualstudio.code
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **VS Code installed successfully! Version: $version**"
                ;;

            "Vscodium")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Vscodium..." -- $pkg_manager_aur vscodium-bin
                    version=$(get_version vscodium-bin)
                else
                    gum spin --spinner dot --title "Installing Vscodium via Flatpak..." -- $flatpak_cmd com.vscodium.codium
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Vscodium installed successfully! Version: $version**"
                ;;

            "ZED Editor")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing ZED Editor..." -- $pkg_manager_aur zed-preview-bin
                    version=$(get_version zed-preview-bin)
                else
                    gum spin --spinner dot --title "Installing ZED via Flatpak..." -- $flatpak_cmd dev.zed.Zed
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **ZED installed successfully! Version: $version**"
                ;;

            "Neovim")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Neovim..." -- $pkg_manager_aur neovim
                    version=$(get_version neovim)
                else
                    gum spin --spinner dot --title "Installing Neovim via DNF..." -- $pkg_manager neovim
                    version=$(get_version neovim)
                fi
                gum format "🎉 **Neovim installed successfully! Version: $version**"
                ;;

            "Vim")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Vim..." -- $pkg_manager_aur vim
                    version=$(get_version vim)
                else
                    gum spin --spinner dot --title "Installing Vim via Flatpak..." -- $flatpak_cmd org.vim.Vim
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Vim installed successfully! Version: $version**"
                ;;

            "Code-OSS")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Code-OSS..." -- $pkg_manager_aur code-oss
                    version=$(get_version code-oss)
                else
                    gum spin --spinner dot --title "Installing Code-OSS via Flatpak..." -- $flatpak_cmd com.visualstudio.code-oss
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Code-OSS installed successfully! Version: $version**"
                ;;

            "Exit")
                break
                ;;
        esac
    done
}

install_multimedia() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_yay
        pkg_manager_aur="yay -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        pkg_manager="sudo dnf install -y"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${RESET}"
        return
    fi

    while true; do
        multimedia_choice=$(gum choose "VLC" "Netflix [Unofficial]" "Exit")

        case $multimedia_choice in
            "VLC")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing VLC..." -- $pkg_manager_aur vlc
                    version=$(get_version vlc)
                else
                    gum spin --spinner dot --title "Installing VLC via DNF..." -- $pkg_manager vlc
                    version=$(get_version vlc)
                fi
                gum format "🎉 **VLC installed successfully! Version: $version**"
                ;;

            "Netflix [Unofficial]")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Netflix [Unofficial]..." -- $pkg_manager_aur netflix
                    version=$(get_version netflix)
                else
                    gum format "🔴 **Netflix Unofficial requires manual installation on Fedora**"
                    gum format "1️⃣  **Installing required dependencies:**"
                    gum spin --spinner dot --title "Installing wget and OpenCL..." -- sudo dnf install -y wget opencl-utils

                    gum format "2️⃣  **Installing Microsoft Core Fonts:**"
                    gum spin --spinner dot --title "Installing Core Fonts..." -- sudo yum -y localinstall http://sourceforge.net/projects/postinstaller/files/fuduntu/msttcorefonts-2.0-2.noarch.rpm

                    gum format "3️⃣ **Installing Wine Silverlight & Netflix Desktop:**"
                    gum spin --spinner dot --title "Installing Wine Silverlight..." -- sudo yum -y install http://sourceforge.net/projects/postinstaller/files/fedora/releases/19/x86_64/updates/wine-silverligh-1.7.2-1.fc19.x86_64.rpm
                    gum spin --spinner dot --title "Installing Netflix Desktop..." -- sudo yum -y install http://sourceforge.net/projects/postinstaller/files/fedora/releases/19/x86_64/updates/netflix-desktop-0.7.0-7.fc19.noarch.rpm
                    
                    version="(Manual installation required)"
                fi
                gum format "🎉 **Netflix [Unofficial] installed successfully! Version: $version**"
                ;;

            "Exit")
                break
                ;;
        esac
    done
}

install_github() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_yay
        pkg_manager_aur="yay -S --noconfirm"
        pkg_manager_pacman="sudo pacman -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        pkg_manager="sudo dnf install -y"
        flatpak_cmd="flatpak install -y --noninteractive flathub"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${RESET}"
        return
    fi

    while true; do
        github_choice=$(gum choose "Git" "GitHub Desktop" "GitHub CLI" "Exit")

        case $github_choice in
            "Git")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Git..." -- $pkg_manager_aur git
                    version=$(get_version git)
                else
                    gum spin --spinner dot --title "Installing Git via DNF..." -- $pkg_manager git
                    version=$(get_version git)
                fi
                gum format "🎉 **Git installed successfully! Version: $version**"
                ;;

            "GitHub Desktop")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing GitHub Desktop..." -- $pkg_manager_aur github-desktop-bin
                    version=$(get_version github-desktop-bin)
                else
                    gum format "🔄 **Setting up GitHub Desktop repository...**"
                    sudo dnf upgrade --refresh
                    sudo rpm --import https://rpm.packages.shiftkey.dev/gpg.key
                    echo -e "[shiftkey-packages]\nname=GitHub Desktop\nbaseurl=https://rpm.packages.shiftkey.dev/rpm/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://rpm.packages.shiftkey.dev/gpg.key" | sudo tee /etc/yum.repos.d/shiftkey-packages.repo > /dev/null

                    gum spin --spinner dot --title "Installing GitHub Desktop via DNF..." -- $pkg_manager github-desktop
                    if [[ $? -ne 0 ]]; then
                        gum format "⚠️ **RPM installation failed. Falling back to Flatpak...**"
                        gum spin --spinner dot --title "Installing GitHub Desktop via Flatpak..." -- $flatpak_cmd io.github.shiftey.Desktop
                        version="(Flatpak version installed)"
                    else
                        version=$(get_version github-desktop)
                    fi
                fi
                gum format "🎉 **GitHub Desktop installed successfully! Version: $version**"
                ;;

            "GitHub CLI")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing GitHub CLI..." -- $pkg_manager_pacman github-cli
                    version=$(get_version github-cli)
                else
                    gum spin --spinner dot --title "Installing GitHub CLI via DNF..." -- $pkg_manager gh
                    version=$(get_version gh)
                fi
                gum format "🎉 **GitHub CLI installed successfully! Version: $version**"
                ;;

            "Exit")
                break
                ;;
        esac
    done
}

install_thunarpreview() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_yay
        pkg_manager_aur="yay -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        pkg_manager="sudo dnf install -y"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${RESET}"
        return
    fi

    while true; do
        thunarpreview_choice=$(gum choose "Tumbler" "Exit")

        case $thunarpreview_choice in
            "Tumbler")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Tumbler..." -- $pkg_manager_aur tumbler
                else
                    gum spin --spinner dot --title "Installing Tumbler via DNF..." -- $pkg_manager tumbler
                fi
                version=$(get_version tumbler)
                gum format "🎉 **Tumbler installed successfully! Version: $version**"
                ;;

            "Exit")
                break
                ;;
        esac
    done
}

install_android() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_yay
        pkg_manager_aur="yay -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        pkg_manager="sudo dnf install -y"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${RESET}"
        return
    fi

    while true; do
        android_choice=$(gum choose "Gvfs-MTP [Displays Android phones via USB]" "ADB" "Exit")

        case $android_choice in
            "Gvfs-MTP [Displays Android phones via USB]")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Gvfs-MTP..." -- $pkg_manager_aur gvfs-mtp
                else
                    gum spin --spinner dot --title "Installing Gvfs-MTP via DNF..." -- $pkg_manager gvfs-mtp
                fi
                version=$(get_version gvfs-mtp)
                gum format "🎉 **Gvfs-MTP installed successfully! Version: $version**"
                ;;

            "ADB")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing ADB..." -- $pkg_manager_aur android-tools
                else
                    gum spin --spinner dot --title "Installing ADB via DNF..." -- $pkg_manager android-tools
                fi
                version=$(get_version android-tools)
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
    main_choice=$(gum choose "Communication & Chatting" "Live Streaming/Recording" "Editing" "Terminal" "Browsers" "File Managers" "Music" "Coding & Text Editor" "Multimedia" "Github" "Thunar [Thumbnail Preview]" "Android" "Exit")

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
        "Android") install_android ;;
        "Exit") exit ;;
    esac
done
