#!/usr/bin/env bash

# Installs a curated selection of essential packages to establish a fully functional environment.

source "$(dirname "$0")/../colors.sh" >/dev/null 2>&1

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

if [ "$(id -u)" = 0 ]; then
    echo -e "${RED}This script should not be run as root.${RESET}"
    exit 1
fi

AUR_HELPER=""

detect_distro() {
   if command -v pacman &>/dev/null; then
       echo -e "${GREEN}:: Arch-based system detected.${RESET}"
       return 0
   elif command -v dnf &>/dev/null; then
       echo -e "${YELLOW}:: Fedora-based system detected. Skipping AUR helper installation.${RESET}"
       return 1
   else
       echo -e "${RED}:: Unsupported distribution detected. Proceeding cautiously...${RESET}"
       return 2
   fi
}

detect_aur_helper() {
    for helper in paru yay; do
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
       sudo dnf install -y "$package_name"
    else
        echo -e "${YELLOW}:: $package_name not found in DNF. Falling back to Flatpak.${RESET}"
        flatpak install -y flathub "$flatpak_id"
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

        options=("Gvfs-MTP [Displays Android phones via USB]" "ADB" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
                "Gvfs-MTP [Displays Android phones via USB]")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur gvfs-mtp
                        version=$(get_version gvfs-mtp)
                    else
                        $pkg_manager gvfs-mtp
                        version=$(get_version gvfs-mtp)
                    fi
                    echo "Gvfs-MTP installed successfully! Version: $version"
                    ;;

                "ADB")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur android-tools
                        version=$(get_version android-tools)
                    else
                        $pkg_manager android-tools
                        version=$(get_version android-tools)
                    fi
                    echo "ADB installed successfully! Version: $version"
                    ;;
            esac
        done

        echo "All selected Android tools have been installed."
        read -rp "Press Enter to continue..."
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

        options=("Brave" "Firefox" "Lynx" "Libre Wolf" "Floorp" "Google Chrome" "Chromium" "Vivaldi" "Qute Browser" "Zen Browser" "Thorium Browser" "Opera" "Tor Browser" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=60% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in

                "Brave")
                    clear
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
                    ;;

                "Firefox")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman firefox
                        version=$(get_version firefox)
                    else
                        $pkg_manager firefox
                        version=$(get_version firefox)
                    fi
                    echo "Firefox installed successfully! Version: $version"
                    ;;

                "Lynx")
                    clear
                    if [[ $distro -eq 0 ]]; then
                      $pkg_manager_pacman lynx
                      version=$(get_version lynx)
                    else
                      $pkg_manager lynx
                      version=$(get_version lynx)
                    fi
                    echo "Lynx installed successfully! Version: $version"
                    ;;

                "Libre Wolf")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur librewolf-bin
                        version=$(get_version librewolf-bin)
                    else
                        $flatpak_cmd io.gitlab.librewolf-community
                        version="(Flatpak version installed)"
                    fi
                    echo "Libre Wolf installed successfully! Version: $version"
                    ;;

                "Floorp")
                    clear
                    if [[ $distro -eq 0 ]]; then
                      $pkg_manager_aur floorp-bin
                      version=$(get_version floorp-bin)
                    else
                      echo "Setting sneexy/floorp repository"
                      sudo dnf copr enable sneexy/floorp
                      $pkg_manager floorp
                      version=$(get_version floorp)
                    fi
                    echo "Floorp browser installed successfully! Version: $version"
                    ;;

                "Google Chrome")
                    clear
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
                    ;;

                "Chromium")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman chromium
                        version=$(get_version chromium)
                    else
                        $flatpak_cmd org.chromium.Chromium
                        version="(Flatpak version installed)"
                    fi
                    echo "Chromium installed successfully! Version: $version"
                    ;;

                "Vivaldi")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman vivaldi
                        version=$(get_version vivaldi)
                    else
                        $flatpak_cmd com.vivaldi.Vivaldi
                        version="(Flatpak version installed)"
                    fi
                    echo "Vivaldi installed successfully! Version: $version"
                    ;;

                "Qute Browser")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman qutebrowser
                        version=$(get_version qutebrowser)
                    else
                        $flatpak_cmd org.qutebrowser.qutebrowser
                        version="(Flatpak version installed)"
                    fi
                    echo "Qute Browser installed successfully! Version: $version"
                    ;;

                "Zen Browser")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur zen-browser-bin
                        version=$(get_version zen-browser-bin)
                    else
                        $flatpak_cmd app.zen_browser.zen
                        version="(Flatpak version installed)"
                    fi
                    echo "Zen Browser installed successfully! Version: $version"
                    ;;

                "Thorium Browser")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur thorium-browser-bin
                        version=$(get_version thorium-browser-bin)
                        echo "Thorium Browser installed successfully! Version: $version"
                    else
                        echo "Downloading and installing Thorium Browser for Fedora..."

                        if ! command -v wget &>/dev/null; then
                            echo "Installing wget..."
                            sudo dnf install -y wget
                        fi

                        temp_dir=$(mktemp -d)
                        cd "$temp_dir" || { echo -e "${RED}Failed to create temp directory${RESET}"; return; }

                        echo "Fetching latest Thorium Browser release..."
                        wget -q --show-progress https://github.com/Alex313031/thorium/releases/latest -O latest
                        latest_url=$(grep -o 'https://github.com/Alex313031/thorium/releases/tag/[^"]*' latest | head -1)
                        latest_version=$(echo "$latest_url" | grep -o '[^/]*$')

                        echo "Latest version: $latest_version"
                        echo "Downloading Thorium Browser AVX package..."
                        wget -q --show-progress "https://github.com/Alex313031/thorium/releases/download/$latest_version/thorium-browser_${latest_version#M}_AVX.rpm" || \
                        wget -q --show-progress "https://github.com/Alex313031/thorium/releases/download/$latest_version/thorium-browser_*_AVX.rpm"

                        rpm_file=$(ls thorium*AVX.rpm 2>/dev/null)
                        if [ -n "$rpm_file" ]; then
                            echo "Installing Thorium Browser..."
                            sudo dnf install -y "./$rpm_file"
                            version="$latest_version"
                            echo "Thorium Browser installed successfully! Version: $version"
                        else
                            echo "Failed to download Thorium Browser. Please visit https://thorium.rocks/ for manual installation."
                        fi

                        cd - >/dev/null || return
                        rm -rf "$temp_dir"
                    fi
                    ;;

                "Opera")
                    clear
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
                    ;;

                "Tor Browser")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur tor-browser-bin
                        version=$(get_version tor-browser-bin)
                    else
                        $flatpak_cmd org.torproject.torbrowser-launcher
                        version="(Flatpak version installed)"
                    fi
                    echo "Tor Browser installed successfully! Version: $version"
                    ;;
            esac
        done

        echo "All selected browsers have been installed."
        read -rp "Press Enter to continue..."
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

        options=("Discord" "Better Discord" "Signal" "Element (Matrix)" "Slack" "Teams" "Zoom" "Telegram" "Keybase" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
            "Discord")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager discord
                    version=$(pacman -Qi discord | grep Version | awk '{print $3}')
                    echo "Discord installed successfully! Version: $version"
                else
                    $pkg_manager "discord" "com.discordapp.Discord"
                    echo "Discord installed successfully!"
                fi
                ;;

            "Better Discord")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager betterdiscord-installer-bin
                    echo "Better Discord installed successfully!"
                else
                    echo -e "${YELLOW}:: Better Discord is not available for Fedora.${RESET}"
                fi
                ;;

            "Signal")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager signal-desktop
                    version=$(pacman -Qi signal-desktop | grep Version | awk '{print $3}')
                    echo "Signal installed successfully! Version: $version"
                else
                    $pkg_manager "signal-desktop" "org.signal.Signal"
                    echo "Signal installed successfully!"
                fi
                ;;

            "Element (Matrix)")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur element-desktop
                    version=$(get_version element-desktop)
                else
                    $flatpak_cmd im.riot.Riot
                    version="(Flatpak version installed)"
                fi
                echo "Element installed successfully! Version: $version"
                ;;

            "Slack")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur slack-desktop
                    version=$(get_version slack-desktop)
                else
                    $flatpak_cmd com.slack.Slack
                    version="(Flatpak version installed)"
                fi
                echo "Slack installed successfully! Version: $version"
                ;;

            "Teams")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur teams
                    version=$(get_version teams)
                    echo "Teams installed successfully! Version: $version"
                else
                    echo "Microsoft Teams is not available in Fedora's repositories. Use the web version instead:** [**Teams Web**](https://teams.microsoft.com)"
                fi
                ;;

            "Zoom")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur zoom
                    version=$(get_version zoom)
                else
                    $flatpak_cmd us.zoom.Zoom
                    version="(Flatpak version installed)"
                fi
                echo "Zoom installed successfully! Version: $version"
                ;;

            "Telegram")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager telegram-desktop
                    version=$(pacman -Qi telegram-desktop | grep Version | awk '{print $3}')
                    echo "Telegram installed successfully! Version: $version"
                else
                    $pkg_manager "telegram-desktop" "org.telegram.desktop"
                    echo "Telegram installed successfully!"
                fi
                ;;

            "Keybase")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager keybase-bin
                    version=$(pacman -Qi keybase-bin | grep Version | awk '{print $3}')
                    echo "Keybase installed successfully! Version: $version"
                else
                    sudo dnf install -y https://prerelease.keybase.io/keybase_amd64.rpm
                    echo "Keybase installed successfully!"
                fi
                ;;

            esac
        done

        echo "All selected Communication Apps have been installed."
        read -rp "Press Enter to continue..."
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

        options=("Node.js" "Python" "Rust" "Go" "Docker" "Postman" "DBeaver" "Hugo" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
            "Node.js")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman nodejs npm
                    version=$(get_version nodejs)
                else
                    $pkg_manager nodejs-npm
                    version=$(get_version nodejs)
                fi
                echo "Node.js installed successfully! Version: $version"
                ;;

            "Python")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman python python-pip
                    version=$(get_version python)
                else
                    $pkg_manager python3 python3-pip
                    version=$(get_version python3)
                fi
                echo "Python installed successfully! Version: $version"
                ;;

            "Rust")
                clear
                bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
                source "$HOME/.cargo/env"
                version=$(rustc --version | awk '{print $2}')
                echo "Rust installed successfully! Version: $version"
                ;;

            "Go")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman go
                    version=$(get_version go)
                else
                    $pkg_manager golang
                    version=$(get_version golang)
                fi
                echo "Go installed successfully! Version: $version"
                ;;

            "Docker")
                clear
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
                ;;

            "Postman")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur postman-bin
                    version=$(get_version postman-bin)
                else
                    $flatpak_cmd com.getpostman.Postman
                    version="(Flatpak version installed)"
                fi
                echo "Postman installed successfully! Version: $version"
                ;;

            "DBeaver")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman dbeaver
                    version=$(get_version dbeaver)
                else
                    $flatpak_cmd io.dbeaver.DBeaverCommunity
                    version="(Flatpak version installed)"
                fi
                echo "DBeaver installed successfully! Version: $version"
                ;;

            "Hugo")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman hugo
                    version=$(get_version hugo)
                else
                    $pkg_manager hugo
                    version=$(get_version hugo)
                fi
                echo "Hugo installed successfully! Version: $version"
                ;;

            esac
        done

        echo "All selected Development tools have been installed."
        read -rp "Press Enter to continue..."
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

        options=("GIMP (Image)" "Kdenlive (Videos)" "Krita" "Blender" "Inkscape" "Audacity" "DaVinci Resolve" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
            "GIMP (Image)")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager gimp
                    version=$(pacman -Qi gimp | grep Version | awk '{print $3}')
                else
                    $pkg_manager gimp
                    version=$(rpm -q gimp)
                fi
                echo "GIMP installed successfully! Version: $version"
                ;;

            "Kdenlive (Videos)")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager kdenlive
                    version=$(pacman -Qi kdenlive | grep Version | awk '{print $3}')
                    echo "Kdenlive installed successfully! Version: $version"
                else
                    $pkg_manager kdenlive
                    version=$(rpm -q kdenlive)
                    echo "Kdenlive installed successfully! Version: $version"
                fi
                ;;

            "Krita")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur krita
                    version=$(get_version krita)
                else
                    $pkg_manager krita
                    version=$(get_version krita)
                fi
                echo "Krita installed successfully! Version: $version"
                ;;

            "Blender")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur blender
                    version=$(get_version blender)
                else
                    $pkg_manager blender
                    version=$(get_version blender)
                fi
                echo "Blender installed successfully! Version: $version"
                ;;

            "Inkscape")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur inkscape
                    version=$(get_version inkscape)
                else
                    $pkg_manager inkscape
                    version=$(get_version inkscape)
                fi
                echo "Inkscape installed successfully! Version: $version"
                ;;

            "Audacity")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur audacity
                    version=$(get_version audacity)
                else
                    $pkg_manager audacity
                    version=$(get_version audacity)
                fi
                echo "Audacity installed successfully! Version: $version"
                ;;

            "DaVinci Resolve")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur davinci-resolve
                    version=$(get_version davinci-resolve)
                else
                    echo "DaVinci Resolve is not directly available in Fedora repositories."
                    echo "Download from: [Blackmagic Design Website](https://www.blackmagicdesign.com/products/davinciresolve/)"
                    version="(Manual installation required)"
                fi
                echo "DaVinci Resolve installation completed! Version: $version"
                ;;

            esac
        done

        echo "All selected Editing tools have been installed."
        read -rp "Press Enter to continue..."
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

        options=("Nemo" "Thunar" "Dolphin" "LF (Terminal File Manager)" "Ranger" "Nautilus" "Yazi" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
            "Nemo")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager nemo
                else
                    $pkg_manager nemo
                fi
                version=$(get_version nemo)
                echo "Nemo installed successfully! Version: $version"
                ;;

            "Thunar")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager thunar
                else
                    $pkg_manager thunar
                fi
                version=$(get_version thunar)
                echo "Thunar installed successfully! Version: $version"
                ;;

            "Dolphin")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager dolphin
                else
                    $pkg_manager dolphin
                fi
                version=$(get_version dolphin)
                echo "Dolphin installed successfully! Version: $version"
                ;;

            "LF (Terminal File Manager)")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager lf
                else
                    sudo dnf copr enable lsevcik/lf -y
                    $pkg_manager lf
                fi
                version=$(get_version lf)
                echo "LF installed successfully! Version: $version"
                ;;

            "Ranger")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager ranger
                else
                    $pkg_manager ranger
                fi
                version=$(get_version ranger)
                echo "Ranger installed successfully! Version: $version"
                ;;

            "Nautilus")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager nautilus
                else
                    $pkg_manager nautilus
                fi
                version=$(get_version nautilus)
                echo "Nautilus installed successfully! Version: $version"
                ;;

            "Yazi")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager yazi
                else
                    sudo dnf copr enable varlad/yazi -y
                    $pkg_manager yazi
                fi
                version=$(get_version yazi)
                echo "Yazi installed successfully! Version: $version"
                ;;

            esac
        done

        echo "All selected Filemanagers have been installed."
        read -rp "Press Enter to continue..."
    done
}

