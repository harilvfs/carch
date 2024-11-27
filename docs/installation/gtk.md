# GTK

**The GTK version of Carch is available.**

> [!CAUTION]
> The GTK version of Carch is currently under development. <br>
> It’s not fully ready for use and needs some script updates to work properly. You may try it now as you would with the usual Carch script.

**How to Install and Use 📦**

<img src="https://cdn-icons-png.flaticon.com/128/1634/1634155.png" width="20" />

## Prerequisites

Simply run the main script:

```bash
bash <(curl -L https://chalisehari.com.np/carch)
```

Once done, you can launch the Carch GTK interface by typing:

```
carch-gtk
```


> **Note:** You can also run the Carch GTK interface after installing it from the AUR.



## From Source

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

## Install and Run Carch

Clone the Carch repository and run the GTK script:

```bash
git clone https://github.com/harilvfs/carch
cd carch
python3 carch-gtk.py
```

> [!NOTE]
> If any errors pop up while running the script, they are likely related to missing dependencies. Make sure to install all required Python dependencies.
