#!/bin/bash

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE="\e[34m"
ENDCOLOR="\e[0m"
RESET='\033[0m'

AUR_HELPER=""

detect_distro() {
    if [[ -f "/etc/os-release" ]]; then
        . /etc/os-release

        if [[ "$ID" == "arch" || "$ID_LIKE" == "arch" ]]; then
            echo -e "${GREEN}:: Arch-based system detected.${RESET}"
            return 0  
        elif [[ "$ID" == "fedora" || "$ID_LIKE" == "fedora" ]]; then
            echo -e "${YELLOW}:: Fedora-based system detected. Skipping AUR helper installation.${RESET}"
            return 1  
        else
            echo -e "${RED}:: Unsupported distribution detected. Proceeding cautiously...${RESET}"
            return 2  
        fi
    else
        echo -e "${RED}:: Unable to detect the distribution.${RESET}"
        return 2
    fi
}

detect_aur_helper() {
    for helper in paru yay trizen pacaur aurman; do
        if command -v $helper &>/dev/null; then
            AUR_HELPER=$helper
            echo -e "${GREEN}:: $helper detected and will be used as AUR helper.${RESET}"
            return 0
        fi
    done
    
    echo -e "${YELLOW}:: No AUR helper found.${RESET}"
    return 1
}

install_aur_helper() {
    detect_distro
    case $? in
        1) return ;; # Fedora - skip
        2) echo -e "${YELLOW}:: Proceeding, but AUR installation may not work properly.${RESET}" ;;
    esac

    detect_aur_helper
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}:: Using $AUR_HELPER as AUR helper.${RESET}"
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
    AUR_HELPER="yay"
    echo -e "${GREEN}:: Yay installed successfully and set as AUR helper.${RESET}"
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

install_android() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
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

install_browsers() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
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
        browser_choice=$(gum choose "Brave" "Firefox" "Libre Wolf" "Google Chrome" "Chromium" "Vivaldi" "Qute Browser" "Zen Browser" "Thorium Browser" "Opera" "Tor Browser" "Exit")

        case $browser_choice in
            "Brave")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Brave..." -- $pkg_manager_aur brave-bin
                    version=$(get_version brave-bin)
                else
                    gum format "🔄 **Setting up Brave repository...**"
                    sudo dnf install -y dnf-plugins-core
                    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
                    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
                    gum spin --spinner dot --title "Installing Brave via DNF..." -- $pkg_manager brave-browser
                    version=$(get_version brave-browser)
                fi
                gum format "🎉 **Brave installed successfully! Version: $version**"
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
                    gum format "🔄 **Setting up Google Chrome repository...**"
                    sudo dnf install -y dnf-plugins-core
                    sudo dnf config-manager --set-enabled google-chrome
                    gum spin --spinner dot --title "Installing Google Chrome via DNF..." -- $pkg_manager google-chrome-stable
                    version=$(get_version google-chrome-stable)
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
            "Vivaldi")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Vivaldi..." -- $pkg_manager_aur vivaldi
                    version=$(get_version vivaldi)
                else
                    gum format "🔄 **Setting up Vivaldi repository...**"
                    sudo dnf install -y dnf-utils
                    sudo dnf config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo
                    gum spin --spinner dot --title "Installing Vivaldi via DNF..." -- $pkg_manager vivaldi-stable
                    version=$(get_version vivaldi-stable)
                fi
                gum format "🎉 **Vivaldi installed successfully! Version: $version**"
                ;;
            "Opera")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Opera..." -- $pkg_manager_aur opera
                    version=$(get_version opera)
                else
                    gum format "🔄 **Setting up Opera repository...**"
                    sudo rpm --import https://rpm.opera.com/rpmrepo.key
                    echo -e "[opera]\nname=Opera packages\ntype=rpm-md\nbaseurl=https://rpm.opera.com/rpm\ngpgcheck=1\ngpgkey=https://rpm.opera.com/rpmrepo.key\nenabled=1" | sudo tee /etc/yum.repos.d/opera.repo
                    gum spin --spinner dot --title "Installing Opera via DNF..." -- $pkg_manager opera-stable
                    version=$(get_version opera-stable)
                fi
                gum format "🎉 **Opera installed successfully! Version: $version**"
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

