#!/usr/bin/env bash

# Installs the Long-Term Support (LTS) kernel for enhanced stability and extended support.

clear

GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
CYAN="\e[36m"
NC="\e[0m"
ENDCOLOR="\e[0m"

fzf_confirm() {
    local options=("Yes" "No" "Exit")
    local selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose an option: " --height=10 --layout=reverse --border)
    
    case "$selected" in
        "Yes") return 0 ;;
        "No") return 1 ;;
        "Exit") echo "Exiting..."; exit 0 ;;
        *) echo "Invalid selection"; exit 1 ;;
    esac
}

echo -e "${BLUE}"
if command -v figlet &>/dev/null; then
    figlet -f slant "LTS Kernel"
else
    echo "========== LTS Kernel Setup =========="
fi
echo -e "${ENDCOLOR}"

check_current_kernel() {
    CURRENT_KERNEL=$(uname -r)
    echo -e "${BLUE}:: Current kernel version: ${GREEN}$CURRENT_KERNEL${ENDCOLOR}"
    if [[ "$CURRENT_KERNEL" == *"lts"* ]]; then
        echo -e "${GREEN}You are already using the LTS kernel. Skipping the installation.${ENDCOLOR}"
        exit 0
    fi
}

install_lts_kernel_arch() {
    echo -e "${GREEN}:: Installing LTS kernel and headers on Arch...${ENDCOLOR}"
    sudo pacman -S --needed linux-lts linux-lts-docs linux-lts-headers
}

install_lts_kernel_fedora() {
    echo -e "${RED}LTS kernel is not available as a package in Fedora.${ENDCOLOR}"
    echo -e "${CYAN}Fedora's default kernel is already a stable and good option for your system.${ENDCOLOR}"
    echo -e "${CYAN}It's recommended to stick with the Fedora kernel unless you have a specific need for LTS.${ENDCOLOR}"
    exit 0
}

configure_grub() {
    echo -e "${GREEN}:: Updating GRUB configuration...${ENDCOLOR}"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

echo -e "${RED}Warning: If you are using systemd or EFI boot and not GRUB, you will need to manually select or set up the LTS kernel after installation.${ENDCOLOR}"
echo -e "${RED}If you don't know about kernel changes, it's recommended to Exit.${ENDCOLOR}"
echo -e "\n${BLUE}Choose an option:${ENDCOLOR}"
echo -e "${GREEN}Yes:${NC} Removes the current kernel and installs the LTS kernel."
echo -e "${GREEN}No:${NC} Installs the LTS kernel without removing the current kernel."
echo -e "${GREEN}Exit:${NC} Cancels the installation.\n"

echo "Do you want to continue with the kernel installation?"

if fzf_confirm; then
    if [ -x "$(command -v pacman)" ]; then
        install_lts_kernel_arch
    elif [ -x "$(command -v dnf)" ]; then
        install_lts_kernel_fedora
    else
        echo -e "${RED}Unsupported package manager. Exiting...${ENDCOLOR}"
        exit 1
    fi
    echo -e "${GREEN}:: Removing the current kernel...${ENDCOLOR}"
    CURRENT_KERNEL_NAME=$(uname -r | sed 's/-[^-]*$//')
    if [[ "$CURRENT_KERNEL_NAME" != "linux" ]]; then
        echo -e "${RED}:: Current kernel name does not match expected 'linux'. Cannot remove kernel.${ENDCOLOR}"
        exit 1
    fi
    sudo pacman -Rns --noconfirm "$CURRENT_KERNEL_NAME"
    echo -e "${GREEN}:: Removed the current kernel.${ENDCOLOR}"
    configure_grub
else
    echo ":: Installing the LTS kernel alongside the current kernel..."
    if [ -x "$(command -v pacman)" ]; then
        install_lts_kernel_arch
    elif [ -x "$(command -v dnf)" ]; then
        install_lts_kernel_fedora
    else
        echo -e "${RED}Unsupported package manager. Exiting...${ENDCOLOR}"
        exit 1
    fi
    configure_grub
fi

echo -e "${GREEN}LTS kernel setup completed. Please check GRUB or select the LTS kernel from the GRUB menu.${ENDCOLOR}"
