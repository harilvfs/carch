#!/usr/bin/env bash

clear

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

if ! command -v fzf &> /dev/null; then
    echo -e "${RED}${BOLD}Error: fzf is not installed${NC}"
    echo -e "${YELLOW}Please install fzf before running this script:${NC}"
    echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install fzf"
    echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S fzf"
    exit 1
fi

echo -e "${TEAL}"
cat << "EOF"

Standard is best for terminals that don't support image rendering
PNG option should only be used in terminals that support image rendering

EOF
echo -e "${NC}"

FASTFETCH_DIR="$HOME/.config/fastfetch"
BACKUP_DIR="$HOME/.config/fastfetch_backup"

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

fzf_confirm() {
    local prompt="$1"
    local options=("Yes" "No" "Back to Menu")
    local selected=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                     --height=40% \
                                                     --prompt="$prompt " \
                                                     --header="Confirm" \
                                                     --pointer="➤" \
                                                     --color='fg:white,fg+:green,bg+:black,pointer:green')

    echo "$selected"
}

fzf_select() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                     --height=40% \
                                                     --prompt="$prompt " \
                                                     --header="Select Option" \
                                                     --pointer="➤" \
                                                     --color='fg:white,fg+:blue,bg+:black,pointer:blue')
    echo "$selected"
}

check_command() {
    local cmd=$1
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Required command '$cmd' not found. Please install it and try again.${NC}"
        return 1
    fi
    return 0
}

check_fastfetch() {
    if command -v fastfetch &> /dev/null; then
        echo -e "${GREEN}Fastfetch is already installed.${NC}"
    else
        echo -e "${CYAN}Fastfetch is not installed. Installing...${NC}"

        if [ -x "$(command -v pacman)" ]; then
            sudo pacman -S fastfetch git --noconfirm
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf install fastfetch git -y
        else
            echo -e "${RED}Unsupported package manager! Please install Fastfetch manually.${NC}"
            exit 1
        fi
        echo -e "${GREEN}Fastfetch has been installed.${NC}"
    fi
}

handle_existing_config() {
    if [ -d "$FASTFETCH_DIR" ]; then
        echo -e "${YELLOW}Existing Fastfetch configuration found.${NC}"

        choice=$(fzf_confirm "Do you want to back up your existing Fastfetch configuration?")

        case $choice in
            "Yes")
                if [ ! -d "$BACKUP_DIR" ]; then
                    echo -e "${CYAN}Creating backup directory...${NC}"
                    mkdir -p "$BACKUP_DIR"
                fi
                echo -e "${CYAN}Backing up existing Fastfetch configuration...${NC}"
                cp -r "$FASTFETCH_DIR"/* "$BACKUP_DIR/" 2> /dev/null
                echo -e "${GREEN}Backup completed to $BACKUP_DIR${NC}"
                return 0
                ;;
            "No")
                echo -e "${YELLOW}Proceeding without backup...${NC}"
                return 0
                ;;
            "Back to Menu")
                clear
                main
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Returning to menu...${NC}"
                clear
                main
                exit 0
                ;;
        esac
    else
        mkdir -p "$FASTFETCH_DIR"
    fi
}

setup_standard_fastfetch() {
    check_fastfetch
    handle_existing_config

    echo -e "${CYAN}Setting up standard Fastfetch configuration...${NC}"

    echo -e "${CYAN}Downloading standard configuration...${NC}"
    curl -sSLo "$FASTFETCH_DIR/config.jsonc" "https://raw.githubusercontent.com/harilvfs/fastfetch/refs/heads/old-days/fastfetch/config.jsonc"

    echo -e "${GREEN}Standard Fastfetch setup completed!${NC}"
}

setup_png_fastfetch() {
    check_fastfetch
    if ! handle_existing_config; then
        return
    fi

    echo -e "${CYAN}Setting up Fastfetch with custom PNG support...${NC}"
    echo -e "${CYAN}Cloning Fastfetch repository directly...${NC}"

    rm -rf "$FASTFETCH_DIR"/* 2> /dev/null
    mkdir -p "$FASTFETCH_DIR"

    git clone https://github.com/harilvfs/fastfetch "$FASTFETCH_DIR"

    echo -e "${CYAN}Cleaning up unnecessary files...${NC}"
    rm -rf "$FASTFETCH_DIR/.git" "$FASTFETCH_DIR/LICENSE" "$FASTFETCH_DIR/README.md"

    echo -e "${GREEN}Fastfetch with PNG support setup completed!${NC}"
}

main() {
    check_command git || {
                           echo -e "${RED}Please install git and try again.${NC}"
                                                                                   exit 1
    }

    clear

    echo -e "${TEAL}"
    cat << "EOF"

Standard is best for terminals that don't support image rendering
PNG option should only be used in terminals that support image rendering

EOF
    echo -e "${NC}"

    choice=$(fzf_select "Choose the setup option:" "Fastfetch Standard" "Fastfetch with PNG" "Exit")

    case $choice in
        "Fastfetch Standard")
            setup_standard_fastfetch
            echo -e "${GREEN}Setup completed! You can now run 'fastfetch' to see the results.${NC}"
            exit 0
            ;;
        "Fastfetch with PNG")
            setup_png_fastfetch
            echo -e "${GREEN}Setup completed! You can now run 'fastfetch' to see the results.${NC}"
            exit 0
            ;;
        "Exit")
            echo -e "${RED}Exiting the script.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option selected! Please try again.${NC}"
            main
            ;;
    esac
}

main
