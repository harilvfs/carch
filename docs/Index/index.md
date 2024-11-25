[![](https://dcbadge.limes.pink/api/server/https://discord.gg/HBySRyymyZ?logoColor=ff6b6b)](https://discord.gg/HBySRyymyZ) [![Discord invite][discord-badge]][discord-link] ![Twitch Status](https://img.shields.io/twitch/status/aayushchalese?style=for-the-badge&color=blue&logo=twitch) [![Telegram Channel](https://img.shields.io/badge/Telegram-Carch-blue?style=for-the-badge&logo=telegram)](https://t.me/harilvfs) 

<a href="https://chalisehari.com.np"><img alt="Visit the website" height="40" src="https://cdn.jsdelivr.net/npm/@intergrav/devins-badges@3/assets/cozy/documentation/website_vector.svg"></a>

# Carch Documentation

**Carch** is a user-friendly Bash script that simplifies the setup process for Arch and Arch-based Linux systems. This documentation serves as a guide for using, contributing to, and understanding the features of Carch.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [CLI Commands](#cli-commands)
- [GTK](#gtk)
- [Aur](#aur)
- [Script Overview](#scripts)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [Code of Conduct](#code-of-conduct)
- [License](#license)
- [Contact](#contact)
- [Acknowledgments](#acknowledgments)
- [Inspiration](#inspiration)

## Introduction

<img src="https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/docs/assets/introduction.webp" width="50" />

Carch aims to automate and streamline the initial setup of Arch Linux, making it easier for users to configure their systems efficiently. The script encompasses various setup tasks, including package installations, theme configurations, and window manager setups.

## Features

<img src="https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/docs/assets/feature.webp" width="50" />

#### Easy Setup
- Quick and straightforward installation of essential packages.

#### TUI Navigation
- A text-based user interface that enhances user experience.

#### Multiple Scripts 
- Automate the setup of various environments, including Dwm and Hyprland.

#### Active Development 
- Continuous updates and new features based on community feedback.

![Carch Screenshots](https://github.com/harilvfs/carch/raw/main/source/carchv3.0.gif)

## Installation

<img src="https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/docs/assets/installation.webp" width="50" /> 

**To install Carch, execute the following command in your terminal:**

```bash
bash <(curl -L https://chalisehari.com.np/carch)
```

## Usage

<img src="https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/docs/assets/usages.webp" width="50" />

<strong>Simply run Carch by entering carch in your terminal.</strong>
```bash
carch
```

> [!Tip]
> You don't need to run the installation script every time. You can run it once, and then simply type carch in your terminal whenever you want to automatically execute the Carch script.

## CLI Commands  

Carch now supports CLI commands! Use `carchcli` with the following options:  

```bash
Usage: carchcli [OPTIONS]

A tool for automating Arch Linux setups.

Options:
 --help               Show this help message and exit.
 --version            Show the program version.
 --run-script <name>  Run the specified script from /usr/bin/scripts.
 --list-scripts       List all available scripts in /usr/bin/scripts.
 --update             Update Carch using the latest script.
```

   - `--help` - Displays the help message.  
   - `--update` - Updates Carch to the latest script version.  
   - `--version` - Shows the current version of Carch.  
   - `--run-script <name>` - Executes the specified script.  
   - `--list-scripts` - Lists all available scripts.  

## GTK
**The GTK version of Carch is available.**

> [!CAUTION]
> The GTK version of Carch is currently under development. <br>
> It’s not fully ready for use and needs some script updates to work properly. You may try it now as you would with the usual Carch script.

**How to Install and Use 📦**

<img src="https://raw.githubusercontent.com/smritics/linuxcli/refs/heads/main/docs/assets/arrowdown.webp" width="20" />

### Prerequisites

Simply run the main script:

```bash
bash <(curl -L https://chalisehari.com.np/carch)
```

Once done, you can launch the Carch GTK interface by typing:

```
carch-gtk
```


> **Note:** You can also run the Carch GTK interface after installing it from the AUR.



### From Source

Before you start, you'll need to install `Python` dependencies.

On Arch Linux:

```bash
sudo pacman -S python
```

Using AUR (with `paru` or `yay`):

```bash
paru -S python
# or
yay -S python
```

### Install and Run Carch

Clone the Carch repository and run the GTK script:

```bash
git clone https://github.com/harilvfs/carch
cd carch
python3 carch-gtk.py
```

> [!NOTE]
> If any errors pop up while running the script, they are likely related to missing dependencies. Make sure to install all required Python dependencies.

## Aur
[![Packaging status](https://repology.org/badge/vertical-allrepos/carch.svg)](https://repology.org/project/carch/versions)

![AUR Version](https://img.shields.io/aur/version/carch-git?style=for-the-badge&color=blue&logo=arch-linux&label=%5BAUR%5D%20carch-git&logocolor=blue)

**Carch is also available in the [AUR](https://aur.archlinux.org/) package repository.**

[Package](https://aur.archlinux.org/packages/carch-git) **`carch-git`**

You can install it using an AUR package manager.
 - [`paru`](https://aur.archlinux.org/packages/paru-bin)
 - [`yay`](https://aur.archlinux.org/packages/yay-bin)

Select `<packager>` then

```bash
<packager> -S carch-git
```

You can also install it using a package build.

```bash
git clone https://aur.archlinux.org/carch-git.git
cd carch-git
makepkg -si
```

> [!NOTE]
> To access the latest commit or updates of `Carch`, you can use the command line instead of the AUR.<br>
> The AUR package may take some time to update, so using the command line will ensure you get the latest version.


## Scripts

<img src="https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/docs/assets/terminal.webp" width="50" /> 

#### Carch comes with the following scripts to configure various aspects of your Arch-based system:

##### Dwm Setup
- Quickly sets up the Dwm window manager with a single-click script, using my customized configuration.

##### Hyprland Setup
- Installs the Hyprland compositor along with my pre-configured dotfiles for a streamlined setup.

##### i3wm Setup
- Installs and configures i3, providing a lightweight and efficient window management experience.

##### Install Fonts
- Downloads and installs a variety of Nerd Fonts for improved readability and aesthetics in terminal applications.

##### Install LTS Kernel
- Installs the Long-Term Support (LTS) kernel for enhanced stability and extended support.

##### Install Packages
- Installs a curated selection of essential packages to establish a fully functional environment.

##### Setup Alacritty
- Configures the Alacritty terminal emulator using my preferred settings for optimal performance.

##### Setup AUR
- Installs AUR (Arch User Repository) helpers, like Paru or Yay, to simplify package management.

##### Setup Fastfetch
- Configures Fastfetch to display detailed system information quickly and attractively in the terminal.

##### Setup GRUB
- Customizes the GRUB bootloader with improved aesthetics and settings for a more polished boot experience.

##### Setup Kitty
- Sets up the Kitty terminal emulator with advanced features and custom configurations.

##### Setup Neovim
- Installs and configures Neovim for an enhanced, efficient code editing environment.

##### Setup Picom
- Installs and configures the Picom compositor to enable window transparency, shadows, and other visual effects.

##### Setup Rofi
- Configures Rofi as a powerful application launcher and window switcher, improving workflow efficiency.

##### Setup SDDM
- Configures the SDDM (Simple Desktop Display Manager) for a streamlined and visually appealing login experience.

##### Setup Themes & Icons
- Installs and applies a set of themes and icons to enhance the look and feel of your desktop.

##### SwayWM Setup
- Installs and configures the Sway window manager, optimized for Wayland environments.

##### Wallpapers
- Installs a selection of wallpapers for a personalized desktop aesthetic.


## Roadmap
<img src="https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/docs/assets/roadmap.webp" width="50" /> 

For information on upcoming features and improvements, check the full roadmap here: 

**[View the Roadmap](https://github.com/harilvfs/carch/blob/main/.github/ROADMAP.md)**

## Contributing
<img src="https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/docs/assets/contribute.webp" width="50" /> 

Contributions are welcome! To contribute to Carch

Please refer to the **[CONTRIBUTING.md](https://github.com/harilvfs/carch/blob/main/.github/CONTRIBUTING.md)** for more details.

## Code of Conduct
<img src="https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/docs/assets/code-of-conduct.webp" width="50" /> 

We strive to create a welcoming environment for all contributors. Please read our **[Code of Conduct](https://github.com/harilvfs/carch/blob/main/.github/CODE_OF_CONDUCT.md)** to ensure a positive experience for everyone involved.

## License
<img src="https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/docs/assets/licensing.webp" width="50" /> 

Carch is licensed under the **Apache-2.0 License**. For more details, see the **[LICENSE](LICENSE)** file.

## Contact
<img src="https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/docs/assets/communicate.webp" width="50" /> 

If you have any questions or suggestions, feel free to reach out via:

- 📧 Email: [harilvfs@chalisehari.com.np](mailto:harilvfs@chalisehari.com.np)
- GitHub: [harilvfs](https://github.com/harilvfs)

## Acknowledgments
<img src="https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/docs/assets/contributors.webp" width="50" />

We thank everyone who has contributed to making **Carch** better. Your feedback and contributions are invaluable!

[![Contributors](https://contrib.rocks/image?repo=harilvfs/carch)](https://github.com/harilvfs/carch/graphs/contributors)

## Inspiration
<img src="https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/docs/assets/inspiration.webp" width="50" />

- **[ChrisTitusTech `linutil`](https://github.com/ChrisTitusTech)**
- **[ML4W `Dotfiles Script`](https://github.com/mylinuxforwork)** 

---

### Repository Structure

```bash
carch/
├── PKGBUILD
├── binarybuild.sh
├── build
│   └── carch
├── carch.desktop
├── clean.sh
├── cxfs.sh
├── docs
│   ├── assets
│   └── index.md
├── package.json
├── run
│   └── cleanrun.sh
├── run.sh
├── preview
├── scripts
│   ├── Alacritty.sh
│   ├── Aur.sh
│   ├── Dwm.sh
│   ├── Fastfetch.sh
│   ├── Fonts.sh
│   ├── Grub.sh
│   ├── Hyprland.sh
│   ├── Kitty.sh
│   ├── LTS-Kernal.sh
│   ├── Neovim.sh
│   ├── Packages.sh
│   ├── Picom.sh
│   ├── Rofi.sh
│   ├── Sddm.sh
│   ├── SwayWM.sh
│   ├── Themes-Icons.sh
│   ├── Wallpapers.sh
│   └── i3wm.sh
├── setup.sh
└── zip
    └── carchscripts.zip

```
---

Thank you for exploring Carch!

[discord-badge]: https://img.shields.io/discord/757266205408100413.svg?logo=discord&colorB=7289DA&style=for-the-badge
[discord-link]: https://discord.gg/TAaVXT95
