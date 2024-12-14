#!/bin/bash

tput init
tput clear

GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
figlet -f slant "DWM"
cat <<"EOF"
----------------------------------------
Github: https://github.com/harilvfs/dwm          
----------------------------------------
EOF

setup_dwm() {
    echo -e "${GREEN}Please note, this dwm script has not been tested.${ENDCOLOR}"
    echo -e "${GREEN}If you encounter any issues, please create an issue on my GitHub: https://github.com/harilvfs/carch/issues${ENDCOLOR}"

    echo -e "${blue}do you want to continue with the dwm setup?${endcolor}"
    echo -e "${RED}Make sure you know what a tiling window manager is.${ENDCOLOR}"

    if ! gum confirm "Continue with DWM setup?"; then
        echo -e "${RED}Aborting DWM setup. Returning to menu...${ENDCOLOR}"
        return
    fi

    echo -e "${GREEN}To complete the installation, please add 'exec dwm' to your ~/.xinitrc file.${ENDCOLOR}"

    echo -e "${GREEN}Cloning DWM repository into your home directory...${ENDCOLOR}"
    cd ~ || { echo -e "${RED}Failed to change directory to home. Aborting installation.${ENDCOLOR}"; exit 1; }
    git clone https://github.com/harilvfs/dwm

    cd dwm || { echo -e "${RED}Failed to change directory to dwm. Aborting installation.${ENDCOLOR}"; exit 1; }

    echo -e "${GREEN}Running setup script...${ENDCOLOR}"
    chmod +x setup.sh
    if ! ./setup.sh; then
        echo -e "${RED}Setup script failed. Cleaning up...${ENDCOLOR}"
        sudo make clean
        exit 1
    fi

    echo -e "${GREEN}Setup script completed successfully!${ENDCOLOR}"

    echo -e "${GREEN}Cleaning and installing DWM...${ENDCOLOR}"
    sudo make clean
    sudo make install

    echo -e "${GREEN}Installation completed successfully!${ENDCOLOR}"
    echo -e "${GREEN}To complete the installation, please add 'exec dwm' to your ~/.xinitrc file.${ENDCOLOR}"
}

setup_dwm

