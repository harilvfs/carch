#!/usr/bin/env bash

install_streaming() {
    while true; do
        clear

        local options=("OBS Studio" "SimpleScreenRecorder [Git]" "Blue Recorder" "Kooha" "Back to Main Menu")

        show_menu "Streaming Tools Selection" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "OBS Studio")
                clear
                install_package "obs-studio" "com.obsproject.Studio"
                ;;

            "SimpleScreenRecorder [Git]")
                clear
                case "$DISTRO" in
                    "openSUSE")
                        print_message "$YELLOW" "SimpleScreenRecorder build dependencies have known issues on OpenSUSE."
                        print_message "$YELLOW" "Main runtime dependencies are not available or fail during build."
                        print_message "$YELLOW" "For more information, visit: https://github.com/MaartenBaert/ssr"
                        echo ""
                        print_message "$BLUE" "Instead, we recommend using Blue Recorder which works well on OpenSUSE."
                        read -rp "Press Enter to continue..."
                        continue
                        ;;
                    *)
                        read -rp "This will clone and build SimpleScreenRecorder from source. Continue? (y/N): " confirm
                        if [[ $confirm =~ ^[Yy]$ ]]; then
                            CACHE_DIR="$HOME/.cache/ssr"
                            rm -rf "$CACHE_DIR"
                            mkdir -p "$CACHE_DIR"

                            case "$DISTRO" in
                                "Arch")
                                    print_message "$GREEN" "Cloning SimpleScreenRecorder (custom fork)..."
                                    git clone https://github.com/harilvfs/ssr "$CACHE_DIR" || {
                                        print_message "$RED" "Failed to clone repository."
                                        rm -rf "$CACHE_DIR"
                                        continue
                                    }

                                    cd "$CACHE_DIR/arch-aur/simplescreenrecorder" || {
                                        print_message "$RED" "Failed to find simplescreenrecorder directory."
                                        rm -rf "$CACHE_DIR"
                                        continue
                                    }

                                    print_message "$GREEN" "Building and installing SimpleScreenRecorder from source..."
                                    makepkg -si --noconfirm
                                    rm -rf "$CACHE_DIR"
                                    ;;
                                "Fedora")
                                    print_message "$GREEN" "Installing build dependencies for Fedora..."
                                    sudo dnf install -y qt4 qt4-devel alsa-lib-devel pulseaudio-libs-devel jack-audio-connection-kit-devel \
                                        make gcc gcc-c++ mesa-libGL-devel mesa-libGLU-devel libX11-devel libXext-devel libXfixes-devel cmake libv4l-devel pipewire-devel || {
                                        print_message "$RED" "Failed to install dependencies."
                                        rm -rf "$CACHE_DIR"
                                        continue
                                    }

                                    print_message "$GREEN" "Enabling RPM Fusion repositories..."
                                    sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-42.noarch.rpm \
                                        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-42.noarch.rpm || {
                                        print_message "$RED" "Failed to enable RPM Fusion."
                                        rm -rf "$CACHE_DIR"
                                        continue
                                    }

                                    print_message "$GREEN" "Installing FFmpeg and 32-bit libraries..."
                                    sudo dnf install -y ffmpeg-devel --allowerasing
                                    sudo dnf install -y glibc-devel.i686 libgcc.i686 mesa-libGL-devel.i686 mesa-libGLU-devel.i686 \
                                        libX11-devel.i686 libXext-devel.i686 libXfixes-devel.i686 || {
                                        print_message "$RED" "Failed to install FFmpeg or i686 libraries."
                                        rm -rf "$CACHE_DIR"
                                        continue
                                    }

                                    print_message "$GREEN" "Cloning SimpleScreenRecorder (original repo)..."
                                    git clone https://github.com/MaartenBaert/ssr "$CACHE_DIR" || {
                                        print_message "$RED" "Failed to clone repository."
                                        rm -rf "$CACHE_DIR"
                                        continue
                                    }

                                    cd "$CACHE_DIR" || {
                                        print_message "$RED" "Failed to enter SSR directory."
                                        rm -rf "$CACHE_DIR"
                                        continue
                                    }

                                    chmod +x simple-build-and-install

                                    print_message "$GREEN" "Building SimpleScreenRecorder..."
                                    if ./simple-build-and-install; then
                                        print_message "$GREEN" "SimpleScreenRecorder installed successfully."
                                    else
                                        print_message "$RED" "Build failed. Check for errors above."
                                    fi
                                    rm -rf "$CACHE_DIR"
                                    ;;
                            esac
                        else
                            echo "Installation aborted."
                        fi
                        ;;
                esac
                ;;

            "Blue Recorder")
                clear
                install_package "" "sa.sy.bluerecorder"
                ;;

            "Kooha")
                clear
                install_package "" "io.github.seadve.Kooha"
                ;;

            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
