#!/bin/bash

BUILD_DIR=~/Documents/GitHub/carch/build
BINARY_NAME=carch

if [[ ! -d "$BUILD_DIR" ]]; then
    echo "Build directory does not exist. Creating it..."
    mkdir -p "$BUILD_DIR"
fi

if [[ -f "$BUILD_DIR/$BINARY_NAME" ]]; then
    echo "Binary already exists. Removing the old binary..."
    rm "$BUILD_DIR/$BINARY_NAME"
fi

echo "Building the binary..."
shc -f setup.sh -o "$BINARY_NAME"

if [[ $? -eq 0 ]]; then
    mv "$BINARY_NAME" "$BUILD_DIR/"
    echo "Build successful! Binary moved to $BUILD_DIR/"
else
    echo "Build failed!"
    exit 1
fi

