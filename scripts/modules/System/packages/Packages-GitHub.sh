#!/usr/bin/env bash

install_github() {
    while true; do
        clear

        local options=("Git" "GitHub Desktop" "GitHub CLI" "LazyGit" "Git-Cliff" "Back to Main Menu")

        show_menu "GitHub Tools Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "Git")
                clear
                install_package "git" ""
                ;;

            "GitHub Desktop")
                clear
                case "$DISTRO" in
                    "Arch")
                        install_package "github-desktop-bin" "io.github.shiftey.Desktop"
                        ;;
                    "Fedora" | "openSUSE")
                        print_message "$GREEN" "Downloading GitHub Desktop from latest release..."

                        if ! command -v curl &> /dev/null; then
                            print_message "$GREEN" "Installing curl..."
                            install_package "curl" ""
                        fi

                        if ! command -v wget &> /dev/null; then
                            print_message "$GREEN" "Installing wget..."
                            install_package "wget" ""
                        fi

                        latest_release=$(curl -s https://api.github.com/repos/shiftkey/desktop/releases/latest)
                        if [[ -z "$latest_release" ]]; then
                            print_message "$RED" "Failed to fetch latest release info. Exiting."
                            continue
                        fi

                        rpm_url=$(echo "$latest_release" | grep -o 'https://github.com/shiftkey/desktop/releases/download/[^\\"]*GitHubDesktop-linux-x86_64-[^\\"]*\.rpm' | head -1)

                        if [[ -z "$rpm_url" ]]; then
                            print_message "$RED" "Failed to find RPM download URL. Exiting."
                            continue
                        fi

                        print_message "$GREEN" "Found RPM URL: $rpm_url"

                        tmp_dir=$(mktemp -d)
                        cd "$tmp_dir" || exit 1

                        print_message "$GREEN" "Downloading GitHub Desktop RPM..."
                        if wget "$rpm_url"; then
                            rpm_file=$(basename "$rpm_url")

                            print_message "$GREEN" "Installing GitHub Desktop..."
                            case "$DISTRO" in
                                "Fedora") sudo dnf install -y "./$rpm_file" ;;
                                "openSUSE") sudo zypper install -y --allow-unsigned-rpm "./$rpm_file" ;;
                            esac
                        else
                            print_message "$RED" "Failed to download GitHub Desktop RPM."
                        fi

                        cd /
                        rm -rf "$tmp_dir"
                        ;;
                esac
                ;;

            "GitHub CLI")
                clear
                local pkg_name="gh"
                if [ "$DISTRO" == "Arch" ]; then
                    pkg_name="github-cli"
                fi
                install_package "$pkg_name" ""
                ;;

            "LazyGit")
                clear
                install_package "lazygit" ""
                ;;

            "Git-Cliff")
                clear
                case "$DISTRO" in
                    "Arch")
                        install_package "git-cliff" ""
                        ;;
                    *)
                        print_message "$GREEN" "Installing Git-Cliff from GitHub releases..."

                        if ! command -v tar &> /dev/null; then
                            print_message "$GREEN" "Installing tar..."
                            install_package "tar" ""
                        fi

                        if ! command -v wget &> /dev/null; then
                            print_message "$GREEN" "Installing wget..."
                            install_package "wget" ""
                        fi

                        latest_version=$(curl -s https://api.github.com/repos/orhun/git-cliff/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')

                        if [[ -z "$latest_version" ]]; then
                            print_message "$RED" "Failed to fetch latest version. Exiting."
                            continue
                        fi

                        print_message "$GREEN" "Latest version: $latest_version"

                        tmp_dir=$(mktemp -d)
                        cd "$tmp_dir" || exit 1

                        print_message "$GREEN" "Downloading git-cliff binary..."
                        if wget "https://github.com/orhun/git-cliff/releases/download/v${latest_version}/git-cliff-${latest_version}-x86_64-unknown-linux-gnu.tar.gz"; then
                            tar -xvzf git-cliff-*.tar.gz

                            cd "git-cliff-${latest_version}" || exit 1

                            sudo mv git-cliff /usr/local/bin/
                            sudo chmod +x /usr/local/bin/git-cliff

                            cd /
                            rm -rf "$tmp_dir"
                        else
                            print_message "$RED" "Failed to download git-cliff."
                            rm -rf "$tmp_dir"
                        fi
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
