#!/usr/bin/env bash

install_streaming() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        pkg_manager_pacman="sudo pacman -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        install_flatpak
        pkg_manager="sudo dnf install -y"
        flatpak_cmd="flatpak install -y --noninteractive flathub"
        get_version() { rpm -q "$1"; }
    elif [[ $distro -eq 2 ]]; then
        install_flatpak
        flatpak_cmd="flatpak install -y --noninteractive flathub"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${NC}"
        return
    fi

    while true; do
        clear

        local options=("OBS Studio" "SimpleScreenRecorder [Git]" "Blue Recorder" "Back to Main Menu")

        show_menu "Streaming Tools Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "OBS Studio")
                clear
                if [[ $distro -eq 0 ]]; then
                    $pkg_manager_pacman obs-studio
                    version=$(get_version obs-studio)
                elif [[ $distro -eq 1 ]]; then
                    $pkg_manager obs-studio
                    version=$(get_version obs-studio)
                else
                    $flatpak_cmd com.obsproject.Studio
                    version="Flatpak Version"
                fi
                echo "OBS Studio installed successfully! Version: $version"
                ;;

            "SimpleScreenRecorder [Git]")
                clear
                if [[ $distro -eq 2 ]]; then
                    echo -e "${YELLOW}:: SimpleScreenRecorder build dependencies have known issues on OpenSUSE.${NC}"
                    echo -e "${YELLOW}:: Main runtime dependencies are not available or fail during build.${NC}"
                    echo -e "${YELLOW}:: For more information, visit: https://github.com/MaartenBaert/ssr${NC}"
                    echo ""
                    echo -e "${BLUE}:: Instead, we recommend using Blue Recorder which works well on OpenSUSE.${NC}"
                    read -rp "Press Enter to continue..."
                    continue
                fi

                read -rp "This will clone and build SimpleScreenRecorder from source. Continue? (y/N): " confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    CACHE_DIR="$HOME/.cache/ssr"
                    rm -rf "$CACHE_DIR"
                    mkdir -p "$CACHE_DIR"

                    if [[ $distro -eq 0 ]]; then
                        echo ":: Cloning SimpleScreenRecorder (custom fork)..."
                        git clone https://github.com/harilvfs/ssr "$CACHE_DIR" || {
                            echo -e "${RED}!! Failed to clone repository.${NC}"
                            rm -rf "$CACHE_DIR"
                            continue
                        }

                        cd "$CACHE_DIR/arch-aur/simplescreenrecorder" || {
                            echo -e "${RED}!! Failed to find simplescreenrecorder directory.${NC}"
                            rm -rf "$CACHE_DIR"
                            continue
                        }

                        echo ":: Building and installing SimpleScreenRecorder from source..."
                        if makepkg -si --noconfirm; then
                            version=$(get_version simplescreenrecorder)
                            echo -e "${GREEN}SimpleScreenRecorder installed! Version: $version${NC}"
                        else
                            echo -e "${RED}!! Build failed. Please check the error above.${NC}"
                        fi
                        rm -rf "$CACHE_DIR"

                    elif [[ $distro -eq 1 ]]; then
                        echo ":: Installing build dependencies for Fedora..."
                        sudo dnf install -y qt4 qt4-devel alsa-lib-devel pulseaudio-libs-devel jack-audio-connection-kit-devel \
                            make gcc gcc-c++ mesa-libGL-devel mesa-libGLU-devel libX11-devel libXext-devel libXfixes-devel cmake libv4l-devel pipewire-devel || {
                            echo -e "${RED}!! Failed to install dependencies.${NC}"
                            rm -rf "$CACHE_DIR"
                            continue
                        }

                        echo ":: Enabling RPM Fusion repositories..."
                        sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-42.noarch.rpm \
                            https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-42.noarch.rpm || {
                            echo -e "${RED}!! Failed to enable RPM Fusion.${NC}"
                            rm -rf "$CACHE_DIR"
                            continue
                        }

                        echo ":: Installing FFmpeg and 32-bit libraries..."
                        sudo dnf install -y ffmpeg-devel --allowerasing
                        sudo dnf install -y glibc-devel.i686 libgcc.i686 mesa-libGL-devel.i686 mesa-libGLU-devel.i686 \
                            libX11-devel.i686 libXext-devel.i686 libXfixes-devel.i686 || {
                            echo -e "${RED}!! Failed to install FFmpeg or i686 libraries.${NC}"
                            rm -rf "$CACHE_DIR"
                            continue
                        }

                        echo ":: Cloning SimpleScreenRecorder (original repo)..."
                        git clone https://github.com/MaartenBaert/ssr "$CACHE_DIR" || {
                            echo -e "${RED}!! Failed to clone repository.${NC}"
                            rm -rf "$CACHE_DIR"
                            continue
                        }

                        cd "$CACHE_DIR" || {
                            echo -e "${RED}!! Failed to enter SSR directory.${NC}"
                            rm -rf "$CACHE_DIR"
                            continue
                        }

                        chmod +x simple-build-and-install

                        echo ":: Building SimpleScreenRecorder..."
                        if ./simple-build-and-install; then
                            echo -e "${GREEN}SimpleScreenRecorder installed successfully.${NC}"
                        else
                            echo -e "${RED}!! Build failed. Check for errors above.${NC}"
                        fi
                        rm -rf "$CACHE_DIR"
                    fi
                else
                    echo "Installation aborted."
                fi
                ;;

            "Blue Recorder")
                clear
                if [[ $distro -eq 0 ]]; then
                    install_flatpak
                    flatpak install -y --noninteractive flathub sa.sy.bluerecorder
                    version="Flatpak Version"
                elif [[ $distro -eq 1 ]]; then
                    install_flatpak
                    flatpak install -y --noninteractive flathub sa.sy.bluerecorder
                    version="Flatpak Version"
                else
                    $flatpak_cmd sa.sy.bluerecorder
                    version="Flatpak Version"
                fi
                echo "Blue Recorder installed successfully! Version: $version"
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
