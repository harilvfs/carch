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
