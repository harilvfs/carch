#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1

check_curl() {
    if ! command -v curl &> /dev/null; then
        echo -e "${YELLOW}Installing curl...${NC}"
        case "$DISTRO" in
            "Arch") sudo pacman -S --noconfirm curl ;;
            "Fedora") sudo dnf install -y curl ;;
            "openSUSE") sudo zypper install -y curl ;;
            *)
                exit 1
                ;;
        esac
    fi
}

install_bun() {
    echo -e "${GREEN}Installing Bun...${NC}"
    curl -fsSL https://bun.sh/install | bash

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Bun has been installed successfully!${NC}"
    else
        echo -e "${RED}Failed to install Bun.${NC}"
        exit 1
    fi
}

main() {
    check_curl
    install_bun
}

main
