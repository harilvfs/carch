# Carch Documentation

**Carch** is a user-friendly Bash script that simplifies the setup process for Arch and Arch-based Linux systems. This documentation serves as a guide for using, contributing to, and understanding the features of Carch.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [Code of Conduct](#code-of-conduct)
- [License](#license)
- [Contact](#contact)
- [Acknowledgments](#acknowledgments)

## Introduction

Carch aims to automate and streamline the initial setup of Arch Linux, making it easier for users to configure their systems efficiently. The script encompasses various setup tasks, including package installations, theme configurations, and window manager setups.

## Features

- **Easy Setup:** Quick and straightforward installation of essential packages.
- **TUI Navigation:** A text-based user interface that enhances user experience.
- **Multiple Scripts:** Automate the setup of various environments, including Dwm and Hyprland.
- **Active Development:** Continuous updates and new features based on community feedback.

![Carch Screenshots](https://github.com/harilvfs/carch/raw/main/preview/carchp.png)

## Installation

To install Carch, execute the following command in your terminal:

```bash
bash <(curl -L https://chalisehari.com.np/carch)
```

> **Important:**  
> This script is primarily designed for Arch and Arch-based systems. Support for additional distributions will be added in future updates.

## Usage

Upon running the installation script, Carch provides a menu-driven interface for various setup options:

- **Arch Setup:** Automated configuration of the Arch Linux environment.
- **AUR Setup:** Options to install your preferred AUR helper (e.g., Paru, Yay).
- **Theme & Icon Setup:** Customize your desktop with themes and icons.

Follow the on-screen instructions to navigate through the menu.

## Roadmap

For information on upcoming features and improvements, check the full roadmap here:  
**[View the Roadmap](https://github.com/harilvfs/carch/blob/main/roadmap.md)**

## Contributing

Contributions are welcome! To contribute to Carch, follow these steps:

1. **Fork** the repository.
2. **Create** a new feature branch.
3. **Make** your changes.
4. **Commit** your changes with a descriptive message.
5. **Push** to the branch.
6. **Submit** a pull request.

Please refer to the **[CONTRIBUTING.md](https://github.com/harilvfs/carch/blob/main/.github/CONTRIBUTING.md)** for more details.

## Code of Conduct

We strive to create a welcoming environment for all contributors. Please read our **[Code of Conduct](https://github.com/harilvfs/carch/blob/main/.github/CODE_OF_CONDUCT.md)** to ensure a positive experience for everyone involved.

## License

Carch is licensed under the **Apache-2.0 License**. For more details, see the **[LICENSE](LICENSE)** file.

## Contact

If you have any questions or suggestions, feel free to reach out via:

- 📧 Email: [ingoprivate@gmail.com](mailto:ingoprivate@gmail.com)
- GitHub: [harilvfs](https://github.com/harilvfs)

## Acknowledgments

We thank everyone who has contributed to making **Carch** better. Your feedback and contributions are invaluable!

[![Contributors](https://contrib.rocks/image?repo=harilvfs/carch)](https://github.com/harilvfs/carch/graphs/contributors)

---

### Repository Structure

```bash
carch/
├── docs/
│   └── index.md
├── preview/
│   ├── carchp.png
│   └── carchp1.png
├── scripts/
│   ├── Dwm Setup.sh
│   ├── Hyprland Setup.sh
│   ├── Install Fonts.sh
│   ├── Install LTS Kernel.sh
│   ├── Install Packages.sh
│   ├── README.txt
│   ├── Setup Alacritty.sh
│   ├── Setup Aur.sh
│   ├── Setup Fastfetch.sh
│   ├── Setup GRUB.sh
│   ├── Setup Kitty.sh
│   ├── Setup Neovim.sh
│   ├── Setup Picom.sh
│   ├── Setup Rofi.sh
│   ├── Setup SDDM.sh
│   ├── Setup Themes-Icons.sh 
│   └── Wallpapers.sh
├── LICENSE
├── README.md
├── SECURITY.md
├── roadmap.md
├── cxfs.sh
├── run.sh
└── setup.sh
```
---

Thank you for exploring Carch!

Test Hello
