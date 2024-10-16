#!/bin/bash

shc -f cxfs.sh -o cxfs

if [[ $? -eq 0 ]]; then
    mv cxfs ~/Documents/GitHub/carch/build/
    echo "Build successful! Binary moved to ~/Documents/github/carch/build/"
else
    echo "Build failed!"
fi

