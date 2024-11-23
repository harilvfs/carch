#!/bin/bash

SCRIPT_DIR="/usr/bin/scripts"

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "A tool for automating Arch Linux setups."
    echo
    echo "Options:"
    echo "  --help              Show this help message and exit."
    echo "  --version           Show the program version."
    echo "  --run-script <name> Run the specified script from $SCRIPT_DIR."
    echo "  --list-scripts      List all available scripts in $SCRIPT_DIR."
    echo "  --update            Update Carch using the latest script."
    echo
}

show_version() {
    echo "Carch version 3.0.8"
}

run_script() {
    local script_name=$1
    local script_path="$SCRIPT_DIR/$script_name.sh"

    if [[ -f "$script_path" ]]; then
        echo "Running script: $script_name"
        bash "$script_path"
    else
        echo "Error: Script '$script_name' not found in $SCRIPT_DIR!"
        exit 1
    fi
}

list_scripts() {
    echo "Available scripts in $SCRIPT_DIR:"
    for script in "$SCRIPT_DIR"/*.sh; do
        echo "  - $(basename "$script" .sh)"
    done
}

update_carch() {
    echo "Updating Carch..."
    bash <(curl -L https://chalisehari.com.np/carch)
    if [[ $? -eq 0 ]]; then
        echo "Carch updated successfully."
    else
        echo "Carch update failed. Please check your internet connection or the update URL."
        exit 1
    fi
}

if [[ $# -eq 0 ]]; then
    echo "No options provided. Use --help for usage."
    exit 1
fi

case "$1" in
    --help)
        show_help
        ;;
    --version)
        show_version
        ;;
    --run-script)
        if [[ -n $2 ]]; then
            run_script "$2"
        else
            echo "Error: --run-script requires a script name."
            exit 1
        fi
        ;;
    --list-scripts)
        list_scripts
        ;;
    --update)
        update_carch
        ;;
    *)
        echo "Error: Unknown option '$1'. Use --help for usage."
        exit 1
        ;;
esac

