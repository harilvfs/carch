#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

main() {
    while true; do
        clear
    local options=("Brave" "Firefox" "Lynx" "Libre Wolf" "Floorp" "Google Chrome" "Chromium" "Ungoogled-chromium" "Vivaldi" "Qute Browser" "Zen Browser" "Thorium Browser" "Opera" "Tor Browser" "Exit")

    show_menu "Browser Selection" "${options[@]}"
    get_choice "${#options[@]}"
    local choice_index=$?
    local selection="${options[$((choice_index - 1))]}"

    case "$selection" in
        "Brave")
            clear
            case "$DISTRO" in
                "Arch")
                    install_package "brave-bin" "com.brave.Browser"
                    ;;
                "Fedora")
                    print_message "$GREEN" "Setting up Brave repository..."
                    sudo dnf install -y dnf-plugins-core
                    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
                    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
                    install_package "brave-browser" "com.brave.Browser"
                    ;;
                "openSUSE")
                    print_message "$GREEN" "Setting up Brave repository for openSUSE..."
                    sudo zypper install -y curl
                    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
                    sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
                    install_package "brave-browser" "com.brave.Browser"
                    ;;
            esac
            ;;

        "Firefox")
            clear
            install_package "firefox" "org.mozilla.firefox"
            ;;

        "Lynx")
            clear
            install_package "lynx" ""
            ;;

        "Libre Wolf")
            clear
            case "$DISTRO" in
                "Arch")
                    install_package "librewolf-bin" "io.gitlab.librewolf-community"
                    ;;
                "Fedora")
                    install_package "" "io.gitlab.librewolf-community"
                    ;;
                "openSUSE")
                    print_message "$GREEN" "Setting up LibreWolf repository for openSUSE..."
                    sudo zypper addrepo https://download.opensuse.org/repositories/home:Hoog/openSUSE_Tumbleweed/home:Hoog.repo
                    sudo zypper refresh
                    install_package "LibreWolf" "io.gitlab.librewolf-community"
                    ;;
            esac
            ;;

        "Floorp")
            clear
            case "$DISTRO" in
                "Arch")
                    install_package "floorp-bin" "one.ablaze.floorp"
                    ;;
                "Fedora")
                    print_message "$GREEN" "Setting sneexy/floorp repository"
                    sudo dnf copr enable sneexy/floorp
                    install_package "floorp" "one.ablaze.floorp"
                    ;;
                "openSUSE")
                    install_package "" "one.ablaze.floorp"
                    ;;
            esac
            ;;

        "Google Chrome")
            clear
            case "$DISTRO" in
                "Arch")
                    install_package "google-chrome" "com.google.Chrome"
                    ;;
                "Fedora")
                    print_message "$GREEN" "Setting up Google Chrome repository..."
                    sudo dnf install -y dnf-plugins-core
                    sudo dnf config-manager --set-enabled google-chrome
                    install_package "google-chrome-stable" "com.google.Chrome"
                    ;;
                "openSUSE")
                    print_message "$GREEN" "Setting up Google Chrome repository for openSUSE..."
                    sudo zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64 google-chrome
                    sudo rpm --import https://dl-ssl.google.com/linux/linux_signing_key.pub
                    install_package "google-chrome-stable" "com.google.Chrome"
                    ;;
            esac
            ;;

        "Chromium")
            clear
            install_package "chromium" "org.chromium.Chromium"
            ;;

        "Ungoogled-chromium")
            clear
            case "$DISTRO" in
                "Arch")
                    install_package "ungoogled-chromium-bin" "io.github.ungoogled_software.ungoogled_chromium"
                    ;;
                "Fedora")
                    print_message "$GREEN" "Enabling COPR repository..."
                    sudo dnf copr enable -y wojnilowicz/ungoogled-chromium
                    install_package "ungoogled-chromium" "io.github.ungoogled_software.ungoogled_chromium"
                    ;;
                "openSUSE")
                    install_package "" "io.github.ungoogled_software.ungoogled_chromium"
                    ;;
            esac
            ;;

        "Vivaldi")
            clear
            case "$DISTRO" in
                "Arch")
                    install_package "vivaldi" "com.vivaldi.Vivaldi"
                    ;;
                "Fedora")
                    install_package "" "com.vivaldi.Vivaldi"
                    ;;
                "openSUSE")
                    print_message "$GREEN" "Setting up Vivaldi repository for openSUSE..."
                    sudo zypper ar https://repo.vivaldi.com/archive/vivaldi-suse.repo
                    install_package "vivaldi-stable" "com.vivaldi.Vivaldi"
                    ;;
            esac
            ;;

        "Qute Browser")
            clear
            install_package "qutebrowser" "org.qutebrowser.qutebrowser"
            ;;

        "Zen Browser")
            clear
            install_package "zen-browser-bin" "app.zen_browser.zen"
            ;;

        "Thorium Browser")
            clear
            case "$DISTRO" in
                "Arch")
                    install_package "thorium-browser-bin" ""
                    ;;
                "Fedora" | "openSUSE")
                    print_message "$YELLOW" "Downloading and installing Thorium Browser..."

                    if ! command -v wget &> /dev/null; then
                        print_message "$GREEN" "Installing wget..."
                        case "$DISTRO" in
                            "Fedora") sudo dnf install -y wget ;;
                            "openSUSE") sudo zypper install -y wget ;;
                        esac
                    fi

                    temp_dir=$(mktemp -d)
                    cd "$temp_dir" || {
                        print_message "$RED" "Failed to create temp directory"
                        return
                    }

                    print_message "$GREEN" "Fetching latest Thorium Browser release..."
                    wget -q --show-progress https://github.com/Alex313031/thorium/releases/latest -O latest
                    latest_url=$(grep -o 'https://github.com/Alex313031/thorium/releases/tag/[^"\n]*' latest | head -1)
                    latest_version=$(echo "$latest_url" | grep -o '[^/]*$')

                    print_message "$GREEN" "Latest version: $latest_version"
                    print_message "$GREEN" "Downloading Thorium Browser AVX package..."
                    wget -q --show-progress "https://github.com/Alex313031/thorium/releases/download/$latest_version/thorium-browser_${latest_version#M}_AVX.rpm" ||
                        wget -q --show-progress "https://github.com/Alex313031/thorium/releases/download/$latest_version/thorium-browser_*_AVX.rpm"

                    rpm_file=$(ls thorium*AVX.rpm 2> /dev/null)
                    if [ -n "$rpm_file" ]; then
                        print_message "$GREEN" "Installing Thorium Browser..."
                        case "$DISTRO" in
                            "Fedora") sudo dnf install -y "./$rpm_file" ;;
                            "openSUSE") sudo zypper install -y "./$rpm_file" ;;
                        esac
                    else
                        print_message "$RED" "Failed to download Thorium Browser. Please visit https://thorium.rocks/."
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
                    install_package "opera" "com.opera.Opera"
                    ;;
                "Fedora")
                    print_message "$GREEN" "Setting up Opera repository..."
                    sudo rpm --import https://rpm.opera.com/rpmrepo.key
                    echo -e "[opera]\nname=Opera packages\ntype=rpm-md\nbaseurl=https://rpm.opera.com/rpm\ngpgcheck=1\ngpgkey=https://rpm.opera.com/rpmrepo.key\nenabled=1" | sudo tee /etc/yum.repos.d/opera.repo
                    install_package "opera-stable" "com.opera.Opera"
                    ;;
                "openSUSE")
                    install_package "opera" "com.opera.Opera"
                    ;;
            esac
            ;;

        "Tor Browser")
            clear
            case "$DISTRO" in
                "Arch")
                    install_package "tor-browser-bin" "org.torproject.torbrowser-launcher"
                    ;;
                "Fedora")
                    install_package "" "org.torproject.torbrowser-launcher"
                    ;;
                "openSUSE")
                    install_package "torbrowser-launcher" "org.torproject.torbrowser-launcher"
                    ;;
            esac
            ;;
           "Exit")
                exit 0
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