install_communication() {
    detect_distro
    distro=$?
    
    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager="$AUR_HELPER -S --noconfirm"
    elif [[ $distro -eq 1 ]]; then
        install_flatpak
        pkg_manager="install_fedora_package"
    else
        echo -e "${RED}:: Unsupported system. Exiting.${RESET}"
        return
    fi

    while true; do
        comm_choice=$(gum choose "Discord" "Better Discord" "Signal" "Element (Matrix)" "Slack" "Teams" "Zoom" "Telegram" "Keybase" "Exit")

        case $comm_choice in
            "Discord")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Discord..." -- $pkg_manager discord
                    version=$(pacman -Qi discord | grep Version | awk '{print $3}')
                    gum format "🎉 **Discord installed successfully! Version: $version**"
                else
                    $pkg_manager "discord" "com.discordapp.Discord"
                    gum format "🎉 **Discord installed successfully!**"
                fi
                ;;
            "Better Discord")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Better Discord..." -- $pkg_manager betterdiscord-installer-bin
                    gum format "🎉 **Better Discord installed successfully!**"
                else
                    echo -e "${YELLOW}:: Better Discord is not available for Fedora.${RESET}"
                fi
                ;;
            "Signal")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Signal..." -- $pkg_manager signal-desktop
                    version=$(pacman -Qi signal-desktop | grep Version | awk '{print $3}')
                    gum format "🎉 **Signal installed successfully! Version: $version**"
                else
                    $pkg_manager "signal-desktop" "org.signal.Signal"
                    gum format "🎉 **Signal installed successfully!**"
                fi
                ;;
            "Element (Matrix)")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Element..." -- $pkg_manager_aur element-desktop
                    version=$(get_version element-desktop)
                else
                    gum spin --spinner dot --title "Installing Element via Flatpak..." -- $flatpak_cmd im.riot.Riot
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Element installed successfully! Version: $version**"
                ;;

            "Slack")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Slack..." -- $pkg_manager_aur slack-desktop
                    version=$(get_version slack-desktop)
                else
                    gum spin --spinner dot --title "Installing Slack via Flatpak..." -- $flatpak_cmd com.slack.Slack
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Slack installed successfully! Version: $version**"
                ;;
            "Teams")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Teams..." -- $pkg_manager_aur teams
                    version=$(get_version teams)
                    gum format "🎉 **Teams installed successfully! Version: $version**"
                else
                    gum format "🚀 **Microsoft Teams is not available in Fedora's repositories. Use the web version instead:** [**Teams Web**](https://teams.microsoft.com)"
                fi
                ;;
            "Zoom")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Zoom..." -- $pkg_manager_aur zoom
                    version=$(get_version zoom)
                else
                    gum spin --spinner dot --title "Installing Zoom via Flatpak..." -- $flatpak_cmd us.zoom.Zoom
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Zoom installed successfully! Version: $version**"
                ;;
            "Telegram")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Telegram..." -- $pkg_manager telegram-desktop
                    version=$(pacman -Qi telegram-desktop | grep Version | awk '{print $3}')
                    gum format "🎉 **Telegram installed successfully! Version: $version**"
                else
                    $pkg_manager "telegram-desktop" "org.telegram.desktop"
                    gum format "🎉 **Telegram installed successfully!**"
                fi
                ;;
            "Keybase")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Keybase..." -- $pkg_manager keybase-bin
                    version=$(pacman -Qi keybase-bin | grep Version | awk '{print $3}')
                    gum format "🎉 **Keybase installed successfully! Version: $version**"
                else
                    gum spin --spinner dot --title "Installing Keybase via RPM..." -- sudo dnf install -y https://prerelease.keybase.io/keybase_amd64.rpm
                    run_keybase
                    gum format "🎉 **Keybase installed successfully!**"
                fi
                ;;
            "Exit")
                break
                ;;
        esac
    done
}

