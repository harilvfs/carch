#!/usr/bin/env bash

install_browsers() {
    case "$DISTRO" in
        "Arch")
            install_aur_helper
            pkg_manager_aur="$AUR_HELPER -S --noconfirm"
            pkg_manager_pacman="sudo pacman -S --noconfirm"
            ;;
        "Fedora")
            install_flatpak
            pkg_manager="sudo dnf install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            ;;
        "openSUSE")
            install_flatpak
            pkg_manager="sudo zypper install -y"
            flatpak_cmd="flatpak install -y --noninteractive flathub"
            ;;
        *)
            exit 1
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
                        ;;
                    "Fedora")
                        echo "Setting up Brave repository..."
                        sudo dnf install -y dnf-plugins-core
                        sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
                        sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
                        $pkg_manager brave-browser
                        ;;
                    "openSUSE")
                        echo "Setting up Brave repository for openSUSE..."
                        sudo zypper install -y curl
                        sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
                        sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
                        $pkg_manager brave-browser
                        ;;
                esac
                ;;

            "Firefox")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_pacman firefox
                        ;;
                    "Fedora" | "openSUSE")
                        $pkg_manager firefox
                        ;;
                esac
                ;;

            "Lynx")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_pacman lynx
                        ;;
                    "Fedora" | "openSUSE")
                        $pkg_manager lynx
                        ;;
                esac
                ;;

            "Libre Wolf")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur librewolf-bin
                        ;;
                    "Fedora")
                        $flatpak_cmd io.gitlab.librewolf-community
                        ;;
                    "openSUSE")
                        echo "Setting up LibreWolf repository for openSUSE..."
                        sudo zypper addrepo https://download.opensuse.org/repositories/home:Hoog/openSUSE_Tumbleweed/home:Hoog.repo
                        sudo zypper refresh
                        sudo zypper install -y LibreWolf
                        ;;
                esac
                ;;

            "Floorp")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur floorp-bin
                        ;;
                    "Fedora")
                        echo "Setting sneexy/floorp repository"
                        sudo dnf copr enable sneexy/floorp
                        $pkg_manager floorp
                        ;;
                    "openSUSE")
                        $flatpak_cmd one.ablaze.floorp
                        ;;
                esac
                ;;

            "Google Chrome")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur google-chrome
                        ;;
                    "Fedora")
                        echo "Setting up Google Chrome repository..."
                        sudo dnf install -y dnf-plugins-core
                        sudo dnf config-manager --set-enabled google-chrome
                        $pkg_manager google-chrome-stable
                        ;;
                    "openSUSE")
                        echo "Setting up Google Chrome repository for openSUSE..."
                        sudo zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64 google-chrome
                        sudo rpm --import https://dl-ssl.google.com/linux/linux_signing_key.pub
                        sudo zypper in -y google-chrome-stable
                        ;;
                esac
                ;;

            "Chromium")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE")
                        $pkg_manager_pacman chromium
                        ;;
                    "Fedora")
                        $flatpak_cmd org.chromium.Chromium
                        ;;
                esac
                ;;

            "Ungoogled-chromium")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur ungoogled-chromium-bin
                        ;;
                    "Fedora")
                        echo "Enabling COPR repository..."
                        sudo dnf copr enable -y wojnilowicz/ungoogled-chromium
                        $pkg_manager ungoogled-chromium
                        ;;
                    "openSUSE")
                        $flatpak_cmd io.github.ungoogled_software.ungoogled_chromium
                        ;;
                esac
                ;;

            "Vivaldi")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_pacman vivaldi
                        ;;
                    "Fedora")
                        $flatpak_cmd com.vivaldi.Vivaldi
                        ;;
                    "openSUSE")
                        echo "Setting up Vivaldi repository for openSUSE..."
                        sudo zypper ar https://repo.vivaldi.com/archive/vivaldi-suse.repo
                        sudo zypper in -y vivaldi-stable
                        ;;
                esac
                ;;

            "Qute Browser")
                clear
                case "$DISTRO" in
                    "Arch" | "openSUSE")
                        $pkg_manager qutebrowser
                        ;;
                    "Fedora")
                        $flatpak_cmd org.qutebrowser.qutebrowser
                        ;;
                esac
                ;;

            "Zen Browser")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur zen-browser-bin
                        ;;
                    "Fedora" | "openSUSE")
                        $flatpak_cmd app.zen_browser.zen
                        ;;
                esac
                ;;

            "Thorium Browser")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur thorium-browser-bin
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
                        else
                            echo "Failed to download Thorium Browser. Please visit https://thorium.rocks/."
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
                        ;;
                    "Fedora")
                        echo "Setting up Opera repository..."
                        sudo rpm --import https://rpm.opera.com/rpmrepo.key
                        echo -e "[opera]\nname=Opera packages\ntype=rpm-md\nbaseurl=https://rpm.opera.com/rpm\ngpgcheck=1\ngpgkey=https://rpm.opera.com/rpmrepo.key\nenabled=1" | sudo tee /etc/yum.repos.d/opera.repo
                        $pkg_manager opera-stable
                        ;;
                    "openSUSE")
                        $pkg_manager opera
                        ;;
                esac
                ;;

            "Tor Browser")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur tor-browser-bin
                        ;;
                    "Fedora")
                        $flatpak_cmd org.torproject.torbrowser-launcher
                        ;;
                    "openSUSE")
                        $pkg_manager torbrowser-launcher
                        ;;
                esac
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