install_fm_tools() {
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

        options=("Tumbler [Thumbnail Viewer]" "Trash-Cli" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
            "Tumbler [Thumbnail Viewer]")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager tumbler
                else
                    $pkg_manager tumbler
                fi
                version=$(get_version tumbler)
                echo "Tumbler installed successfully! Version: $version"
                ;;

            "Trash-Cli")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager trash-cli
                else
                    $pkg_manager trash-cli
                fi
                version=$(get_version trash-cli)
                echo "Trash-Cli installed successfully! Version: $version"
                ;;

            esac
        done

        echo "All selected FM tools have been installed."
        read -rp "Press Enter to continue..."
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

        options=("Steam" "Lutris" "Heroic Games Launcher" "ProtonUp-Qt" "MangoHud" "GameMode" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
            "Steam")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman steam
                    version=$(get_version steam)
                else
                    $flatpak_cmd com.valvesoftware.Steam
                    version="(Flatpak version installed)"
                fi
                echo "Steam installed successfully! Version: $version"
                ;;

            "Lutris")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman lutris
                    version=$(get_version lutris)
                else
                    $pkg_manager lutris
                    version=$(get_version lutris)
                fi
                echo "Lutris installed successfully! Version: $version"
                ;;

            "Heroic Games Launcher")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur heroic-games-launcher-bin
                    version=$(get_version heroic-games-launcher-bin)
                else
                    $flatpak_cmd com.heroicgameslauncher.hgl
                    version="(Flatpak version installed)"
                fi
                echo "Heroic Games Launcher installed successfully! Version: $version"
                ;;

            "ProtonUp-Qt")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur protonup-qt-bin
                    version=$(get_version protonup-qt-bin)
                else
                    $flatpak_cmd net.davidotek.pupgui2
                    version="(Flatpak version installed)"
                fi
                echo "ProtonUp-Qt installed successfully! Version: $version"
                ;;

            "MangoHud")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman mangohud
                    version=$(get_version mangohud)
                else
                    $pkg_manager mangohud
                    version=$(get_version mangohud)
                fi
                echo "MangoHud installed successfully! Version: $version"
                ;;

            "GameMode")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman gamemode
                    version=$(get_version gamemode)
                else
                    $pkg_manager gamemode
                    version=$(get_version gamemode)
                fi
                echo "GameMode installed successfully! Version: $version"
                ;;

            esac
        done

        echo "All selected Gaming Platform have been installed."
        read -rp "Press Enter to continue..."
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

        options=("Git" "GitHub Desktop" "GitHub CLI" "LazyGit" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
            "Git")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur git
                    version=$(get_version git)
                else
                    $pkg_manager git
                    version=$(get_version git)
                fi
                echo "Git installed successfully! Version: $version"
                ;;

            "GitHub Desktop")
                clear
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
                ;;

            "GitHub CLI")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman github-cli
                    version=$(get_version github-cli)
                else
                    $pkg_manager gh
                    version=$(get_version gh)
                fi
                echo "GitHub CLI installed successfully! Version: $version"
                ;;

            "LazyGit")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman lazygit
                    version=$(get_version lazygit)
                    echo "LazyGit installed successfully! Version: $version"
                else
                    echo -e "${YELLOW}:: Warning: LazyGit COPR repository is no longer maintained in Fedora.${RESET}"
                    read -rp "Do you want to proceed with installation anyway? (y/N) " confirm
                    if [[ $confirm =~ ^[Yy]$ ]]; then
                        sudo dnf copr enable atim/lazygit -y
                        $pkg_manager lazygit
                        version=$(get_version lazygit)
                        echo "LazyGit installed successfully! Version: $version"
                    else
                        echo "LazyGit installation aborted."
                    fi
                fi
                ;;

            esac
        done

        echo "All selected Git tools have been installed."
        read -rp "Press Enter to continue..."
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

        options=("VLC" "Netflix [Unofficial]" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
            "VLC")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur vlc
                    version=$(get_version vlc)
                else
                    $pkg_manager vlc
                    version=$(get_version vlc)
                fi
                echo "VLC installed successfully! Version: $version"
                ;;

            "Netflix [Unofficial]")
                clear
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
                ;;

            esac
        done

        echo "All selected Multimedia tools have been installed."
        read -rp "Press Enter to continue..."
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

        options=("Youtube-Music" "Spotube" "Spotify" "Rhythmbox" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
            "Youtube-Music")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager youtube-music-bin
                    version=$(get_version youtube-music-bin)
                else
                    flatpak install -y flathub app.ytmdesktop.ytmdesktop
                    version="Flatpak Version"
                fi
                echo "Youtube-Music installed successfully! Version: $version"
                ;;

            "Spotube")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager spotube
                    version=$(get_version spotube)
                else
                    flatpak install -y flathub com.github.KRTirtho.Spotube
                    version="Flatpak Version"
                fi
                echo "Spotube installed successfully! Version: $version"
                ;;

            "Spotify")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager spotify
                    version=$(get_version spotify)
                else
                    flatpak install -y flathub com.spotify.Client
                    version="Flatpak Version"
                fi
                echo "Spotify installed successfully! Version: $version"
                ;;

            "Rhythmbox")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager rhythmbox
                else
                    $pkg_manager rhythmbox
                fi
                version=$(get_version rhythmbox)
                echo "Rhythmbox installed successfully! Version: $version"
                ;;

            esac
        done

        echo "All selected Music Apps have been installed."
        read -rp "Press Enter to continue..."
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

        options=("LibreOffice" "OnlyOffice" "Obsidian" "Joplin" "Calibre" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
            "LibreOffice")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman libreoffice-fresh
                    version=$(get_version libreoffice-fresh)
                else
                    $pkg_manager libreoffice
                    version=$(get_version libreoffice)
                fi
                echo "LibreOffice installed successfully! Version: $version"
                ;;

            "OnlyOffice")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur onlyoffice-bin
                    version=$(get_version onlyoffice-bin)
                else
                    $flatpak_cmd org.onlyoffice.desktopeditors
                    version="(Flatpak version installed)"
                fi
                echo "OnlyOffice installed successfully! Version: $version"
                ;;

            "Obsidian")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur obsidian
                    version=$(get_version obsidian)
                else
                    $flatpak_cmd md.obsidian.Obsidian
                    version="(Flatpak version installed)"
                fi
                echo "Obsidian installed successfully! Version: $version"
                ;;

            "Joplin")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur joplin-desktop
                    version=$(get_version joplin-desktop)
                else
                    $flatpak_cmd net.cozic.joplin_desktop
                    version="(Flatpak version installed)"
                fi
                echo "Joplin installed successfully! Version: $version"
                ;;

            "Calibre")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman calibre
                    version=$(get_version calibre)
                else
                    $pkg_manager calibre
                    version=$(get_version calibre)
                fi
                echo "Calibre installed successfully! Version: $version"
                ;;

            esac
        done

        echo "All selected Productivity Apps have been installed."
        read -rp "Press Enter to continue..."
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

        options=("OBS Studio" "SimpleScreenRecorder [Git]" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
            "OBS Studio")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman obs-studio
                    version=$(get_version obs-studio)
                else
                    $pkg_manager obs-studio
                    version=$(get_version obs-studio)
                fi
                echo "OBS Studio installed successfully! Version: $version"
                ;;

            "SimpleScreenRecorder [Git]")
                clear
                if [[ $distro -eq 0 ]]; then
                    read -rp "The Git version builds from source and may take some time. Proceed? (y/N) " confirm
                    if [[ $confirm =~ ^[Yy]$ ]]; then
                        $pkg_manager_aur simplescreenrecorder-git
                        version=$(get_version simplescreenrecorder-git)
                        echo "SimpleScreenRecorder [Git] installed successfully! Version: $version"
                    else
                        echo "Installation aborted."
                    fi
                else
                    echo -e "${YELLOW}:: SimpleScreenRecorder [Git] is not available on Fedora.${RESET}"
                fi
                ;;

            esac
        done

        echo "All selected Streaming tools have been installed."
        read -rp "Press Enter to continue..."
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

        options=("Alacritty" "Kitty" "St" "Terminator" "Tilix" "Hyper" "GNOME Terminal" "Konsole" "WezTerm" "Ghostty" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=50% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
            "Alacritty")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager alacritty
                else
                    $pkg_manager alacritty
                fi
                    version=$(get_version alacritty)
                echo "Alacritty installed successfully! Version: $version"
                ;;

            "Kitty")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager kitty
                else
                    $pkg_manager kitty
                fi
                    version=$(get_version kitty)
                echo "Kitty installed successfully! Version: $version"
                ;;

            "St")
                clear
                if [[ distro -eq 0 ]]; then
                   $pkg_manager_aur st
                   version=$(get_version st)
                else
                   $pkg_manager st
                   version=$(get_version st)
                fi
                echo "St Terminal installed successfully! Version: $version"
                ;;

            "Terminator")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur terminator
                    version=$(get_version terminator)
                else
                    $pkg_manager terminator
                    version=$(get_version terminator)
                fi
                echo "Terminator installed successfully! Version: $version"
                ;;

            "Tilix")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur tilix
                    version=$(get_version tilix)
                else
                    $pkg_manager tilix
                    version=$(get_version tilix)
                fi
                echo "Tilix installed successfully! Version: $version"
                ;;

            "Hyper")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur hyper
                    version=$(get_version hyper)
                else
                    echo "Hyper is not directly available in Fedora repositories."
                    echo "Download from: [Hyper Website](https://hyper.is/)"
                    version="(Manual installation required)"
                fi
                echo "Hyper installation completed! Version: $version"
                ;;

            "GNOME Terminal")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager gnome-terminal
                else
                    $pkg_manager gnome-terminal
                fi
                    version=$(get_version gnome-terminal)
                echo "GNOME Terminal installed successfully! Version: $version"
                ;;

            "Konsole")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager konsole
                else
                    $pkg_manager konsole
                fi
                    version=$(get_version konsole)
                echo "Konsole installed successfully! Version: $version"
                ;;

            "WezTerm")
                clear
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
                ;;

            "Ghostty")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager ghostty
                elif [[ $distro -eq 1 ]]; then
                    sudo dnf copr enable pgdev/ghostty -y
                    sudo dnf install -y ghostty
                fi
                version=$(get_version ghostty)
                echo "Ghostty installed successfully! Version: $version"
                ;;

            esac
        done

        echo "All selected Terminals Package have been installed."
        read -rp "Press Enter to continue..."
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

        options=("Cursor (AI Code Editor)" "Visual Studio Code (VSCODE)" "Vscodium" "ZED Editor" "Neovim" "Vim" "Code-OSS" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
            "Cursor (AI Code Editor)")
                clear
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
                ;;

            "Visual Studio Code (VSCODE)")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur visual-studio-code-bin
                    version=$(get_version visual-studio-code-bin)
                else
                    $flatpak_cmd com.visualstudio.code
                    version="(Flatpak version installed)"
                fi
                echo "VS Code installed successfully! Version: $version"
                ;;

            "Vscodium")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur vscodium-bin
                    version=$(get_version vscodium-bin)
                else
                    $flatpak_cmd com.vscodium.codium
                    version="(Flatpak version installed)"
                fi
                echo "Vscodium installed successfully! Version: $version"
                ;;

            "ZED Editor")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur zed-preview-bin
                    version=$(get_version zed-preview-bin)
                else
                    $flatpak_cmd dev.zed.Zed
                    version="(Flatpak version installed)"
                fi
                echo "ZED installed successfully! Version: $version"
                ;;

            "Neovim")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur neovim
                    version=$(get_version neovim)
                else
                    $pkg_manager neovim
                    version=$(get_version neovim)
                fi
                echo "Neovim installed successfully! Version: $version"
                ;;

            "Vim")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur vim
                    version=$(get_version vim)
                else
                    $flatpak_cmd org.vim.Vim
                    version="(Flatpak version installed)"
                fi
                echo "Vim installed successfully! Version: $version"
                ;;

            "Code-OSS")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur code-oss
                    version=$(get_version code-oss)
                else
                    $flatpak_cmd com.visualstudio.code-oss
                    version="(Flatpak version installed)"
                fi
                echo "Code-OSS installed successfully! Version: $version"
                ;;

            esac
        done

        echo "All selected Text Editors have been installed."
        read -rp "Press Enter to continue..."
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

        options=("QEMU/KVM" "VirtualBox" "Distrobox" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
            "QEMU/KVM")
                clear
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
                ;;

            "VirtualBox")
                clear
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
                ;;

            "Distrobox")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman distrobox podman
                    version=$(get_version distrobox)
                else
                    $pkg_manager distrobox
                    version=$(get_version distrobox)
                fi
                echo "Distrobox installed successfully! Version: $version"
                ;;

            esac
        done

        echo "All selected Android tools have been installed."
        read -rp "Press Enter to continue..."
    done
}

