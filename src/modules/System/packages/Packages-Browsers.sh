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
