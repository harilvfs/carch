#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

print_message() {
    local color="$1"
    local message="$2"
    printf "%b%s%b\n" "$color" "$message" "$ENDCOLOR"
}

confirm() {
    while true; do
        read -p "$(printf "%b%s%b" "$CYAN" "$1 [y/N]: " "$ENDCOLOR")" answer
        case ${answer,,} in
            y | yes) return 0 ;;
            n | no | "") return 1 ;;
            *) print_message "$YELLOW" "Please answer with y/yes or n/no." ;;
        esac
    done
}

check_current_kernel() {
    CURRENT_KERNEL=$(uname -r)
    echo -e "${TEAL}:: Current kernel version: ${GREEN}$CURRENT_KERNEL${ENDCOLOR}"
    if [[ "$CURRENT_KERNEL" == *"lts"* ]]; then
        echo -e "${GREEN}You are already using the LTS kernel. Skipping the installation.${ENDCOLOR}"
        exit 0
    fi
}

install_lts_kernel_arch() {
    echo -e "${GREEN}:: Installing LTS kernel and headers on Arch...${ENDCOLOR}"
    sudo pacman -S --needed linux-lts linux-lts-docs linux-lts-headers
}

configure_grub() {
    echo -e "${GREEN}:: Updating GRUB configuration...${ENDCOLOR}"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

check_current_kernel

if [ -x "$(command -v pacman)" ]; then
    echo -e "${RED}Warning: If you are using systemd or EFI boot and not GRUB, you will need to manually select or set up the LTS kernel after installation.${ENDCOLOR}"
    echo -e "${TEAL}This script will install the LTS kernel alongside your current kernel.${ENDCOLOR}"
    echo -e "${TEAL}Your current kernel will NOT be removed.${ENDCOLOR}"
elif [ -x "$(command -v dnf)" ]; then
    echo -e "${RED}Note: LTS kernel is not available as a package in Fedora.${ENDCOLOR}"
    echo -e "${CYAN}Fedora's default kernel is already a stable and good option for your system.${ENDCOLOR}"
    echo -e "${CYAN}It's recommended to stick with the Fedora kernel unless you have a specific need for LTS.${ENDCOLOR}"
    exit 0
elif [ -x "$(command -v zypper)" ]; then
    echo -e "${RED}Note: LTS kernel is not available as a package in openSUSE.${ENDCOLOR}"
    echo -e "${CYAN}openSUSE's default kernel is already a stable and good option for your system.${ENDCOLOR}"
    echo -e "${CYAN}It's recommended to stick with the openSUSE kernel unless you have a specific need for LTS.${ENDCOLOR}"
    exit 0
else
    echo -e "${RED}Unsupported package manager. Exiting...${ENDCOLOR}"
    exit 1
fi

echo ""

if confirm "Do you want to continue with LTS kernel installation?"; then
    if [ -x "$(command -v pacman)" ]; then
        install_lts_kernel_arch
    elif [ -x "$(command -v dnf)" ]; then
        install_lts_kernel_fedora
    elif [ -x "$(command -v zypper)" ]; then
        install_lts_kernel_opensuse
    fi

    configure_grub
    echo -e "${GREEN}LTS kernel setup completed. Please check GRUB or select the LTS kernel from the GRUB menu.${ENDCOLOR}"
else
    echo -e "${CYAN}Installation canceled.${ENDCOLOR}"
    exit 0
fi
