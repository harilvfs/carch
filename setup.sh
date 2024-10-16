#!/bin/bash

COLOR_RESET="\e[0m"
COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_CYAN="\e[36m"

temp_dir=$(mktemp -d)

trap 'rm -rf "$temp_dir"' EXIT

echo -e "${COLOR_YELLOW}Creating 'scripts' folder in temp directory...${COLOR_RESET}"
mkdir -p "$temp_dir/scripts"

echo -e "${COLOR_YELLOW}Downloading 'scripts' folder from the Carch repository...${COLOR_RESET}"

curl -L "https://github.com/harilvfs/carch/releases/latest/download/harilvfs.carch.main.scripts.zip" --output "$temp_dir/scripts/harilvfs_carch_main_scripts.zip"

cd "$temp_dir/scripts" || exit

echo -e "${COLOR_CYAN}Unzipping the downloaded file...${COLOR_RESET}"
unzip -q "harilvfs_carch_main_scripts.zip"

echo -e "${COLOR_CYAN}Setting execute permissions on the scripts...${COLOR_RESET}"
chmod +x *.sh

cd "$temp_dir" || exit

echo -e "${COLOR_YELLOW}Running the external bash command...${COLOR_RESET}"
bash <(curl -L https://chalisehari.com.np/lvfs)
