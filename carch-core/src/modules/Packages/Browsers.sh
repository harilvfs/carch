#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

install_brave() {
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
}

install_firefox() {
    clear
    install_package "firefox" "org.mozilla.firefox"
}

install_lynx() {
    clear
    install_package "lynx" ""
}

install_librewolf() {
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
}

install_floorp() {
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
}

install_google_chrome() {
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
}

install_chromium() {
    clear
    install_package "chromium" "org.chromium.Chromium"
}

install_ungoogled_chromium() {
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
}

install_vivaldi() {
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
}

install_qutebrowser() {
    clear
    install_package "qutebrowser" "org.qutebrowser.qutebrowser"
}

install_zen_browser() {
    clear
    install_package "zen-browser-bin" "app.zen_browser.zen"
}

install_thorium_browser() {
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
}

install_opera() {
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
}

install_tor_browser() {
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
}

main() {
    while true; do
        clear
        local options=("Brave" "Firefox" "Lynx" "Libre Wolf" "Floorp" "Google Chrome" "Chromium" "Ungoogled-chromium" "Vivaldi" "Qute Browser" "Zen Browser" "Thorium Browser" "Opera" "Tor Browser" "Exit")

        show_menu "Browser Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Brave") install_brave ;;
            "Firefox") install_firefox ;;
            "Lynx") install_lynx ;;
            "Libre Wolf") install_librewolf ;;
            "Floorp") install_floorp ;;
            "Google Chrome") install_google_chrome ;;
            "Chromium") install_chromium ;;
            "Ungoogled-chromium") install_ungoogled_chromium ;;
            "Vivaldi") install_vivaldi ;;
            "Qute Browser") install_qutebrowser ;;
            "Zen Browser") install_zen_browser ;;
            "Thorium Browser") install_thorium_browser ;;
            "Opera") install_opera ;;
            "Tor Browser") install_tor_browser ;;
            "Exit") exit 0 ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}

main
