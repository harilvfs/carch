#!/usr/bin/env bash

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
    elif [[ $distro -eq 2 ]]; then
        install_flatpak
        pkg_manager="sudo zypper install -y"
        flatpak_cmd="flatpak install -y --noninteractive flathub"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${NC}"
        return
    fi

    while true; do
        clear

        options=("Brave" "Firefox" "Lynx" "Libre Wolf" "Floorp" "Google Chrome" "Chromium" "Ungoogled-chromium" "Vivaldi" "Qute Browser" "Zen Browser" "Thorium Browser" "Opera" "Tor Browser" "Back to Main Menu")
        mapfile -t selected < <(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                    --height=65% \
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
                    elif [[ $distro -eq 1 ]]; then
                        echo "Setting up Brave repository..."
                        sudo dnf install -y dnf-plugins-core
                        sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
                        sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
                        $pkg_manager brave-browser
                        version=$(get_version brave-browser)
                    else
                        echo "Setting up Brave repository for openSUSE..."
                        sudo zypper install -y curl
                        sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
                        sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
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
                    elif [[ $distro -eq 1 ]]; then
                        $pkg_manager firefox
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
                    elif [[ $distro -eq 1 ]]; then
                        $pkg_manager lynx
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
                    elif [[ $distro -eq 1 ]]; then
                        $flatpak_cmd io.gitlab.librewolf-community
                        version="(Flatpak version installed)"
                    else
                        echo "Setting up LibreWolf repository for openSUSE..."
                        sudo zypper addrepo https://download.opensuse.org/repositories/home:Hoog/openSUSE_Tumbleweed/home:Hoog.repo
                        sudo zypper refresh
                        sudo zypper install -y LibreWolf
                        version=$(get_version LibreWolf)
                    fi
                    echo "Libre Wolf installed successfully! Version: $version"
                    ;;

                "Floorp")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur floorp-bin
                        version=$(get_version floorp-bin)
                    elif [[ $distro -eq 1 ]]; then
                        echo "Setting sneexy/floorp repository"
                        sudo dnf copr enable sneexy/floorp
                        $pkg_manager floorp
                        version=$(get_version floorp)
                    else
                        $flatpak_cmd one.ablaze.floorp
                        version="(Flatpak version installed)"
                    fi
                    echo "Floorp browser installed successfully! Version: $version"
                    ;;

                "Google Chrome")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur google-chrome
                        version=$(get_version google-chrome)
                    elif [[ $distro -eq 1 ]]; then
                        echo "Setting up Google Chrome repository..."
                        sudo dnf install -y dnf-plugins-core
                        sudo dnf config-manager --set-enabled google-chrome
                        $pkg_manager google-chrome-stable
                        version=$(get_version google-chrome-stable)
                    else
                        echo "Setting up Google Chrome repository for openSUSE..."
                        sudo zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64 google-chrome
                        sudo rpm --import https://dl-ssl.google.com/linux/linux_signing_key.pub
                        sudo zypper in -y google-chrome-stable
                        version=$(get_version google-chrome-stable)
                    fi
                    echo "Google Chrome installed successfully! Version: $version"
                    ;;

                "Chromium")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman chromium
                        version=$(get_version chromium)
                    elif [[ $distro -eq 1 ]]; then
                        $flatpak_cmd org.chromium.Chromium
                        version="(Flatpak version installed)"
                    else
                        $pkg_manager chromium
                        version=$(get_version chromium)
                    fi
                    echo "Chromium installed successfully! Version: $version"
                    ;;

                "Ungoogled-chromium")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur ungoogled-chromium-bin
                        version=$(get_version ungoogled-chromium-bin)
                    elif [[ $distro -eq 1 ]]; then
                        echo "Enabling COPR repository..."
                        sudo dnf copr enable -y wojnilowicz/ungoogled-chromium
                        $pkg_manager ungoogled-chromium
                        version=$(get_version ungoogled-chromium)
                    else
                        $flatpak_cmd io.github.ungoogled_software.ungoogled_chromium
                        version="(Flatpak version installed)"
                    fi
                    echo "Ungoogled Chromium installed successfully! Version: $version"
                    ;;

                "Vivaldi")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman vivaldi
                        version=$(get_version vivaldi)
                    elif [[ $distro -eq 1 ]]; then
                        $flatpak_cmd com.vivaldi.Vivaldi
                        version="(Flatpak version installed)"
                    else
                        echo "Setting up Vivaldi repository for openSUSE..."
                        sudo zypper ar https://repo.vivaldi.com/archive/vivaldi-suse.repo
                        sudo zypper in -y vivaldi-stable
                        version=$(get_version vivaldi-stable)
                    fi
                    echo "Vivaldi installed successfully! Version: $version"
                    ;;

                "Qute Browser")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman qutebrowser
                        version=$(get_version qutebrowser)
                    elif [[ $distro -eq 1 ]]; then
                        $flatpak_cmd org.qutebrowser.qutebrowser
                        version="(Flatpak version installed)"
                    else
                        $pkg_manager qutebrowser
                        version=$(get_version qutebrowser)
                    fi
                    echo "Qute Browser installed successfully! Version: $version"
                    ;;

                "Zen Browser")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur zen-browser-bin
                        version=$(get_version zen-browser-bin)
                    elif [[ $distro -eq 1 ]]; then
                        $flatpak_cmd app.zen_browser.zen
                        version="(Flatpak version installed)"
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
                    elif [[ $distro -eq 1 ]]; then
                        echo "Downloading and installing Thorium Browser for Fedora..."

                        if ! command -v wget &> /dev/null; then
                            echo "Installing wget..."
                            sudo dnf install -y wget
                        fi

                        temp_dir=$(mktemp -d)
                        cd "$temp_dir" || {
                                            echo -e "${RED}Failed to create temp directory${NC}"
                                                                                                     return
                        }

                        echo "Fetching latest Thorium Browser release..."
                        wget -q --show-progress https://github.com/Alex313031/thorium/releases/latest -O latest
                        latest_url=$(grep -o 'https://github.com/Alex313031/thorium/releases/tag/[^"]*' latest | head -1)
                        latest_version=$(echo "$latest_url" | grep -o '[^/]*$')

                        echo "Latest version: $latest_version"
                        echo "Downloading Thorium Browser AVX package..."
                        wget -q --show-progress "https://github.com/Alex313031/thorium/releases/download/$latest_version/thorium-browser_${latest_version#M}_AVX.rpm" ||
                            wget -q --show-progress "https://github.com/Alex313031/thorium/releases/download/$latest_version/thorium-browser_*_AVX.rpm"

                        rpm_file=$(ls thorium*AVX.rpm 2> /dev/null)
                        if [ -n "$rpm_file" ]; then
                            echo "Installing Thorium Browser..."
                            sudo dnf install -y "./$rpm_file"
                            version="$latest_version"
                            echo "Thorium Browser installed successfully! Version: $version"
                        else
                            echo "Failed to download Thorium Browser. Please visit https://thorium.rocks/ for manual installation."
                        fi

                        cd - > /dev/null || return
                        rm -rf "$temp_dir"
                    else
                        echo "Thorium Browser is not currently available for openSUSE."
                        echo "No package found. Will check for future availability."
                        echo "Please visit https://thorium.rocks/ for manual installation or check back later."
                    fi
                    ;;

                "Opera")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur opera
                        version=$(get_version opera)
                    elif [[ $distro -eq 1 ]]; then
                        echo "Setting up Opera repository..."
                        sudo rpm --import https://rpm.opera.com/rpmrepo.key
                        echo -e "[opera]\nname=Opera packages\ntype=rpm-md\nbaseurl=https://rpm.opera.com/rpm\ngpgcheck=1\ngpgkey=https://rpm.opera.com/rpmrepo.key\nenabled=1" | sudo tee /etc/yum.repos.d/opera.repo
                        $pkg_manager opera-stable
                        version=$(get_version opera-stable)
                    else
                        $pkg_manager opera
                        version=$(get_version opera)
                    fi
                    echo "Opera installed successfully! Version: $version"
                    ;;

                "Tor Browser")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_aur tor-browser-bin
                        version=$(get_version tor-browser-bin)
                    elif [[ $distro -eq 1 ]]; then
                        $flatpak_cmd org.torproject.torbrowser-launcher
                        version="(Flatpak version installed)"
                    else
                        $pkg_manager torbrowser-launcher
                        version=$(get_version torbrowser-launcher)
                    fi
                    echo "Tor Browser installed successfully! Version: $version"
                    ;;
            esac
        done

        echo "All selected browsers have been installed."
        read -rp "Press Enter to continue..."
    done
}