install_crypto_tools() {
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

        options=("Electrum" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=40% \
                                                    --prompt="Choose options (TAB to select multiple): " \
                                                    --header="Package Selection" \
                                                    --pointer="➤" \
                                                    --multi \
                                                    --color='fg:white,fg+:blue,bg+:black,pointer:blue')

        if printf '%s\n' "${selected[@]}" | grep -q "Back to Main Menu" || [[ ${#selected[@]} -eq 0 ]]; then
            return
        fi

        for selection in "${selected[@]}"; do
            case $selection in
            "Electrum")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_aur electrum
                    version=$(get_version electrum)
                else
                    $pkg_manager electrum
                    version=$(get_version electrum)
                fi
                echo "Electrum installed successfully! Version: $version"
                ;;

            esac
        done

        echo "All selected Crypto tools have been installed."
        read -rp "Press Enter to continue..."
    done
}

while true; do

    clear

    if ! command -v fzf &> /dev/null; then
        echo -e "${RED}${BOLD}Error: fzf is not installed${NC}"
        echo -e "${YELLOW}Please install fzf before running this script:${NC}"
        echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install fzf"
        echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S fzf"
        exit 1
    fi

    options=("Android Tools" "Browsers" "Communication Apps" "Development Tools" "Editing Tools" "File Managers" "FM Tools" "Gaming" "GitHub" "Multimedia" "Music Apps" "Productivity Apps" "Streaming Tools" "Terminals" "Text Editors" "Virtualization" "Crypto Tools" "Exit")
    selected=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                        --height=70% \
                                                        --prompt="Choose an option: " \
                                                        --header="Package Selection" \
                                                        --pointer="➤" \
                                                        --color='fg:white,fg+:blue,bg+:black,pointer:blue')

    case $selected in
        "Android Tools") install_android ;;
        "Browsers") install_browsers ;;
        "Communication Apps") install_communication ;;
        "Development Tools") install_development ;;
        "Editing Tools") install_editing ;;
        "File Managers") install_filemanagers ;;
        "FM Tools") install_fm_tools ;;
        "Gaming") install_gaming ;;
        "GitHub") install_github ;;
        "Multimedia") install_multimedia ;;
        "Music Apps") install_music ;;
        "Productivity Apps") install_productivity ;;
        "Streaming Tools") install_streaming ;;
        "Terminals") install_terminals ;;
        "Text Editors") install_texteditor ;;
        "Virtualization") install_virtualization ;;
        "Crypto Tools") install_crypto_tools ;;
        "Exit") exit ;;
    esac
done
