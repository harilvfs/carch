#!/bin/bash

export RED='\033[0;31m'  
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

last_main_menu_index=0  
last_submenu_index=0    

display_main_menu() {
    while true; do
        choice=$(whiptail --title "Arch Linux System Setup Script" \
                          --menu "Choose an option\n------------------\nUse Arrow Up & Down to Navigate\n----------------------------------" 15 65 4 \
                          --default-item "$((last_main_menu_index + 1))" \
                          "1" "Arch Setup" \
                          "2" "Help & Info" \
                          "3" "Exit" 3>&1 1>&2 2>&3)

        case $choice in
            1) last_main_menu_index=0; display_submenu ;;
            2) last_main_menu_index=1; display_help ;;
            3) last_main_menu_index=2; clear; exit 0 ;;
        esac
    done
}

load_scripts() {
    local script_dir="./scripts"
    scripts=()
    while IFS= read -r -d '' file; do
        script_name=$(basename "${file}" .sh)
        scripts+=("$script_name")
    done < <(find "$script_dir" -maxdepth 1 -name '*.sh' -print0)
}

display_submenu() {
    load_scripts
    local search_query=""
    
    while true; do
        if [ -n "$search_query" ]; then
            search_scripts "$search_query"
        else
            filtered_scripts=("${scripts[@]}")
        fi

        script_list=()
        script_list+=("/" "Search (press '/' to enter search mode)")
        for i in "${!filtered_scripts[@]}"; do
            script_list+=("$((i + 1))" "${filtered_scripts[i]}")
        done

        if [ -n "$search_query" ]; then
            script_list+=("$(( ${#filtered_scripts[@]} + 2 ))" "Back to Menu")
        else
            script_list+=("$(( ${#filtered_scripts[@]} + 2 ))" "Exit")
        fi

        num_scripts=${#filtered_scripts[@]}
        
        menu_height=$((num_scripts + 8))
        ((menu_height < 15)) && menu_height=15
        ((menu_height > 25)) && menu_height=25

        CHOICE=$(dialog --default-item "$((last_submenu_index + 1))" \
                        --title "Arch Setup Options" \
                        --menu "Select a script to run\n------------------------\nUse Arrow Up & Down to Navigate" \
                        "$menu_height" 60 ${#script_list[@]} "${script_list[@]}" 3>&1 1>&2 2>&3)

        EXIT_STATUS=$?

        if [ $EXIT_STATUS -eq 1 ]; then
            break
        fi

        if [[ "$CHOICE" == "/" ]]; then
            search_query=$(dialog --title "Search" --inputbox "Enter search term:" 10 60 "$search_query" 3>&1 1>&2 2>&3)
            if [ -z "$search_query" ]; then
                filtered_scripts=("${scripts[@]}")
            fi
            continue
        fi

        selected=$((CHOICE - 1))

        if [[ "$search_query" && $selected -ge ${#filtered_scripts[@]} ]]; then
            search_query=""
        elif [[ ! "$search_query" && $selected -ge ${#filtered_scripts[@]} ]]; then
            break
        elif [[ $selected -lt ${#filtered_scripts[@]} ]]; then
            last_submenu_index=$selected  
            run_script "${filtered_scripts[selected]}"
        fi
    done
}

search_scripts() {
    local search_query="$1"
    filtered_scripts=()
    for script in "${scripts[@]}"; do
        if [[ "${script,,}" == *"${search_query,,}"* ]]; then
            filtered_scripts+=("$script")
        fi
    done
}

run_script() {
    local script_name="$1"

    if [ "$script_name" = "Exit" ] || [ "$script_name" = "0" ]; then
        echo "Script aborted. Press Enter to return to the menu."
        read -r
        return 1  
    fi

    echo "Running ${script_name}..."

    if bash "./scripts/${script_name}.sh"; then
        echo "${script_name} completed successfully. Press Enter to return to the menu."
    else
        echo "${script_name} failed to complete. Press Enter to return to the menu."
    fi

    read -r  
}

display_help() {
    whiptail --msgbox "This tool helps to automate Arch Linux setup.\n\nSelect 'Arch Setup' to install packages and configure the system.\nFor more information, visit: https://harilvfs.github.io/carch/" 15 65
}

display_main_menu

