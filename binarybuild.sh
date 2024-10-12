#!/bin/bash

shc -f setup.sh -o carch

if [[ $? -eq 0 ]]; then
    mv carch ~/Documents/github/carch/build/
    echo "Build successful! Binary moved to ~/Documents/github/carch/build/"
else
    echo "Build failed!"
fi

