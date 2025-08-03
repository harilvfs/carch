#!/usr/bin/env bash

install_browsers() {
    case "$DISTRO" in
        "Arch")
            install_aur_helper
            pkg_manager_aur="$AUR_HELPER -S --noconfirm"
            pkg_manager_pacman="sudo pacman -S --noconfirm"
            get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
            ;;
        "Fedora")
            install_flatpak
            pkg_manager="sudo dnf install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            get_version() { rpm -q "$1"; }
            ;;
        "openSUSE")
            install_flatpak
            pkg_manager="sudo zypper install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            get_version() { rpm -q "$1"; }
            ;;
        *)
            echo -e "${RED}:: Unsupported distribution. Exiting.${NC}"
            return
            ;;
    esac

    while true; do
        clear

        local options=("Brave" "Firefox" "Lynx" "Libre Wolf" "Floorp" "Google Chrome" "Chromium" "Ungoogled-chromium" "Vivaldi" "Qute Browser" "Zen Browser" "Thorium Browser" "Opera" "Tor Browser" "Back to Main Menu")

        show_menu "Browser Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Brave")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur brave-bin
                        version=$(get_version brave-bin)
                        ;;
                    "Fedora")
                        echo "Setting up Brave repository..."
                        sudo dnf install -y dnf-plugins-core
                        sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
                        sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
                        $pkg_manager brave-browser
                        version=$(get_version brave-browser)
                        ;;
                    "openSUSE")
                        echo "Setting up Brave repository for openSUSE..."
                        sudo zypper install -y curl
                        sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
                        sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
                        $pkg_manager brave-browser
                        version=$(get_version brave-browser)
                        ;;
                esac
                echo "Brave installed successfully! Version: $version"
                ;;

            "Firefox")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_pacman firefox
                        version=$(get_version firefox)
                        ;;
                    "Fedora" | "openSUSE")
                        $pkg_manager firefox
                        version=$(get_version firefox)
                        ;;
                esac
                echo "Firefox installed successfully! Version: $version"
                ;;

            "Lynx")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_pacman lynx
                        version=$(get_version lynx)
                        ;;
                    "Fedora" | "openSUSE")
                        $pkg_manager lynx
                        version=$(get_version lynx)
                        ;;
                esac
                echo "Lynx installed successfully! Version: $version"
                ;;

            "Libre Wolf")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur librewolf-bin
                        version=$(get_version librewolf-bin)
                        ;;
                    "Fedora")
                        $flatpak_cmd io.gitlab.librewolf-community
                        version="(Flatpak version installed)"
                        ;;
                    "openSUSE")
                        echo "Setting up LibreWolf repository for openSUSE..."
                        sudo zypper addrepo https://download.opensuse.org/repositories/home:Hoog/openSUSE_Tumbleweed/home:Hoog.repo
                        sudo zypper refresh
                        sudo zypper install -y LibreWolf
                        version=$(get_version LibreWolf)
                        ;;
                esac
                echo "Libre Wolf installed successfully! Version: $version"
                ;;

            "Floorp")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur floorp-bin
                        version=$(get_version floorp-bin)
                        ;;
                    "Fedora")
                        echo "Setting sneexy/floorp repository"
                        sudo dnf copr enable sneexy/floorp
                        $pkg_manager floorp
                        version=$(get_version floorp)
                        ;;
                    "openSUSE")
                        $flatpak_cmd one.ablaze.floorp
                        version="(Flatpak version installed)"
                        ;;
                esac
                echo "Floorp browser installed successfully! Version: $version"
                ;;

            "Google Chrome")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur google-chrome
                        version=$(get_version google-chrome)
                        ;;
                    "Fedora")
                        echo "Setting up Google Chrome repository..."
                        sudo dnf install -y dnf-plugins-core
                        sudo dnf config-manager --set-enabled google-chrome
                        $pkg_manager google-chrome-stable
                        version=$(get_version google-chrome-stable)
                        ;;
                    "openSUSE")
                        echo "Setting up Google Chrome repository for openSUSE..."
                        sudo zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64 google-chrome
                        sudo rpm --import https://dl-ssl.google.com/linux/linux_signing_key.pub
                        sudo zypper in -y google-chrome-stable
                        version=$(get_version google-chrome-stable)
                        ;;
                esac
                echo "Google Chrome installed successfully! Version: $version"
                ;;

            "Chromium")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE")
                        $pkg_manager_pacman chromium
                        version=$(get_version chromium)
                        ;;
                    "Fedora")
                        $flatpak_cmd org.chromium.Chromium
                        version="(Flatpak version installed)"
                        ;;
                esac
                echo "Chromium installed successfully! Version: $version"
                ;;

            "Ungoogled-chromium")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur ungoogled-chromium-bin
                        version=$(get_version ungoogled-chromium-bin)
                        ;;
                    "Fedora")
                        echo "Enabling COPR repository..."
                        sudo dnf copr enable -y wojnilowicz/ungoogled-chromium
                        $pkg_manager ungoogled-chromium
                        version=$(get_version ungoogled-chromium)
                        ;;
                    "openSUSE")
                        $flatpak_cmd io.github.ungoogled_software.ungoogled_chromium
                        version="(Flatpak version installed)"
                        ;;
                esac
                echo "Ungoogled Chromium installed successfully! Version: $version"
                ;;

            "Vivaldi")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_pacman vivaldi
                        version=$(get_version vivaldi)
                        ;;
                    "Fedora")
                        $flatpak_cmd com.vivaldi.Vivaldi
                        version="(Flatpak version installed)"
                        ;;
                    "openSUSE")
                        echo "Setting up Vivaldi repository for openSUSE..."
                        sudo zypper ar https://repo.vivaldi.com/archive/vivaldi-suse.repo
                        sudo zypper in -y vivaldi-stable
                        version=$(get_version vivaldi-stable)
                        ;;
                esac
                echo "Vivaldi installed successfully! Version: $version"
                ;;

            "Qute Browser")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE")
                        $pkg_manager qutebrowser
                        version=$(get_version qutebrowser)
                        ;;
                    "Fedora")
                        $flatpak_cmd org.qutebrowser.qutebrowser
                        version="(Flatpak version installed)"
                        ;;
                esac
                echo "Qute Browser installed successfully! Version: $version"
                ;;

            "Zen Browser")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur zen-browser-bin
                        version=$(get_version zen-browser-bin)
                        ;;
                    "Fedora" | "openSUSE")
                        $flatpak_cmd app.zen_browser.zen
                        version="(Flatpak version installed)"
                        ;;
                esac
                echo "Zen Browser installed successfully! Version: $version"
                ;;

            "Thorium Browser")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur thorium-browser-bin
                        version=$(get_version thorium-browser-bin)
                        echo "Thorium Browser installed successfully! Version: $version"
                        ;;
                    "Fedora" | "openSUSE")
                        echo "Downloading and installing Thorium Browser..."

                        if ! command -v wget &> /dev/null; then
                            echo "Installing wget..."
                            case "$DISTRO" in
                                "Fedora") sudo dnf install -y wget ;;
                                "openSUSE") sudo zypper install -y wget ;;
                            esac
                        fi

                        temp_dir=$(mktemp -d)
                        cd "$temp_dir" || {
                            echo -e "${RED}Failed to create temp directory${NC}"
                            return
                        }

                        echo "Fetching latest Thorium Browser release..."
                        wget -q --show-progress https://github.com/Alex313031/thorium/releases/latest -O latest
                        latest_url=$(grep -o 'https://github.com/Alex313031/thorium/releases/tag/[^"\n]*' latest | head -1)
                        latest_version=$(echo "$latest_url" | grep -o '[^/]*$')

                        echo "Latest version: $latest_version"
                        echo "Downloading Thorium Browser AVX package..."
                        wget -q --show-progress "https://github.com/Alex313031/thorium/releases/download/$latest_version/thorium-browser_${latest_version#M}_AVX.rpm" ||
                            wget -q --show-progress "https://github.com/Alex313031/thorium/releases/download/$latest_version/thorium-browser_*_AVX.rpm"

                        rpm_file=$(ls thorium*AVX.rpm 2> /dev/null)
                        if [ -n "$rpm_file" ]; then
                            echo "Installing Thorium Browser..."
                            case "$DISTRO" in
                                "Fedora") sudo dnf install -y "./$rpm_file" ;;
                                "openSUSE") sudo zypper install -y "./$rpm_file" ;;
                            esac
                            version="$latest_version"
                            echo "Thorium Browser installed successfully! Version: $version"
                        else
                            echo "Failed to download Thorium Browser. Please visit https://thorium.rocks/ for manual installation."
                        fi

                        cd - > /dev/null || return
                        rm -rf "$temp_dir"
                        ;;
                esac
                ;;

            "Opera")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur opera
                        version=$(get_version opera)
                        ;;
                    "Fedora")
                        echo "Setting up Opera repository..."
                        sudo rpm --import https://rpm.opera.com/rpmrepo.key
                        echo -e "[opera]\nname=Opera packages\ntype=rpm-md\nbaseurl=https://rpm.opera.com/rpm\ngpgcheck=1\ngpgkey=https://rpm.opera.com/rpmrepo.key\nenabled=1" | sudo tee /etc/yum.repos.d/opera.repo
                        $pkg_manager opera-stable
                        version=$(get_version opera-stable)
                        ;;
                    "openSUSE")
                        $pkg_manager opera
                        version=$(get_version opera)
                        ;;
                esac
                echo "Opera installed successfully! Version: $version"
                ;;

            "Tor Browser")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur tor-browser-bin
                        version=$(get_version tor-browser-bin)
                        ;;
                    "Fedora")
                        $flatpak_cmd org.torproject.torbrowser-launcher
                        version="(Flatpak version installed)"
                        ;;
                    "openSUSE")
                        $pkg_manager torbrowser-launcher
                        version=$(get_version torbrowser-launcher)
                        ;;
                esac
                echo "Tor Browser installed successfully! Version: $version"
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
