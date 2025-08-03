#!/usr/bin/env bash

install_virtualization() {
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
                        install_package "qemu-base" ""
                        install_package "virt-manager" ""
                        install_package "virt-viewer" ""
                        install_package "dnsmasq" ""
                        install_package "vde2" ""
                        install_package "bridge-utils" ""
                        install_package "openbsd-netcat" ""
                        install_package "ebtables" ""
                        install_package "iptables-nft" ""
                        install_package "libguestfs" ""
                        sudo systemctl enable --now libvirtd.service
                        sudo usermod -aG libvirt "$USER"
                        ;;
                    "Fedora")
                        install_package "@virtualization" ""
                        sudo systemctl enable --now libvirtd
                        sudo usermod -aG libvirt "$USER"
                        ;;
                    "openSUSE")
                        sudo zypper addrepo https://download.opensuse.org/repositories/Virtualization/openSUSE_Tumbleweed/Virtualization.repo
                        sudo zypper refresh
                        install_package "qemu" ""
                        sudo systemctl enable --now libvirtd
                        sudo usermod -aG libvirt "$USER"
                        ;;
                esac
                ;;

            "VirtualBox")
                clear
                case "$DISTRO" in
                    "Arch")
                        install_package "virtualbox" ""
                        install_package "virtualbox-host-dkms" ""
                        sudo usermod -aG vboxusers "$USER"
                        sudo modprobe vboxdrv
                        ;;
                    *)
                        install_package "virtualbox" ""
                        sudo usermod -aG vboxusers "$USER"
                        ;;
                esac
                echo "Note: You may need to log out and back in for group changes to take effect."
                ;;

            "Distrobox")
                clear
                install_package "distrobox" ""
                install_package "podman" ""
                ;;
            "Back to Main Menu")
                return
                ;;
        esac
        read -p "$(printf "\n%bPress Enter to continue...%b" "$GREEN" "$NC")"
    done
}