install_development() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
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
        dev_choice=$(gum choose "Node.js" "Python" "Rust" "Go" "Docker" "Postman" "DBeaver" "Exit")

        case $dev_choice in
            "Node.js")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Node.js..." -- $pkg_manager_pacman nodejs npm
                    version=$(get_version nodejs)
                else
                    gum spin --spinner dot --title "Installing Node.js via DNF..." -- $pkg_manager nodejs-npm
                    version=$(get_version nodejs)
                fi
                gum format "🎉 **Node.js installed successfully! Version: $version**"
                ;;

            "Python")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Python..." -- $pkg_manager_pacman python python-pip
                    version=$(get_version python)
                else
                    gum spin --spinner dot --title "Installing Python via DNF..." -- $pkg_manager python3 python3-pip
                    version=$(get_version python3)
                fi
                gum format "🎉 **Python installed successfully! Version: $version**"
                ;;

            "Rust")
                gum spin --spinner dot --title "Installing Rust..." -- bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
                source "$HOME/.cargo/env"
                version=$(rustc --version | awk '{print $2}')
                gum format "🎉 **Rust installed successfully! Version: $version**"
                ;;

            "Go")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Go..." -- $pkg_manager_pacman go
                    version=$(get_version go)
                else
                    gum spin --spinner dot --title "Installing Go via DNF..." -- $pkg_manager golang
                    version=$(get_version golang)
                fi
                gum format "🎉 **Go installed successfully! Version: $version**"
                ;;

            "Docker")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Docker..." -- $pkg_manager_pacman docker
                    sudo systemctl enable --now docker
                    sudo usermod -aG docker "$USER"
                    version=$(get_version docker)
                else
                    gum spin --spinner dot --title "Installing Docker via DNF..." -- $pkg_manager docker
                    sudo systemctl enable --now docker
                    sudo usermod -aG docker "$USER"
                    version=$(get_version docker)
                fi
                gum format "🎉 **Docker installed successfully! Version: $version**"
                gum format "⚠️ **Note:** You may need to log out and back in for group changes to take effect."
                ;;

            "Postman")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Postman..." -- $pkg_manager_aur postman-bin
                    version=$(get_version postman-bin)
                else
                    gum spin --spinner dot --title "Installing Postman via Flatpak..." -- $flatpak_cmd com.getpostman.Postman
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Postman installed successfully! Version: $version**"
                ;;

            "DBeaver")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing DBeaver..." -- $pkg_manager_pacman dbeaver
                    version=$(get_version dbeaver)
                else
                    gum spin --spinner dot --title "Installing DBeaver via Flatpak..." -- $flatpak_cmd io.dbeaver.DBeaverCommunity
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **DBeaver installed successfully! Version: $version**"
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
        edit_choice=$(gum choose "GIMP (Image)" "Kdenlive (Videos)" "Krita" "Blender" "Inkscape" "Audacity" "DaVinci Resolve" "Exit")

        case $edit_choice in
            "GIMP (Image)")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing GIMP..." -- $pkg_manager gimp
                    version=$(pacman -Qi gimp | grep Version | awk '{print $3}')
                else
                    gum spin --spinner dot --title "Installing GIMP..." -- $pkg_manager gimp
                    version=$(rpm -q gimp)
                fi
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
            "Krita")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Krita..." -- $pkg_manager_aur krita
                    version=$(get_version krita)
                else
                    gum spin --spinner dot --title "Installing Krita via DNF..." -- $pkg_manager krita
                    version=$(get_version krita)
                fi
                gum format "🎉 **Krita installed successfully! Version: $version**"
                ;;

            "Blender")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Blender..." -- $pkg_manager_aur blender
                    version=$(get_version blender)
                else
                    gum spin --spinner dot --title "Installing Blender via DNF..." -- $pkg_manager blender
                    version=$(get_version blender)
                fi
                gum format "🎉 **Blender installed successfully! Version: $version**"
                ;;

            "Inkscape")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Inkscape..." -- $pkg_manager_aur inkscape
                    version=$(get_version inkscape)
                else
                    gum spin --spinner dot --title "Installing Inkscape via DNF..." -- $pkg_manager inkscape
                    version=$(get_version inkscape)
                fi
                gum format "🎉 **Inkscape installed successfully! Version: $version**"
                ;;

            "Audacity")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Audacity..." -- $pkg_manager_aur audacity
                    version=$(get_version audacity)
                else
                    gum spin --spinner dot --title "Installing Audacity via DNF..." -- $pkg_manager audacity
                    version=$(get_version audacity)
                fi
                gum format "🎉 **Audacity installed successfully! Version: $version**"
                ;;

            "DaVinci Resolve")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing DaVinci Resolve..." -- $pkg_manager_aur davinci-resolve
                    version=$(get_version davinci-resolve)
                else
                    gum format "📝 **DaVinci Resolve is not directly available in Fedora repositories.**"
                    gum format "🔗 **Download from:** [Blackmagic Design Website](https://www.blackmagicdesign.com/products/davinciresolve/)"
                    version="(Manual installation required)"
                fi
                gum format "🎉 **DaVinci Resolve installation completed! Version: $version**"
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
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Nemo..." -- $pkg_manager nemo
                else
                    gum spin --spinner dot --title "Installing Nemo..." -- $pkg_manager nemo
                fi
                version=$(get_version nemo)
                gum format "🎉 **Nemo installed successfully! Version: $version**"
                ;;

            "Thunar")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Thunar..." -- $pkg_manager thunar
                else
                    gum spin --spinner dot --title "Installing Thunar..." -- $pkg_manager thunar
                fi
                version=$(get_version thunar)
                gum format "🎉 **Thunar installed successfully! Version: $version**"
                ;;

            "Dolphin")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Dolphin..." -- $pkg_manager dolphin
                else
                    gum spin --spinner dot --title "Installing Dolphin..." -- $pkg_manager dolphin
                fi
                version=$(get_version dolphin)
                gum format "🎉 **Dolphin installed successfully! Version: $version**"
                ;;

            "LF (Terminal File Manager)")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing LF..." -- $pkg_manager lf
                else
                    gum spin --spinner dot --title "Enabling LF COPR repository..." -- sudo dnf copr enable lsevcik/lf -y
                    gum spin --spinner dot --title "Installing LF..." -- $pkg_manager lf
                fi
                version=$(get_version lf)
                gum format "🎉 **LF installed successfully! Version: $version**"
                ;;

            "Ranger")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Ranger..." -- $pkg_manager ranger
                else
                    gum spin --spinner dot --title "Installing Ranger..." -- $pkg_manager ranger
                fi
                version=$(get_version ranger)
                gum format "🎉 **Ranger installed successfully! Version: $version**"
                ;;

            "Nautilus")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Nautilus..." -- $pkg_manager nautilus
                else
                    gum spin --spinner dot --title "Installing Nautilus..." -- $pkg_manager nautilus
                fi
                version=$(get_version nautilus)
                gum format "🎉 **Nautilus installed successfully! Version: $version**"
                ;;

            "Yazi")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Yazi..." -- $pkg_manager yazi
                else
                    gum spin --spinner dot --title "Adding Yazi repository..." -- sudo dnf copr enable varlad/yazi -y
                    gum spin --spinner dot --title "Installing Yazi..." -- $pkg_manager yazi
                fi
                version=$(get_version yazi)
                gum format "🎉 **Yazi installed successfully! Version: $version**"
                ;;

            "Exit")
                break
                ;;
        esac
    done
}

