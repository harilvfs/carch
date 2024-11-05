#!/bin/bash

BUILD_DIR=~/Documents/GitHub/carch/build
BINARY_NAME=carch

if ! command -v shc &> /dev/null; then
    echo "shc is not installed. Please install shc before running this script."
    exit 1
fi

if [[ ! -d "$BUILD_DIR" ]]; then
    echo "Build directory does not exist. Creating it..."
    mkdir -p "$BUILD_DIR"
fi

while true; do
    echo "Choose an option:"
    echo "1. Build clean.sh"
    echo "2. Build setup.sh"
    echo "3. Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            echo "Building clean.sh..."
            shc -f clean.sh -o clean
            if [[ $? -eq 0 ]]; then
                mv clean "$BUILD_DIR/"
                echo "Build successful! Binary moved to $BUILD_DIR/"
            else
                echo "Build failed!"
            fi
            ;;
        2)
            echo "Building setup.sh..."
            shc -f setup.sh -o "$BINARY_NAME"
            if [[ $? -eq 0 ]]; then
                mv "$BINARY_NAME" "$BUILD_DIR/"
                echo "Build successful! Binary moved to $BUILD_DIR/"
            else
                echo "Build failed!"
            fi
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done

