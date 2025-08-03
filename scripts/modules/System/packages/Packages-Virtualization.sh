#!/usr/bin/env bash

install_virtualization() {
    case "$DISTRO" in
        "Arch")
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
        local options=("QEMU/KVM" "VirtualBox" "Distrobox" "Back to Main Menu")

        show_menu "Virtualization Tools Installation" "${options[@]}"
        get_choice "${#options[@]}"
        local choice_index=$?
        local selection="${options[$((choice_index - 1))]}"

        case "$selection" in
            "QEMU/KVM")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_pacman qemu-base virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat ebtables iptables-nft libguestfs
                        sudo systemctl enable --now libvirtd.service
                        sudo usermod -aG libvirt "$USER"
                        ;;
                    "Fedora")
                        $pkg_manager @virtualization
                        sudo systemctl enable --now libvirtd
                        sudo usermod -aG libvirt "$USER"
                        ;;
                    "openSUSE")
                        sudo zypper addrepo https://download.opensuse.org/repositories/Virtualization/openSUSE_Tumbleweed/Virtualization.repo
                        sudo zypper refresh
                        sudo zypper install -y qemu
                        sudo systemctl enable --now libvirtd
                        sudo usermod -aG libvirt "$USER"
                        ;;
                esac
                ;;

            "VirtualBox")
                clear
                case "$DISTRO" in
                    "Arch")
                        $pkg_manager_pacman virtualbox virtualbox-host-dkms
                        sudo usermod -aG vboxusers "$USER"
                        sudo modprobe vboxdrv
                        ;;
                    *)
                        $pkg_manager virtualbox
                        sudo usermod -aG vboxusers "$USER"
                        ;;
                esac
                echo "Note: You may need to log out and back in for group changes to take effect."
                ;;

            "Distrobox")
                clear
                case "$DISTRO" in
                    "Arch" | "Fedora" | "openSUSE")
                        $pkg_manager distrobox podman
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