install_gaming() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
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

    while true; 
        do
        gaming_choice=$(gum choose "Steam" "Lutris" "Heroic Games Launcher" "ProtonUp-Qt" "MangoHud" "GameMode" "Exit")

        case $gaming_choice in
            "Steam")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Steam..." -- $pkg_manager_pacman steam
                    version=$(get_version steam)
                else
                    gum spin --spinner dot --title "Installing Steam via Flatpak..." -- $flatpak_cmd com.valvesoftware.Steam
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Steam installed successfully! Version: $version**"
                ;;

            "Lutris")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Lutris..." -- $pkg_manager_pacman lutris
                    version=$(get_version lutris)
                else
                    gum spin --spinner dot --title "Installing Lutris via DNF..." -- $pkg_manager lutris
                    version=$(get_version lutris)
                fi
                gum format "🎉 **Lutris installed successfully! Version: $version**"
                ;;

            "Heroic Games Launcher")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Heroic Games Launcher..." -- $pkg_manager_aur heroic-games-launcher-bin
                    version=$(get_version heroic-games-launcher-bin)
                else
                    gum spin --spinner dot --title "Installing Heroic Games Launcher via Flatpak..." -- $flatpak_cmd com.heroicgameslauncher.hgl
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Heroic Games Launcher installed successfully! Version: $version**"
                ;;

            "ProtonUp-Qt")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing ProtonUp-Qt..." -- $pkg_manager_aur protonup-qt-bin
                    version=$(get_version protonup-qt-bin)
                else
                    gum spin --spinner dot --title "Installing ProtonUp-Qt via Flatpak..." -- $flatpak_cmd net.davidotek.pupgui2
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **ProtonUp-Qt installed successfully! Version: $version**"
                ;;

            "MangoHud")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing MangoHud..." -- $pkg_manager_pacman mangohud
                    version=$(get_version mangohud)
                else
                    gum spin --spinner dot --title "Installing MangoHud via DNF..." -- $pkg_manager mangohud
                    version=$(get_version mangohud)
                fi
                gum format "🎉 **MangoHud installed successfully! Version: $version**"
                ;;

            "GameMode")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing GameMode..." -- $pkg_manager_pacman gamemode
                    version=$(get_version gamemode)
                else
                    gum spin --spinner dot --title "Installing GameMode via DNF..." -- $pkg_manager gamemode
                    version=$(get_version gamemode)
                fi
                gum format "🎉 **GameMode installed successfully! Version: $version**"
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
        install_aur_helper
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
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

