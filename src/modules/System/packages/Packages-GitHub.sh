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
