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
        1) return ;; 
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
        clear
        figlet -f slant "Android"
        echo -e "${YELLOW}--------------------------------------${RESET}"
        echo "Select a Android tool to install:"

        options=("Gvfs-MTP [Displays Android phones via USB]" "ADB" "Exit")
        selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=15 --layout=reverse --border)

        case $selected in
            "Gvfs-MTP [Displays Android phones via USB]")
                clear
                figlet -f small "Installing Gvfs-MTP"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur gvfs-mtp
                    version=$(get_version gvfs-mtp)
                else
                    $pkg_manager gvfs-mtp
                    version=$(get_version gvfs-mtp)
                fi
                echo "Gvfs-MTP installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "ADB")
                clear
                figlet -f small "Installing ADB"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur android-tools
                    version=$(get_version android-tools)
                else
                    $pkg_manager android-tools
                    version=$(get_version android-tools)
                fi
                echo "ADB installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
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
        clear
        figlet -f slant "Browser"
        echo -e "${YELLOW}--------------------------------------${RESET}"
        echo "Select a Browser tool to install:"

        options=("Brave" "Firefox" "Libre Wolf" "Google Chrome" "Chromium" "Vivaldi" "Qute Browser" "Zen Browser" "Thorium Browser" "Opera" "Tor Browser" "Exit")
        selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=15 --layout=reverse --border)

         case $selected in
            "Brave")
                clear
                figlet -f small "Installing Brave"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur brave-bin
                    version=$(get_version brave-bin)
                else
                    echo "Setting up Brave repository..."
                    sudo dnf install -y dnf-plugins-core
                    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
                    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
                    $pkg_manager brave-browser
                    version=$(get_version brave-browser)
                fi
                echo "Brave installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Firefox")
                clear
                figlet -f small "Installing Firefox"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman firefox
                    version=$(get_version firefox)
                else
                    $pkg_manager firefox
                    version=$(get_version firefox)
                fi
                echo "Firefox installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Libre Wolf")
                clear
                figlet -f small "Installing Libre Wolf"             
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur librewolf-bin
                    version=$(get_version librewolf-bin)
                else
                    $flatpak_cmd io.gitlab.librewolf-community
                    version="(Flatpak version installed)"
                fi
                echo "Libre Wolf installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Google Chrome")
                clear
                figlet -f small "Installing Chrome"  
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur google-chrome
                    version=$(get_version google-chrome)
                else
                    echo "Setting up Google Chrome repository..."
                    sudo dnf install -y dnf-plugins-core
                    sudo dnf config-manager --set-enabled google-chrome
                    $pkg_manager google-chrome-stable
                    version=$(get_version google-chrome-stable)
                fi
                echo "Google Chrome installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Chromium")
                clear
                figlet -f small "Installing Chromium"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman chromium
                    version=$(get_version chromium)
                else
                    $flatpak_cmd org.chromium.Chromium
                    version="(Flatpak version installed)"
                fi
                echo "Chromium installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Vivaldi")
                clear
                figlet -f small "Installing Vivaldi"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman vivaldi
                    version=$(get_version vivaldi)
                else
                    $flatpak_cmd com.vivaldi.Vivaldi
                    version="(Flatpak version installed)"
                fi
                echo "Vivaldi installed successfully! Version: $version"
                read -rp "Press enter to continue..."
                ;;

            "Qute Browser")
                clear
                figlet -f small "Installing Qute"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman qutebrowser
                    version=$(get_version qutebrowser)
                else
                    $flatpak_cmd org.qutebrowser.qutebrowser
                    version="(Flatpak version installed)"
                fi
                echo "Qute Browser installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Zen Browser")
                clear
                figlet -f small "Installing Zen"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur zen-browser-bin
                    version=$(get_version zen-browser-bin)
                else
                    $flatpak_cmd app.zen_browser.zen
                    version="(Flatpak version installed)"
                fi
                echo "Zen Browser installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Thorium Browser")
                clear
                figlet -f small "Installing Thorium"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur thorium-browser-bin
                    version=$(get_version thorium-browser-bin)
                    echo "Thorium Browser installed successfully! Version: $version"
                else
                    echo "Thorium Browser is not available on Fedora repositories or Flatpak. Visit [Thorium Website](https://thorium.rocks/) for installation instructions."
                fi
                read -rp "Press Enter to continue..."
                ;;

            "Opera")
                clear
                figlet -f small "Installing Opera"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur opera
                    version=$(get_version opera)
                else
                    echo "Setting up Opera repository..."
                    sudo rpm --import https://rpm.opera.com/rpmrepo.key
                    echo -e "[opera]\nname=Opera packages\ntype=rpm-md\nbaseurl=https://rpm.opera.com/rpm\ngpgcheck=1\ngpgkey=https://rpm.opera.com/rpmrepo.key\nenabled=1" | sudo tee /etc/yum.repos.d/opera.repo
                    $pkg_manager opera-stable
                    version=$(get_version opera-stable)
                fi
                echo "Opera installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Tor Browser")
                clear
                figlet -f small "Installing Opera"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur tor-browser-bin
                    version=$(get_version tor-browser-bin)
                else
                    $flatpak_cmd org.torproject.torbrowser-launcher
                    version="(Flatpak version installed)"
                fi
                echo "Tor Browser installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
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
        clear
        figlet -f slant "Communication"
        echo -e "${YELLOW}--------------------------------------${RESET}"
        echo "Select a Communication App to install:"

        options=("Discord" "Better Discord" "Signal" "Element (Matrix)" "Slack" "Teams" "Zoom" "Telegram" "Keybase" "Exit")
        selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=15 --layout=reverse --border)

        case $selected in
            "Discord")
                clear
                figlet -f small "Installing Discord" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager discord
                    version=$(pacman -Qi discord | grep Version | awk '{print $3}')
                    echo "Discord installed successfully! Version: $version"
                else
                    $pkg_manager "discord" "com.discordapp.Discord"
                    echo "Discord installed successfully!"
                fi
                read -rp "Press Enter to continue..."
                ;;

            "Better Discord")
                clear
                figlet -f small "Installing Better Discord"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager betterdiscord-installer-bin
                    echo "Better Discord installed successfully!"
                else
                    echo -e "${YELLOW}:: Better Discord is not available for Fedora.${RESET}"
                fi
                read -rp "Press Enter to continue..."
                ;;

            "Signal")
                clear
                figlet -f small "Installing Signal" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager signal-desktop
                    version=$(pacman -Qi signal-desktop | grep Version | awk '{print $3}')
                    echo "Signal installed successfully! Version: $version"
                else
                    $pkg_manager "signal-desktop" "org.signal.Signal"
                    echo "Signal installed successfully!"
                fi
                read -rp "Press Enter to continue..."
                ;;

            "Element (Matrix)")
                clear
                figlet -f small "Installing Element" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur element-desktop
                    version=$(get_version element-desktop)
                else
                    $flatpak_cmd im.riot.Riot
                    version="(Flatpak version installed)"
                fi
                echo "Element installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Slack")
                clear
                figlet -f small "Installing Slack" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur slack-desktop
                    version=$(get_version slack-desktop)
                else
                    $flatpak_cmd com.slack.Slack
                    version="(Flatpak version installed)"
                fi
                echo "Slack installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Teams")
                clear
                figlet -f small "Installing Teams" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur teams
                    version=$(get_version teams)
                    echo "Teams installed successfully! Version: $version"
                else
                    echo "Microsoft Teams is not available in Fedora's repositories. Use the web version instead:** [**Teams Web**](https://teams.microsoft.com)"
                fi
                read -rp "Press Enter to continue..."
                ;;

            "Zoom")
                clear
                figlet -f small "Installing Zoom" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur zoom
                    version=$(get_version zoom)
                else
                    $flatpak_cmd us.zoom.Zoom
                    version="(Flatpak version installed)"
                fi
                echo "Zoom installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Telegram")
                clear
                figlet -f small "Installing Telegram" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager telegram-desktop
                    version=$(pacman -Qi telegram-desktop | grep Version | awk '{print $3}')
                    echo "Telegram installed successfully! Version: $version"
                else
                    $pkg_manager "telegram-desktop" "org.telegram.desktop"
                    echo "Telegram installed successfully!"
                fi
                read -rp "Press Enter to continue..."
                ;;

            "Keybase")
                clear
                figlet -f small "Installing Keybase" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager keybase-bin
                    version=$(pacman -Qi keybase-bin | grep Version | awk '{print $3}')
                    echo "Keybase installed successfully! Version: $version"
                else
                    sudo dnf install -y https://prerelease.keybase.io/keybase_amd64.rpm
                    echo "Keybase installed successfully!"
                fi
                read -rp "Press Enter to continue..."
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
        clear
        figlet -f slant "Development"
        echo -e "${YELLOW}--------------------------------------${RESET}"
        echo "Select a development tool to install:"
        
        options=("Node.js" "Python" "Rust" "Go" "Docker" "Postman" "DBeaver" "Hugo" "Exit")
        selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=15 --layout=reverse --border)
        
        case $selected in
            "Node.js")
                clear
                figlet -f small "Installing Node.js"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman nodejs npm
                    version=$(get_version nodejs)
                else
                    $pkg_manager nodejs-npm
                    version=$(get_version nodejs)
                fi
                echo "Node.js installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Python")
                clear
                figlet -f small "Installing Python"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman python python-pip
                    version=$(get_version python)
                else
                    $pkg_manager python3 python3-pip
                    version=$(get_version python3)
                fi
                echo "Python installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Rust")
                clear
                figlet -f small "Installing Rust"
                bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
                source "$HOME/.cargo/env"
                version=$(rustc --version | awk '{print $2}')
                echo "Rust installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Go")
                clear
                figlet -f small "Installing Go"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman go
                    version=$(get_version go)
                else
                    $pkg_manager golang
                    version=$(get_version golang)
                fi
                echo "Go installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Docker")
                clear
                figlet -f small "Installing Docker"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman docker
                    sudo systemctl enable --now docker
                    sudo usermod -aG docker "$USER"
                    version=$(get_version docker)
                else
                    $pkg_manager docker
                    sudo systemctl enable --now docker
                    sudo usermod -aG docker "$USER"
                    version=$(get_version docker)
                fi
                echo "Docker installed successfully! Version: $version"
                echo "Note: You may need to log out and back in for group changes to take effect."
                read -rp "Press Enter to continue..."
                ;;

            "Postman")
                clear
                figlet -f small "Installing Postman"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur postman-bin
                    version=$(get_version postman-bin)
                else
                    $flatpak_cmd com.getpostman.Postman
                    version="(Flatpak version installed)"
                fi
                echo "Postman installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "DBeaver")
                clear
                figlet -f small "Installing DBeaver"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman dbeaver
                    version=$(get_version dbeaver)
                else
                    $flatpak_cmd io.dbeaver.DBeaverCommunity
                    version="(Flatpak version installed)"
                fi
                echo "DBeaver installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Hugo")
                clear
                figlet -f small "Installing Hugo"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman hugo
                    version=$(get_version hugo)
                else
                    $pkg_manager hugo
                    version=$(get_version hugo)
                fi
                echo "Hugo installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Exit"|"")
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
        clear
        figlet -f slant "Editing"
        echo -e "${YELLOW}--------------------------------------${RESET}"
        echo "Select a Editing tool to install:"

        options=("GIMP (Image)" "Kdenlive (Videos)" "Krita" "Blender" "Inkscape" "Audacity" "DaVinci Resolve" "Exit")
        selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=15 --layout=reverse --border)

        case $selected in
            "GIMP (Image)")
                clear
                figlet -f small "Installing Gimp"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager gimp
                    version=$(pacman -Qi gimp | grep Version | awk '{print $3}')
                else
                    $pkg_manager gimp
                    version=$(rpm -q gimp)
                fi
                echo "GIMP installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Kdenlive (Videos)")
                clear
                figlet -f small "Installing Kdenlive"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager kdenlive
                    version=$(pacman -Qi kdenlive | grep Version | awk '{print $3}')
                    echo "Kdenlive installed successfully! Version: $version"
                else
                    $pkg_manager kdenlive
                    version=$(rpm -q kdenlive)
                    echo "Kdenlive installed successfully! Version: $version"
                fi
                read -rp "Press Enter to continue..."
                ;;

            "Krita")
                clear
                figlet -f small "Installing Krita"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur krita
                    version=$(get_version krita)
                else
                    $pkg_manager krita
                    version=$(get_version krita)
                fi
                echo "Krita installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Blender")
                clear
                figlet -f small "Installing Krita"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur blender
                    version=$(get_version blender)
                else
                    $pkg_manager blender
                    version=$(get_version blender)
                fi
                echo "Blender installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Inkscape")
                clear
                figlet -f small "Installing Inkscape"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur inkscape
                    version=$(get_version inkscape)
                else
                    $pkg_manager inkscape
                    version=$(get_version inkscape)
                fi
                echo "Inkscape installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Audacity")
                clear
                figlet -f small "Installing Audacity"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur audacity
                    version=$(get_version audacity)
                else
                    $pkg_manager audacity
                    version=$(get_version audacity)
                fi
                echo "Audacity installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "DaVinci Resolve")
                clear
                figlet -f small "Installing DaVinci Resolve"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur davinci-resolve
                    version=$(get_version davinci-resolve)
                else
                    echo "DaVinci Resolve is not directly available in Fedora repositories."
                    echo "Download from: [Blackmagic Design Website](https://www.blackmagicdesign.com/products/davinciresolve/)"
                    version="(Manual installation required)"
                fi
                echo "DaVinci Resolve installation completed! Version: $version"
                read -rp "Press Enter to continue..."
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
        clear
        figlet -f slant "Filemanagers"
        echo -e "${YELLOW}--------------------------------------${RESET}"
        echo "Select a Filemanagers Apps to install:"

        options=("Nemo" "Thunar" "Dolphin" "LF (Terminal File Manager)" "Ranger" "Nautilus" "Yazi" "Exit")
        selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=15 --layout=reverse --border)

        case $selected in
            "Nemo")
                clear
                figlet -f small "Installing Nemo"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager nemo
                else
                    $pkg_manager nemo
                fi
                version=$(get_version nemo)
                echo "Nemo installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Thunar")
                clear
                figlet -f small "Installing Thunar" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager thunar
                else
                    $pkg_manager thunar
                fi
                version=$(get_version thunar)
                echo "Thunar installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Dolphin")
                clear
                figlet -f small "Installing Thunar" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager dolphin
                else
                    $pkg_manager dolphin
                fi
                version=$(get_version dolphin)
                echo "Dolphin installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "LF (Terminal File Manager)")
                clear
                figlet -f small "Installing LF" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager lf
                else
                    sudo dnf copr enable lsevcik/lf -y
                    $pkg_manager lf
                fi
                version=$(get_version lf)
                echo "LF installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Ranger")
                clear
                figlet -f small "Installing Ranger" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager ranger
                else
                    $pkg_manager ranger
                fi
                version=$(get_version ranger)
                echo "Ranger installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Nautilus")
                clear
                figlet -f small "Installing Nautilus" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager nautilus
                else
                    $pkg_manager nautilus
                fi
                version=$(get_version nautilus)
                echo "Nautilus installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Yazi")
                clear
                figlet -f small "Installing Yazi" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager yazi
                else
                    sudo dnf copr enable varlad/yazi -y
                    $pkg_manager yazi
                fi
                version=$(get_version yazi)
                echo "Yazi installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
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

    while true; do
        clear
        figlet -f slant "Gaming"
        echo -e "${YELLOW}--------------------------------------${RESET}"
        echo "Select a Gaming Platform to install:"

        options=("Steam" "Lutris" "Heroic Games Launcher" "ProtonUp-Qt" "MangoHud" "GameMode" "Exit")
        selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=15 --layout=reverse --border)

        case $selected in
            "Steam")
                clear
                figlet -f small "Installing Steam"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman steam
                    version=$(get_version steam)
                else
                    $flatpak_cmd com.valvesoftware.Steam
                    version="(Flatpak version installed)"
                fi
                echo "Steam installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Lutris")
                clear
                figlet -f small "Installing Lutris"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman lutris
                    version=$(get_version lutris)
                else
                    $pkg_manager lutris
                    version=$(get_version lutris)
                fi
                echo "Lutris installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Heroic Games Launcher")
                clear
                figlet -f small "Installing Launcher"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur heroic-games-launcher-bin
                    version=$(get_version heroic-games-launcher-bin)
                else
                    $flatpak_cmd com.heroicgameslauncher.hgl
                    version="(Flatpak version installed)"
                fi
                echo "Heroic Games Launcher installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "ProtonUp-Qt")
                clear
                figlet -f small "Installing ProtonUp-Qt"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur protonup-qt-bin
                    version=$(get_version protonup-qt-bin)
                else
                    $flatpak_cmd net.davidotek.pupgui2
                    version="(Flatpak version installed)"
                fi
                echo "ProtonUp-Qt installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "MangoHud")
                clear
                figlet -f small "Installing MangoHud"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman mangohud
                    version=$(get_version mangohud)
                else
                    $pkg_manager mangohud
                    version=$(get_version mangohud)
                fi
                echo "MangoHud installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "GameMode")
                clear
                figlet -f small "Installing GameMode"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman gamemode
                    version=$(get_version gamemode)
                else
                    $pkg_manager gamemode
                    version=$(get_version gamemode)
                fi
                echo "GameMode installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
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
        clear
        figlet -f slant "Git"
        echo -e "${YELLOW}--------------------------------------${RESET}"
        echo "Select a Git tool to install:"
        
        options=("Git" "GitHub Desktop" "GitHub CLI" "Exit")
        selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=15 --layout=reverse --border)

        case $selected in
            "Git")
                clear
                figlet -f small "Installing Git"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur git
                    version=$(get_version git)
                else
                    $pkg_manager git
                    version=$(get_version git)
                fi
                echo "Git installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "GitHub Desktop")
                clear
                figlet -f small "Installing Github-Desktop"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur github-desktop-bin
                    version=$(get_version github-desktop-bin)
                else
                    echo "Setting up GitHub Desktop repository..."
                    sudo dnf upgrade --refresh
                    sudo rpm --import https://rpm.packages.shiftkey.dev/gpg.key
                    echo -e "[shiftkey-packages]\nname=GitHub Desktop\nbaseurl=https://rpm.packages.shiftkey.dev/rpm/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://rpm.packages.shiftkey.dev/gpg.key" | sudo tee /etc/yum.repos.d/shiftkey-packages.repo > /dev/null

                    $pkg_manager github-desktop
                    if [[ $? -ne 0 ]]; then
                        echo "RPM installation failed. Falling back to Flatpak..."
                        $flatpak_cmd io.github.shiftey.Desktop
                        version="(Flatpak version installed)"
                    else
                        version=$(get_version github-desktop)
                    fi
                fi
                echo "GitHub Desktop installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "GitHub CLI")
                clear
                figlet -f small "Installing Git-Cli"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman github-cli
                    version=$(get_version github-cli)
                else
                    $pkg_manager gh
                    version=$(get_version gh)
                fi
                echo "GitHub CLI installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
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
        clear
        figlet -f slant "Multimedia"
        echo -e "${YELLOW}--------------------------------------${RESET}"
        echo "Select a Multimedia Packages to install:"

        options=("VLC" "Netflix [Unofficial]" "Exit")
        selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=15 --layout=reverse --border)

        case $selected in
            "VLC")
                clear
                figlet -f small "Installing VLC"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur vlc
                    version=$(get_version vlc)
                else
                    $pkg_manager vlc
                    version=$(get_version vlc)
                fi
                echo "VLC installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Netflix [Unofficial]")
                clear
                figlet -f small "Installing Netflix" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur netflix
                    version=$(get_version netflix)
                else
                    echo "Netflix Unofficial requires manual installation on Fedora"
                    echo "Installing required dependencies:"
                    sudo dnf install -y wget opencl-utils
                    echo "Installing Microsoft Core Fonts:"
                    sudo yum -y localinstall http://sourceforge.net/projects/postinstaller/files/fuduntu/msttcorefonts-2.0-2.noarch.rpm
                    echo "Installing Wine Silverlight & Netflix Desktop:"
                    sudo yum -y install http://sourceforge.net/projects/postinstaller/files/fedora/releases/19/x86_64/updates/wine-silverligh-1.7.2-1.fc19.x86_64.rpm
                    sudo yum -y install http://sourceforge.net/projects/postinstaller/files/fedora/releases/19/x86_64/updates/netflix-desktop-0.7.0-7.fc19.noarch.rpm
                    
                    version="(Manual installation required)"
                fi
                echo "Netflix [Unofficial] installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
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
        clear
        figlet -f slant "Music"
        echo -e "${YELLOW}--------------------------------------${RESET}"
        echo "Select a Music Packages to install:"

        options=("Youtube-Music" "Spotube" "Spotify" "Rhythmbox" "Exit")
        selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=15 --layout=reverse --border)

        case $selected in
            "Youtube-Music")
                clear
                figlet -f small "Installing Yt-Music"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager youtube-music-bin
                    version=$(get_version youtube-music-bin)
                else
                    flatpak install -y flathub app.ytmdesktop.ytmdesktop
                    version="Flatpak Version"
                fi
                echo "Youtube-Music installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Spotube")
                clear
                figlet -f small "Installing Spotube" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager spotube
                    version=$(get_version spotube)
                else
                    flatpak install -y flathub com.github.KRTirtho.Spotube
                    version="Flatpak Version"
                fi
                echo "Spotube installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Spotify")
                clear
                figlet -f small "Installing Spotify" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager spotify
                    version=$(get_version spotify)
                else
                    flatpak install -y flathub com.spotify.Client
                    version="Flatpak Version"
                fi
                echo "Spotify installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Rhythmbox")
                clear
                figlet -f small "Installing Rhythmbox" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager rhythmbox
                else
                    $pkg_manager rhythmbox
                fi
                version=$(get_version rhythmbox)
                echo "Rhythmbox installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
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
        clear
        figlet -f slant "Productivity"
        echo -e "${YELLOW}--------------------------------------${RESET}"
        echo "Select a Productivity Packages to install:"
        
        options=("LibreOffice" "OnlyOffice" "Obsidian" "Joplin" "Calibre" "Exit")
        selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=15 --layout=reverse --border)

        case $selected in
            "LibreOffice")
                clear
                figlet -f small "Installing LibreOffice"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman libreoffice-fresh
                    version=$(get_version libreoffice-fresh)
                else
                    $pkg_manager libreoffice
                    version=$(get_version libreoffice)
                fi
                echo "LibreOffice installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "OnlyOffice")
                clear
                figlet -f small "Installing OnlyOffice"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur onlyoffice-bin
                    version=$(get_version onlyoffice-bin)
                else
                    $flatpak_cmd org.onlyoffice.desktopeditors
                    version="(Flatpak version installed)"
                fi
                echo "OnlyOffice installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Obsidian")
                clear
                figlet -f small "Installing Obsidian"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur obsidian
                    version=$(get_version obsidian)
                else
                    $flatpak_cmd md.obsidian.Obsidian
                    version="(Flatpak version installed)"
                fi
                echo "Obsidian installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Joplin")
                clear
                figlet -f small "Installing Joplin"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur joplin-desktop
                    version=$(get_version joplin-desktop)
                else
                    $flatpak_cmd net.cozic.joplin_desktop
                    version="(Flatpak version installed)"
                fi
                echo "Joplin installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Calibre")
                clear
                figlet -f small "Installing Calibre"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman calibre
                    version=$(get_version calibre)
                else
                    $pkg_manager calibre
                    version=$(get_version calibre)
                fi
                echo "Calibre installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
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
        clear
        figlet -f slant "Streaming"
        echo -e "${YELLOW}--------------------------------------${RESET}"
        echo "Select a Streaming tool to install:"

        options=("OBS Studio" "SimpleScreenRecorder [Git]" "Exit")
        selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=15 --layout=reverse --border)

        case $selected in
            "OBS Studio")
                clear
                figlet -f small "Installing obs-studio"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman obs-studio
                    version=$(get_version obs-studio)
                else
                    $pkg_manager obs-studio
                    version=$(get_version obs-studio)
                fi
                echo "OBS Studio installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "SimpleScreenRecorder [Git]")
                clear
                figlet -f small "Installing SimpleScreenRecorder"
 
                if [[ $distro -eq 0 ]]; then
                    gum confirm "The Git version builds from source and may take some time. Proceed?" && \
                    $pkg_manager_aur simplescreenrecorder-git
                    version=$(get_version simplescreenrecorder-git)
                    echo "SimpleScreenRecorder [Git] installed successfully! Version: $version"
                else
                    echo -e "${YELLOW}:: SimpleScreenRecorder [Git] is not available on Fedora.${RESET}"
                fi
                read -rp "Press Enter to continue..."
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
        clear
        figlet -f slant "Terminal"
        echo "Select a Terminal to install:"
        echo -e "${BLUE}If you're unsure what to choose, Kitty or Alacritty are great options.${RESET}"
        echo -e "${YELLOW}----------------------------------------------------------------------${RESET}"

        options=("Alacritty" "Kitty" "Terminator" "Tilix" "Hyper" "GNOME Terminal" "Konsole" "WezTerm" "Ghostty" "Exit")
        selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=15 --layout=reverse --border)

        case $selected in
            "Alacritty")
                clear
                figlet -f small "Installing Alacritty"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager alacritty
                else
                    $pkg_manager alacritty
                fi
                    version=$(get_version alacritty)
                echo "Alacritty installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Kitty")
                clear
                figlet -f small "Installing Kitty"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager kitty
                else
                    $pkg_manager kitty
                fi
                    version=$(get_version kitty)
                echo "Kitty installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Terminator")
                clear
                figlet -f small "Installing Terminator"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur terminator
                    version=$(get_version terminator)
                else
                    $pkg_manager terminator
                    version=$(get_version terminator)
                fi
                echo "Terminator installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Tilix")
                clear
                figlet -f small "Installing Tilix"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur tilix
                    version=$(get_version tilix)
                else
                    $pkg_manager tilix
                    version=$(get_version tilix)
                fi
                echo "Tilix installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Hyper")
                clear
                figlet -f small "Installing Hyper"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur hyper
                    version=$(get_version hyper)
                else
                    echo "Hyper is not directly available in Fedora repositories."
                    echo "Download from: [Hyper Website](https://hyper.is/)"
                    version="(Manual installation required)"
                fi
                echo "Hyper installation completed! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "GNOME Terminal")
                clear
                figlet -f small "Installing Gnome-Terminal"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager gnome-terminal
                else
                    $pkg_manager gnome-terminal
                fi
                    version=$(get_version gnome-terminal)
                echo "GNOME Terminal installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Konsole")
                clear
                figlet -f small "Installing Konsole"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager konsole
                else
                    $pkg_manager konsole
                fi
                    version=$(get_version konsole)
                echo "Konsole installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "WezTerm")
                clear
                figlet -f small "Installing WezTerm"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager wezterm
                    version=$(get_version wezterm)
                    echo "WezTerm installed successfully! Version: $version"
                elif [[ $distro -eq 1 ]]; then
                    if sudo dnf list --installed wezterm &>/dev/null; then
                        version=$(get_version wezterm)
                        echo "WezTerm is already installed! Version: $version"
                    else
                        sudo dnf install -y wezterm
                        if [[ $? -ne 0 ]]; then
                            $flatpak_cmd org.wezfurlong.wezterm
                            version="(Flatpak version installed)"
                        else
                            version=$(get_version wezterm)
                        fi
                        echo "WezTerm installed successfully! Version: $version"
                    fi
                fi
                read -rp "Press Enter to continue..."
                ;;

            "Ghostty")
                clear
                figlet -f small "Installing Ghostty"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager ghostty
                elif [[ $distro -eq 1 ]]; then
                    sudo dnf copr enable pgdev/ghostty -y
                    sudo dnf install -y ghostty
                fi
                version=$(get_version ghostty)
                echo "Ghostty installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
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
       clear
        figlet -f slant "Text Editors"
        echo -e "${YELLOW}--------------------------------------${RESET}"
        echo "Select a Text Editor to install:"

        options=("Cursor (AI Code Editor)" "Visual Studio Code (VSCODE)" "Vscodium" "ZED Editor" "Neovim" "Vim" "Code-OSS" "Exit")
        selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=15 --layout=reverse --border)

        case $selected in
            "Cursor (AI Code Editor)")
                clear
                figlet -f small "Installing Cursor"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur cursor-bin
                    version=$(get_version cursor-bin)
                else
                    echo "Cursor is not available in Fedora repositories."
                    echo "Download AppImage from:** [Cursor Official Site](https://www.cursor.com/)"
                    echo "To Run: chmod +x Cursor.AppImage && ./Cursor.AppImage"
                    version="(Manual installation required)"
                fi
                echo "Cursor installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Visual Studio Code (VSCODE)")
                clear
                figlet -f small "Installing VSCODE"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur visual-studio-code-bin
                    version=$(get_version visual-studio-code-bin)
                else
                    $flatpak_cmd com.visualstudio.code
                    version="(Flatpak version installed)"
                fi
                echo "VS Code installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Vscodium")
                clear
                figlet -f small "Installing Vscodium" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur vscodium-bin
                    version=$(get_version vscodium-bin)
                else
                    $flatpak_cmd com.vscodium.codium
                    version="(Flatpak version installed)"
                fi
                echo "Vscodium installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "ZED Editor")
                clear
                figlet -f small "Installing ZED" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur zed-preview-bin
                    version=$(get_version zed-preview-bin)
                else
                    $flatpak_cmd dev.zed.Zed
                    version="(Flatpak version installed)"
                fi
                echo "ZED installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Neovim")
                clear
                figlet -f small "Installing Neovim" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur neovim
                    version=$(get_version neovim)
                else
                    $pkg_manager neovim
                    version=$(get_version neovim)
                fi
                echo "Neovim installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Vim")
                clear
                figlet -f small "Installing Vim" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur vim
                    version=$(get_version vim)
                else
                    $flatpak_cmd org.vim.Vim
                    version="(Flatpak version installed)"
                fi
                echo "Vim installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Code-OSS")
                clear
                figlet -f small "Installing Code-OSS" 
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur code-oss
                    version=$(get_version code-oss)
                else
                    $flatpak_cmd com.visualstudio.code-oss
                    version="(Flatpak version installed)"
                fi
                echo "Code-OSS installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
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
        clear
        figlet -f slant "Thunar"
        echo -e "${YELLOW}--------------------------------------${RESET}"
        echo "Select a Thumbnail Previewer:"

        options=("Tumbler" "Trash-Cli" "Exit")
        selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=15 --layout=reverse --border)

        case $selected in
            "Tumbler")
                clear
                figlet -f small "Installing Tumbler"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager tumbler
                else
                    $pkg_manager tumbler
                fi
                version=$(get_version tumbler)
                echo "Tumbler installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
                ;;

            "Trash-Cli")
                clear
                figlet -f small "Installing Trash-Cli"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager trash-cli
                else
                    $pkg_manager trash-cli
                fi
                version=$(get_version trash-cli)
                echo "Trash-Cli installed successfully! Version: $version"
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
        clear
        figlet -f slant "Virtualization"
        echo -e "${YELLOW}--------------------------------------${RESET}"
        echo "Select a Virtualization tool to install:"

        options=("QEMU/KVM" "VirtualBox" "Distrobox" "Exit")
        selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=15 --layout=reverse --border)

        case $selected in
            "QEMU/KVM")
                clear
                figlet -f small "Installing QEMU"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman qemu-base virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat ebtables iptables-nft libguestfs
                    sudo systemctl enable --now libvirtd.service
                    sudo usermod -aG libvirt "$USER"
                    version=$(get_version qemu)
                else
                    $pkg_manager @virtualization
                    sudo systemctl enable --now libvirtd
                    sudo usermod -aG libvirt "$USER"
                    version=$(get_version qemu-kvm)
                fi
                echo "QEMU/KVM installed successfully! Version: $version"
                echo "Note: You may need to log out and back in for group changes to take effect."
                read -rp "Press Enter to continue..."
                ;;

            "VirtualBox")
                clear
                figlet -f small "Installing VirtualBox"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman virtualbox virtualbox-host-dkms
                    sudo usermod -aG vboxusers "$USER"
                    sudo modprobe vboxdrv
                    version=$(get_version virtualbox)
                else
                    $pkg_manager gnome-boxes
                    version=$(get_version gnome-boxes)
                fi
                echo "VirtualBox installed successfully! Version: $version"
                echo "Note: You may need to log out and back in for group changes to take effect."
                read -rp "Press Enter to continue..."
                ;;

            "Distrobox")
                clear
                figlet -f small "Installing DistroBox"
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman distrobox
                    version=$(get_version distrobox)
                else
                    $pkg_manager distrobox
                    version=$(get_version distrobox)
                fi
                echo "Distrobox installed successfully! Version: $version"
                read -rp "Press Enter to continue..."
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
    echo "Select a Category To Install Packages:"
    echo -e "${YELLOW}--------------------------------------${RESET}"

    options=("Android Tools" "Browsers" "Communication Apps" "Development Tools" "Editing Tools" "File Managers" "Gaming" "GitHub" "Multimedia" "Music Apps" "Productivity Apps" "Streaming Tools" "Terminals" "Text Editors" "Thunar Preview" "Virtualization" "Exit")
    selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=15 --layout=reverse --border)

    case $selected in
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