install_multimedia() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
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

install_music() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager="$AUR_HELPER -S --noconfirm"
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
                else
                    gum spin --spinner dot --title "Installing Youtube-Music via Flatpak..." -- flatpak install -y flathub app.ytmdesktop.ytmdesktop
                    version="Flatpak Version"
                fi
                gum format "🎉 **Youtube-Music installed successfully! Version: $version**"
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

install_productivity() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
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
        productivity_choice=$(gum choose "LibreOffice" "OnlyOffice" "Obsidian" "Joplin" "Calibre" "Exit")

        case $productivity_choice in
            "LibreOffice")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing LibreOffice..." -- $pkg_manager_pacman libreoffice-fresh
                    version=$(get_version libreoffice-fresh)
                else
                    gum spin --spinner dot --title "Installing LibreOffice via DNF..." -- $pkg_manager libreoffice
                    version=$(get_version libreoffice)
                fi
                gum format "🎉 **LibreOffice installed successfully! Version: $version**"
                ;;

            "OnlyOffice")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing OnlyOffice..." -- $pkg_manager_aur onlyoffice-bin
                    version=$(get_version onlyoffice-bin)
                else
                    gum spin --spinner dot --title "Installing OnlyOffice via Flatpak..." -- $flatpak_cmd org.onlyoffice.desktopeditors
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **OnlyOffice installed successfully! Version: $version**"
                ;;

            "Obsidian")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Obsidian..." -- $pkg_manager_aur obsidian
                    version=$(get_version obsidian)
                else
                    gum spin --spinner dot --title "Installing Obsidian via Flatpak..." -- $flatpak_cmd md.obsidian.Obsidian
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Obsidian installed successfully! Version: $version**"
                ;;

            "Joplin")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Joplin..." -- $pkg_manager_aur joplin-desktop
                    version=$(get_version joplin-desktop)
                else
                    gum spin --spinner dot --title "Installing Joplin via Flatpak..." -- $flatpak_cmd net.cozic.joplin_desktop
                    version="(Flatpak version installed)"
                fi
                gum format "🎉 **Joplin installed successfully! Version: $version**"
                ;;

            "Calibre")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Calibre..." -- $pkg_manager_pacman calibre
                    version=$(get_version calibre)
                else
                    gum spin --spinner dot --title "Installing Calibre via DNF..." -- $pkg_manager calibre
                    version=$(get_version calibre)
                fi
                gum format "🎉 **Calibre installed successfully! Version: $version**"
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
        install_aur_helper
        pkg_manager_pacman="sudo pacman -S --noconfirm"
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        pkg_manager="sudo dnf install -y"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${RESET}"
        return
    fi

    while true; do
        stream_choice=$(gum choose "OBS Studio" "SimpleScreenRecorder [Git]" "Exit")

        case $stream_choice in
            "OBS Studio")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing OBS Studio..." -- $pkg_manager_pacman obs-studio
                    version=$(get_version obs-studio)
                else
                    gum spin --spinner dot --title "Installing OBS Studio via DNF..." -- $pkg_manager obs-studio
                    version=$(get_version obs-studio)
                fi
                gum format "🎉 **OBS Studio installed successfully! Version: $version**"
                ;;

            "SimpleScreenRecorder [Git]")
                if [[ $distro -eq 0 ]]; then
                    gum confirm "The Git version builds from source and may take some time. Proceed?" && \
                    gum spin --spinner dot --title "Installing SimpleScreenRecorder [Git]..." -- $pkg_manager_aur simplescreenrecorder-git
                    version=$(get_version simplescreenrecorder-git)
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

