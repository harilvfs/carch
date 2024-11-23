#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'
NC='\033[0m'

last_selected_index=0

load_scripts() {
    local script_dir="/usr/bin/scripts"
    scripts=()
    while IFS= read -r -d '' file; do
        script_name=$(basename "${file}" .sh)
        scripts+=("$script_name")
    done < <(find "$script_dir" -maxdepth 1 -name '*.sh' -print0)
    
    scripts+=("Cancel")
}

display_scripts_menu() {
    load_scripts
    clear
    echo -e "${GREEN}"
    figlet -f slant "Carch"
    echo "Version 3.0.8"
    echo -e "${YELLOW}--------------${RESET}"
    echo -e "${GREEN}A script that helps to automate Arch Linux system setup."
    echo -e "${GREEN}For more information, visit: \033[4;34mhttps://harilvfs.github.io/carch/\033[0m"
    echo -e "${NC}"

    echo "Select a script to run:"
    
    reordered_scripts=("${scripts[last_selected_index]}" "${scripts[@]:0:last_selected_index}" "${scripts[@]:last_selected_index+1}")

    selected_script=$(gum choose "${reordered_scripts[@]}")

    for i in "${!scripts[@]}"; do
        if [[ "${scripts[i]}" == "$selected_script" ]]; then
            last_selected_index=$i
            break
        fi
    done

    if [[ "$selected_script" == "Cancel" ]]; then
        clear
        exit 0
    else
        run_script "$selected_script"
    fi
}

run_script() {
    local script_name="$1"
    local script_path="/usr/bin/scripts/${script_name}.sh"

    if [[ -f "$script_path" ]]; then
        echo -e "${YELLOW}Running script: ${script_name}${RESET}"
        bash "$script_path"
    else
        echo -e "${YELLOW}Error: Script '${script_name}' not found in /usr/bin/scripts!${RESET}"
    fi
    display_scripts_menu
}

display_scripts_menu

