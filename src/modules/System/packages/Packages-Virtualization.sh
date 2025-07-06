#!/usr/bin/env bash

install_virtualization() {
    detect_distro
    distro=$?

    if [[ $distro -eq 0 ]]; then
        install_aur_helper
        pkg_manager_pacman="sudo pacman -S --noconfirm"
        pkg_manager_aur="$AUR_HELPER -S --noconfirm"
        get_version() { pacman -Qi "$1" | grep Version | awk '{print $3}'; }
    elif [[ $distro -eq 1 ]]; then
        pkg_manager="sudo dnf install -y"
        get_version() { rpm -q "$1"; }
    else
        echo -e "${RED}:: Unsupported distribution. Exiting.${NC}"
        return
    fi

    while true; do
        clear

        options=("QEMU/KVM" "VirtualBox" "Distrobox" "Back to Main Menu")
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
                "QEMU/KVM")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman qemu-base virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat ebtables iptables-nft libguestfs
                        sudo systemctl enable --now libvirtd.service
                        sudo usermod -aG libvirt "$USER"
                        version=$(get_version qemu)
                    else
                        $pkg_manager @virtualization
                        sudo systemctl enable --now libvirtd
                        sudo usermod -aG libvirt "$USER"
                        version=$(get_version qemu-kvm)
                    fi
                    echo "QEMU/KVM installed successfully! Version: $version"
                    echo "Note: You may need to log out and back in for group changes to take effect."
                    ;;

                "VirtualBox")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman virtualbox virtualbox-host-dkms
                        sudo usermod -aG vboxusers "$USER"
                        sudo modprobe vboxdrv
                        version=$(get_version virtualbox)
                    else
                        $pkg_manager gnome-boxes
                        version=$(get_version gnome-boxes)
                    fi
                    echo "VirtualBox installed successfully! Version: $version"
                    echo "Note: You may need to log out and back in for group changes to take effect."
                    ;;

                "Distrobox")
                    clear
                    if [[ $distro -eq 0 ]]; then
                        $pkg_manager_pacman distrobox podman
                        version=$(get_version distrobox)
                    else
                        $pkg_manager distrobox
                        version=$(get_version distrobox)
                    fi
                    echo "Distrobox installed successfully! Version: $version"
                    ;;

            esac
        done

        echo "All selected Android tools have been installed."
        read -rp "Press Enter to continue..."
    done
}
