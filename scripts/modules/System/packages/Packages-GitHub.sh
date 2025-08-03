#!/usr/bin/env bash

install_github() {
    case "$DISTRO" in
        "Arch")
            install_aur_helper
            pkg_manager_aur="$AUR_HELPER -S --noconfirm"
            pkg_manager_pacman="sudo pacman -S --noconfirm"
            ;;
        "Fedora")
            pkg_manager="sudo dnf install -y"
            ;;
        "openSUSE")
            pkg_manager="sudo zypper install -y"
            ;;
        *)
            exit 1
            ;;
    esac

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
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur git
                        ;;
                    *)
                        $pkg_manager git
                        ;;
                esac
                ;;

            "GitHub Desktop")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_aur github-desktop-bin
                        ;;
                    "Fedora" | "openSUSE")
                        echo "Downloading GitHub Desktop from latest release..."

                        if ! command -v curl &> /dev/null; then
                            echo "Installing curl..."
                            $pkg_manager curl
                        fi

                        if ! command -v wget &> /dev/null; then
                            echo "Installing wget..."
                            $pkg_manager wget
                        fi

                        latest_release=$(curl -s https://api.github.com/repos/shiftkey/desktop/releases/latest)
                        if [[ -z "$latest_release" ]]; then
                            echo -e "${RED}:: Failed to fetch latest release info. Exiting.${NC}"
                            continue
                        fi

                        rpm_url=$(echo "$latest_release" | grep -o 'https://github.com/shiftkey/desktop/releases/download/[^\\"]*GitHubDesktop-linux-x86_64-[^\\"]*\.rpm' | head -1)

                        if [[ -z "$rpm_url" ]]; then
                            echo -e "${RED}:: Failed to find RPM download URL. Exiting.${NC}"
                            continue
                        fi

                        echo "Found RPM URL: $rpm_url"

                        tmp_dir=$(mktemp -d)
                        cd "$tmp_dir" || exit 1

                        echo "Downloading GitHub Desktop RPM..."
                        if wget "$rpm_url"; then
                            rpm_file=$(basename "$rpm_url")

                            echo "Installing GitHub Desktop..."
                            case "$DISTRO" in
                                "Fedora") sudo dnf install -y "./$rpm_file" ;;
                                "openSUSE") sudo zypper install -y --allow-unsigned-rpm "./$rpm_file" ;;
                            esac
                        else
                            echo -e "${RED}:: Failed to download GitHub Desktop RPM.${NC}"
                        fi

                        cd /
                        rm -rf "$tmp_dir"
                        ;;
                esac
                ;;

            "GitHub CLI")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_pacman github-cli
                        ;;
                    *)
                        $pkg_manager gh
                        ;;
                esac
                ;;

            "LazyGit")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_pacman lazygit
                        ;;
                    *)
                        $pkg_manager lazygit
                        ;;
                esac
                ;;

            "Git-Cliff")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_pacman git-cliff
                        ;;
                    *)
                        echo "Installing Git-Cliff from GitHub releases..."

                        if ! command -v tar &> /dev/null; then
                            echo "Installing tar..."
                            $pkg_manager tar
                        fi

                        if ! command -v wget &> /dev/null; then
                            echo "Installing wget..."
                            $pkg_manager wget
                        fi

                        latest_version=$(curl -s https://api.github.com/repos/orhun/git-cliff/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')

                        if [[ -z "$latest_version" ]]; then
                            echo -e "${RED}:: Failed to fetch latest version. Exiting.${NC}"
                            continue
                        fi

                        echo "Latest version: $latest_version"

                        tmp_dir=$(mktemp -d)
                        cd "$tmp_dir" || exit 1

                        echo "Downloading git-cliff binary..."
                        if wget "https://github.com/orhun/git-cliff/releases/download/v${latest_version}/git-cliff-${latest_version}-x86_64-unknown-linux-gnu.tar.gz"; then
                            tar -xvzf git-cliff-*.tar.gz

                            cd "git-cliff-${latest_version}" || exit 1

                            sudo mv git-cliff /usr/local/bin/
                            sudo chmod +x /usr/local/bin/git-cliff

                            cd /
                            rm -rf "$tmp_dir"
                        else
                            echo -e "${RED}:: Failed to download git-cliff.${NC}"
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
