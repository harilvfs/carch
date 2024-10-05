#!/bin/bash

tput init
tput clear
export RED='\033[0;31m'  
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' 

tput civis

display_main_menu() {
    local selected=0
    while true; do
        clear
        echo -e "${CYAN}============================="
        echo -e "    Linux System Arch Setup    "
        echo -e "=============================${NC}"
        
        options=("Arch Setup" "Help & Info" "Exit")
        
        for i in "${!options[@]}"; do
            if [[ $i -eq $selected ]]; then
                echo -e "${GREEN}> ${options[i]}${NC}"
            else
                echo "  ${options[i]}"
            fi
        done

        read -sn 1 input
        case $input in
            $'\x1B') read -sn 2 input
                case $input in
                    '[A') ((selected--));; 
                    '[B') ((selected++));; 
                esac ;;
            "") 
                case $selected in
                    0) display_submenu ;;
                    1) display_help ;;
                    2) exit ;;
                esac ;;
        esac
        
        ((selected<0)) && selected=0
        ((selected>${#options[@]}-1)) && selected=${#options[@]}-1
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
    local selected=0
    while true; do
        clear
        echo -e "${CYAN}=============================="
        echo -e "      Arch Setup Options       "
        echo -e "==============================${NC}"

        for i in "${!scripts[@]}"; do
            if [[ $i -eq $selected ]]; then
                echo -e "${GREEN}> ${scripts[i]}${NC}"
            else
                echo "  ${scripts[i]}"
            fi
        done

        if [[ $selected -eq ${#scripts[@]} ]]; then
            echo -e "${GREEN}> Exit${NC}"
        else
            echo "  Exit"
        fi

        read -sn 1 input
        case $input in
            $'\x1B') 
                read -sn 2 input
                case $input in
                    '[A') ((selected--));; 
                    '[B') ((selected++));;
                esac ;;
            "")
                if [[ $selected -eq ${#scripts[@]} ]]; then
                    break  
                else
                    run_script "${scripts[selected]}"  
                fi ;;
        esac

        ((selected < 0)) && selected=0
        ((selected > ${#scripts[@]})) && selected=${#scripts[@]}
    done
}


run_script() {
    local script_name="$1"
    clear
    echo -e "${CYAN}Running ${script_name}...${NC}"
    bash "./scripts/${script_name}.sh" || echo "Error: Could not run ${script_name}.sh"
    echo "Press Enter to return..."
    read -r
}

display_help() {
    load_scripts  
    clear
    echo -e "${CYAN}Help & Information${NC}"
    echo "This is the help section where you can view all available setup scripts."
    echo ""
    echo "Available scripts in the Arch Setup submenu:"
    
    for script in "${scripts[@]}"; do
        echo "- ${script}"
    done
    
    echo ""
    echo "Press Enter to return to the main menu..."
    read -r
}

cleanup() {
    tput cnorm  
}
trap cleanup EXIT  

display_main_menu