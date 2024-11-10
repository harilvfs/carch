#!/bin/bash

COLOR_RESET="\e[0m"
COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_CYAN="\e[36m"

temp_dir=$(mktemp -d)

trap 'rm -rf "$temp_dir"' EXIT

echo -e "${COLOR_YELLOW}Setting Carch Script...${COLOR_RESET}"
mkdir -p "$temp_dir/scripts" &> /dev/null &

curl -L "https://github.com/harilvfs/carch/releases/latest/download/carchscripts.zip" --output "$temp_dir/scripts/carchscripts.zip" &> /dev/null &

wait

cd "$temp_dir/scripts" || exit

echo -e "${COLOR_CYAN}Processing Carch Script...${COLOR_RESET}"
unzip -q "carchscripts.zip" &> /dev/null &

wait

echo -e "${COLOR_CYAN}Setting execute permissions on the scripts...${COLOR_RESET}"
chmod +x *.sh &> /dev/null &

wait

echo -e "${COLOR_YELLOW}Downloading and installing the latest Carch binary...${COLOR_RESET}"
sudo curl -L "https://github.com/harilvfs/carch/releases/latest/download/carch" --output /usr/bin/carch &> /dev/null
sudo chmod +x /usr/bin/carch

echo -e "${COLOR_GREEN}Carch binary installed successfully!${COLOR_RESET}"

echo -e "${COLOR_YELLOW}Creating Carch Desktop Entry...${COLOR_RESET}"
sudo tee /usr/share/applications/carch.desktop > /dev/null <<EOL
[Desktop Entry]
Name=Carch
Comment=An automated script for quick & easy Arch Linux system setup.
Exec=/usr/bin/carch
Icon=utilities-terminal
Type=Application
Terminal=true
Categories=Utility;
EOL

echo -e "${COLOR_GREEN}Carch Desktop Entry created successfully!${COLOR_RESET}"

cd "$temp_dir" || exit

echo -e "${COLOR_YELLOW}Running the external bash command...${COLOR_RESET}"
bash <(curl -L https://chalisehari.com.np/lvfs)

