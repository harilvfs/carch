#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m'

last_selected_index=0  

load_scripts() {
    local script_dir="./scripts"
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
    figlet -f slant "Arch Linux System Setup"
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
    echo "Running ${script_name}..."
    if bash "./scripts/${script_name}.sh"; then
        echo "${script_name} completed successfully. Press Enter to return to the menu."
    else
        echo "${script_name} failed to complete. Press Enter to return to the menu."
    fi
    read -r
    display_scripts_menu
}

display_scripts_menu

