#!/usr/bin/env bash

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
        get_version() { rpm -q "$1"; }
    elif [[ $distro -eq 2 ]]; then
        pkg_manager="sudo zypper install -y"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${NC}"
        return
    fi

    while true; do
        clear

        options=("Git" "GitHub Desktop" "GitHub CLI" "LazyGit" "Git-Cliff" "Back to Main Menu")
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

                        rpm_url=$(echo "$latest_release" | grep -o 'https://github.com/shiftkey/desktop/releases/download/[^"]*GitHubDesktop-linux-x86_64-[^"]*\.rpm' | head -1)

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
                            if [[ $distro -eq 1 ]]; then
                                sudo dnf install -y "./$rpm_file"
                            elif [[ $distro -eq 2 ]]; then
                                sudo zypper install -y --allow-unsigned-rpm "./$rpm_file"
                            fi

                            if [[ $? -eq 0 ]]; then
                                version=$(get_version github-desktop 2> /dev/null || echo "Latest version installed")
                                echo "GitHub Desktop installed successfully! Version: $version"
                            else
                                echo -e "${RED}:: Failed to install GitHub Desktop RPM.${NC}"
                            fi
                        else
                            echo -e "${RED}:: Failed to download GitHub Desktop RPM.${NC}"
                        fi

                        cd /
                        rm -rf "$tmp_dir"
                    fi
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
                        $pkg_manager lazygit
                        version=$(get_version lazygit)
                        echo "LazyGit installed successfully! Version: $version"
                    fi
                    ;;

                "Git-Cliff")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman git-cliff
                        version=$(get_version git-cliff)
                        echo "Git-Cliff installed successfully! Version: $version"
                    else
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

                            echo "Git-Cliff installed successfully! Version: $latest_version"
                        else
                            echo -e "${RED}:: Failed to download git-cliff.${NC}"
                            rm -rf "$tmp_dir"
                        fi
                    fi
                    ;;

            esac
        done

        echo "All selected Git tools have been installed."
        read -rp "Press Enter to continue..."
    done
}