install_terminals() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager="sudo pacman -S --noconfirm"
        aur_manager="$AUR_HELPER -S --noconfirm"
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

        terminal_choice=$(gum choose "Alacritty" "Kitty" "Terminator" "Tilix" "Hyper" "GNOME Terminal" "Konsole" "WezTerm" "Ghostty" "Exit")

        case $terminal_choice in
            "Alacritty")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Alacritty..." -- $pkg_manager alacritty
                else
                    gum spin --spinner dot --title "Installing Alacritty via DNF..." -- $pkg_manager alacritty
                fi
                    version=$(get_version alacritty)
                    gum format "🎉 **Alacritty installed successfully! Version: $version**"
                ;;
            "Kitty")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Kitty..." -- $pkg_manager kitty
                else
                    gum spin --spinner dot --title "Installing Kitty via DNF..." -- $pkg_manager kitty
                fi
                    version=$(get_version kitty)
                    gum format "🎉 **Kitty installed successfully! Version: $version**"
                ;;
            "Terminator")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Terminator..." -- $pkg_manager_aur terminator
                    version=$(get_version terminator)
                else
                    gum spin --spinner dot --title "Installing Terminator via DNF..." -- $pkg_manager terminator
                    version=$(get_version terminator)
                fi
                gum format "🎉 **Terminator installed successfully! Version: $version**"
                ;;
            "Tilix")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Tilix..." -- $pkg_manager_aur tilix
                    version=$(get_version tilix)
                else
                    gum spin --spinner dot --title "Installing Tilix via DNF..." -- $pkg_manager tilix
                    version=$(get_version tilix)
                fi
                gum format "🎉 **Tilix installed successfully! Version: $version**"
                ;;
            "Hyper")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Hyper..." -- $pkg_manager_aur hyper
                    version=$(get_version hyper)
                else
                    gum format "📝 **Hyper is not directly available in Fedora repositories.**"
                    gum format "🔗 **Download from:** [Hyper Website](https://hyper.is/)"
                    version="(Manual installation required)"
                fi
                gum format "🎉 **Hyper installation completed! Version: $version**"
                ;;
            "GNOME Terminal")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing GNOME Terminal..." -- $pkg_manager gnome-terminal
                else
                    gum spin --spinner dot --title "Installing GNOME Terminal via DNF..." -- $pkg_manager gnome-terminal
                fi
                    version=$(get_version gnome-terminal)
                    gum format "🎉 **GNOME Terminal installed successfully! Version: $version**"
                ;;
            "Konsole")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Konsole..." -- $pkg_manager konsole
                else
                    gum spin --spinner dot --title "Installing Konsole via DNF..." -- $pkg_manager konsole
                fi
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

