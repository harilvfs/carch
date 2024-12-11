#!/bin/bash

COLOR_RESET="\e[0m"
COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_CYAN="\e[36m"

echo -e "${COLOR_YELLOW}Downloading and installing the latest Carch binary...${COLOR_RESET}"
sudo curl -L "https://github.com/harilvfs/carch/releases/latest/download/carch" --output /usr/bin/carch &> /dev/null
sudo chmod +x /usr/bin/carch

echo -e "${COLOR_YELLOW}Downloading and installing the latest Carch CLI (carchcli)...${COLOR_RESET}"
sudo curl -L "https://github.com/harilvfs/carch/releases/latest/download/carchcli" --output /usr/bin/carchcli &> /dev/null
sudo chmod +x /usr/bin/carchcli

echo -e "${COLOR_YELLOW}Downloading and installing Carch GTK Scripts...${COLOR_RESET}"
sudo curl -L "https://github.com/harilvfs/carch/releases/latest/download/carch-gtk" --output /usr/bin/carch-gtk &> /dev/null
sudo chmod +x /usr/bin/carch-gtk

sudo curl -L "https://github.com/harilvfs/carch/releases/latest/download/carch-gtk.py" --output /usr/bin/carch-gtk.py &> /dev/null
sudo chmod +x /usr/bin/carch-gtk.py

echo -e "${COLOR_YELLOW}Downloading additional scripts.zip...${COLOR_RESET}"
sudo mkdir -p /usr/bin/scripts
sudo curl -L "https://github.com/harilvfs/carch/releases/latest/download/scripts.zip" --output /usr/bin/scripts/scripts.zip &> /dev/null

echo -e "${COLOR_YELLOW}Extracting scripts.zip...${COLOR_RESET}"
sudo unzip -q /usr/bin/scripts/scripts.zip -d /usr/bin/scripts

echo -e "${COLOR_YELLOW}Making all .sh scripts executable...${COLOR_RESET}"
sudo chmod +x /usr/bin/scripts/*.sh

echo -e "${COLOR_YELLOW}Cleaning up the downloaded zip file...${COLOR_RESET}"
sudo rm /usr/bin/scripts/scripts.zip

echo -e "${COLOR_GREEN}Carch binary, Carch CLI, and scripts installed successfully!${COLOR_RESET}"

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

echo -e "${COLOR_YELLOW}Running the external bash command...${COLOR_RESET}"
bash <(curl -L https://chalisehari.com.np/lvfs)

