# Aur

![AUR Version](https://img.shields.io/aur/version/carch-git?style=for-the-badge&color=dbb6ed&logo=arch-linux&label=%5BAUR%5D%20carch-git&logocolor=85e185&labelColor=1c1c29)

![AUR Version](https://img.shields.io/aur/version/carch?style=for-the-badge&color=ef9f9c&logo=arch-linux&label=%5BAUR%5D%20carch&logocolor=85e185&labelColor=1c1c29)

**Carch is also available in the [AUR](https://aur.archlinux.org/) package repository.**

[Package](https://aur.archlinux.org/packages/) **`carch`** **`carch-git`**
 - [Carch](https://aur.archlinux.org/packages/carch) - Stable Build
 - [Carch-Git](https://aur.archlinux.org/packages/carch-git) - Github Latest Build

You can install it using an AUR package manager.
 - [`paru`](https://aur.archlinux.org/packages/paru-bin)
 - [`yay`](https://aur.archlinux.org/packages/yay-bin)

Select `<packager>` then

:::code-group


```sh [<i class="devicon-archlinux-plain"></i> paru]
paru -S carch
#or
paru -S carch-git

```

```sh [<i class="devicon-archlinuc-plain"></i> yay]
yay -S carch
#or
yay -S carch-git
```

```sh [Package Build ]
git clone https://aur.archlinux.org/carch.git
cd carch
makepkg -si
```

```sh [Git Package Build ]
git clone https://aur.archlinux.org/carch-git.git
cd carch-git
makepkg -si
```

> [!NOTE]
> You can use the `carch` package for stable updates with the latest release, or use the `git package` to get the most recent changes directly from the Carch GitHub repository.

