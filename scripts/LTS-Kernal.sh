#!/bin/bash

tput init
tput clear

GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
figlet -f slant "Lts Kernel"
echo -e "${ENDCOLOR}"

check_current_kernel() {
    CURRENT_KERNEL=$(uname -r)
    echo -e "${BLUE}:: Current kernel version: ${GREEN}$CURRENT_KERNEL${ENDCOLOR}"
    if [[ "$CURRENT_KERNEL" == *"lts"* ]]; then
        echo -e "${GREEN}You are already using the LTS kernel. Skipping the installation.${ENDCOLOR}"
        exit 0
    fi
}

install_lts_kernel() {
    echo -e "${GREEN}:: Installing LTS kernel and headers...${ENDCOLOR}"
    sudo pacman -S --needed linux-lts linux-lts-docs linux-lts-headers
}

configure_grub() {
    echo -e "${GREEN}:: Updating GRUB configuration...${ENDCOLOR}"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

prompt_continue() {
    choice=$(gum choose "Yes" "No" "Exit")
    case "$choice" in
        "Yes") return 0 ;;
        "No") return 1 ;;
        "Exit") echo "Exiting..."; exit 0 ;;
    esac
}

echo -e "${RED}Warning: If you are using systemd or EFI boot and not GRUB, you will need to manually select or set up the LTS kernel after installation.${ENDCOLOR}"
echo -e "${RED}If you don't know about kernel changes, it's recommended to Exit.${ENDCOLOR}"

echo -e "\n${BLUE}Choose an option:${ENDCOLOR}"
echo -e "${GREEN}Yes:${NC} Removes the current kernel and installs the LTS kernel."
echo -e "${GREEN}No:${NC} Installs the LTS kernel without removing the current kernel."
echo -e "${GREEN}Exit:${NC} Cancels the installation.\n"

echo "Do you want to continue with the kernel installation?"
if prompt_continue; then
    install_lts_kernel
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
    install_lts_kernel
    configure_grub
fi

echo -e "${GREEN}LTS kernel setup completed. Please check GRUB or select the LTS kernel from the GRUB menu.${ENDCOLOR}"