install_texteditor() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
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

install_thunarpreview() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
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

install_virtualization() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        pkg_manager="sudo dnf install -y"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${RESET}"
        return
    fi

    while true; do
        virt_choice=$(gum choose "QEMU/KVM" "VirtualBox" "Distrobox" "Exit")

        case $virt_choice in
            "QEMU/KVM")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing QEMU/KVM..." -- $pkg_manager_pacman qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat ebtables iptables-nft libguestfs
                    sudo systemctl enable --now libvirtd.service
                    sudo usermod -aG libvirt "$USER"
                    version=$(get_version qemu)
                else
                    gum spin --spinner dot --title "Installing QEMU/KVM..." -- $pkg_manager @virtualization
                    sudo systemctl enable --now libvirtd
                    sudo usermod -aG libvirt "$USER"
                    version=$(get_version qemu-kvm)
                fi
                gum format "🎉 **QEMU/KVM installed successfully! Version: $version**"
                gum format "⚠️ **Note:** You may need to log out and back in for group changes to take effect."
                ;;

            "VirtualBox")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing VirtualBox..." -- $pkg_manager_pacman virtualbox virtualbox-host-dkms
                    sudo usermod -aG vboxusers "$USER"
                    sudo modprobe vboxdrv
                    version=$(get_version virtualbox)
                else
                    gum spin --spinner dot --title "Installing Boxes..." -- $pkg_manager gnome-boxes
                    version=$(get_version gnome-boxes)
                fi
                gum format "🎉 **VirtualBox installed successfully! Version: $version**"
                gum format "⚠️ **Note:** You may need to log out and back in for group changes to take effect."
                ;;

            "Distrobox")
                if [[ $distro -eq 0 ]]; then
                    gum spin --spinner dot --title "Installing Distrobox..." -- $pkg_manager_pacman distrobox
                    version=$(get_version distrobox)
                else
                    gum spin --spinner dot --title "Installing Distrobox..." -- $pkg_manager distrobox
                    version=$(get_version distrobox)
                fi
                gum format "🎉 **Distrobox installed successfully! Version: $version**"
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
    main_choice=$(gum choose "Android Tools" "Browsers" "Communication Apps" "Development Tools" "Editing Tools" "File Managers" "Gaming" "GitHub" "Multimedia" "Music Apps" "Productivity Apps" "Streaming Tools" "Terminals" "Text Editors" "Thunar Preview" "Virtualization" "Exit")

    case $main_choice in
        "Android Tools") install_android ;;
        "Browsers") install_browsers ;;
        "Communication Apps") install_communication ;;
        "Development Tools") install_development ;;
        "Editing Tools") install_editing ;;
        "File Managers") install_filemanagers ;;
        "Gaming") install_gaming ;;
        "GitHub") install_github ;;
        "Multimedia") install_multimedia ;;
        "Music Apps") install_music ;;
        "Productivity Apps") install_productivity ;;
        "Streaming Tools") install_streaming ;;
        "Terminals") install_terminals ;;
        "Text Editors") install_texteditor ;;
        "Thunar Preview") install_thunarpreview ;;
        "Virtualization") install_virtualization ;;
        "Exit") exit ;;
    esac
done
