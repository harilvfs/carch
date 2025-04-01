#!/bin/bash

# Install dependencies via pacman
pacman -Syu --noconfirm
pacman -S --noconfirm figlet fzf

# List installed packages for verification
echo "Installed packages:"
pacman -Q figlet fzf
