#!/usr/bin/env python3
import json
import os
import sys
import urllib.request
import zipfile
from io import BytesIO

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from carch_lib import (
    command_exists,
    confirm,
    detect_distro,
    get_choice,
    install_aur_helper,
    print_error,
    print_info,
    print_success,
    print_teal,
    print_warning,
    run,
    show_menu,
)

FONTS_DIR = os.path.expanduser("~/.fonts")
GITHUB_API = "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
GITHUB_DL = "https://github.com/ryanoasis/nerd-fonts/releases/download"

FONTS = {
    "FiraCode": {
        "arch": ["ttf-firacode-nerd"],
        "fedora": {"pkg": None, "github": "FiraCode"},
        "opensuse": {"pkg": "fira-code-fonts"},
    },
    "Meslo": {
        "arch": ["ttf-meslo-nerd"],
        "fedora": {"pkg": None, "github": "Meslo"},
        "opensuse": {"pkg": "meslo-lg-fonts"},
    },
    "JetBrainsMono": {
        "arch": ["ttf-jetbrains-mono-nerd", "ttf-jetbrains-mono"],
        "fedora": {"pkg": "jetbrains-mono-fonts-all"},
        "opensuse": {"pkg": "jetbrains-mono-fonts"},
    },
    "Hack": {
        "arch": ["ttf-hack-nerd"],
        "fedora": {"pkg": None, "github": "Hack"},
        "opensuse": {"pkg": "hack-fonts"},
    },
    "CascadiaMono": {
        "arch": ["ttf-cascadia-mono-nerd", "ttf-cascadia-code-nerd"],
        "fedora": {"pkg": None, "github": "CascadiaMono"},
        "opensuse": {"pkg": None, "github": "CascadiaMono"},
    },
    "Terminus": {
        "arch": ["terminus-font"],
        "fedora": {"pkg": None, "github": "Terminus"},
        "opensuse": {"pkg": None, "github": "Terminus"},
    },
    "Noto": {
        "arch": [
            "noto-fonts",
            "noto-fonts-emoji",
            "noto-fonts-cjk",
            "noto-fonts-extra",
        ],
        "fedora": {"pkg": "google-noto-fonts"},
        "opensuse": {"pkg": "google-noto-fonts"},
    },
    "DejaVu": {
        "arch": ["ttf-dejavu"],
        "fedora": {"pkg": "dejavu-sans-fonts"},
        "opensuse": {"pkg": "dejavu-fonts"},
    },
    "JoyPixels": {
        "arch": None,
        "aur": "ttf-joypixels",
        "fedora": {
            "pkg": None,
            "url": "https://cdn.joypixels.com/arch-linux/font/8.0.0/joypixels-android.ttf",
        },
        "opensuse": {
            "pkg": None,
            "url": "https://cdn.joypixels.com/arch-linux/font/8.0.0/joypixels-android.ttf",
        },
    },
    "FontAwesome": {
        "arch": None,
        "aur": "ttf-font-awesome",
        "fedora": {"pkg": "fontawesome-fonts-all"},
        "opensuse": {"pkg": "fontawesome-fonts"},
    },
}


def check_dependencies():
    missing = [dep for dep in ("curl", "unzip") if not command_exists(dep)]
    if missing:
        for dep in missing:
            print_error(f"{dep} is not installed.")
            distro = detect_distro()
            if distro == "Fedora":
                print_info(f"  sudo dnf install {dep}")
            elif distro == "Arch":
                print_info(f"  sudo pacman -S {dep}")
            elif distro == "openSUSE":
                print_info(f"  sudo zypper install {dep}")
        sys.exit(1)


def get_latest_version():
    req = urllib.request.Request(GITHUB_API, headers={"User-Agent": "carch"})
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read())
    return data["tag_name"].lstrip("v")


def download_and_extract_font(font_name):
    version = get_latest_version()
    url = f"{GITHUB_DL}/v{version}/{font_name}.zip"
    print_info(f"Downloading {font_name} v{version}...")

    req = urllib.request.Request(url, headers={"User-Agent": "carch"})
    with urllib.request.urlopen(req) as resp:
        zip_data = resp.read()

    os.makedirs(FONTS_DIR, exist_ok=True)
    with zipfile.ZipFile(BytesIO(zip_data)) as zf:
        zf.extractall(FONTS_DIR)

    print_info("Refreshing font cache...")
    run(["fc-cache", "-vf"], check=False)
    print_success(f"{font_name} installed to {FONTS_DIR}")


def install_font_arch(pkgs):
    run(["sudo", "pacman", "-S", "--noconfirm", "--needed"] + pkgs)
    print_success(f"Installed via pacman: {' '.join(pkgs)}")


def install_font_fedora(pkg):
    run(["sudo", "dnf", "install", "-y", pkg])
    print_success(f"Installed via dnf: {pkg}")


def install_font_opensuse(pkg):
    run(["sudo", "zypper", "install", "-y", pkg])
    print_success(f"Installed via zypper: {pkg}")


def install_font(font_name):
    info = FONTS[font_name]
    distro = detect_distro()

    if font_name in ("JoyPixels", "FontAwesome") and info.get("aur"):
        aur = install_aur_helper()
        print_info(f"Installing {font_name} via {aur}...")
        run([aur, "-S", "--noconfirm", info["aur"]])
        print_success(f"{font_name} installed successfully!")
        return

    if distro == "Arch" and info.get("arch"):
        install_font_arch(info["arch"])
    elif distro == "Fedora":
        fedora = info.get("fedora", {})
        if fedora.get("pkg"):
            install_font_fedora(fedora["pkg"])
        elif fedora.get("github"):
            download_and_extract_font(fedora["github"])
        elif fedora.get("url"):
            os.makedirs(FONTS_DIR, exist_ok=True)
            dest = os.path.join(FONTS_DIR, os.path.basename(fedora["url"]))
            run(["curl", "-L", fedora["url"], "-o", dest])
            run(["fc-cache", "-vf"], check=False)
            print_success(f"{font_name} installed to {FONTS_DIR}")
    elif distro == "openSUSE":
        opensuse = info.get("opensuse", {})
        if opensuse.get("pkg"):
            install_font_opensuse(opensuse["pkg"])
        elif opensuse.get("github"):
            download_and_extract_font(opensuse["github"])
        elif opensuse.get("url"):
            os.makedirs(FONTS_DIR, exist_ok=True)
            dest = os.path.join(FONTS_DIR, os.path.basename(opensuse["url"]))
            run(["curl", "-L", opensuse["url"], "-o", dest])
            run(["fc-cache", "-vf"], check=False)
            print_success(f"{font_name} installed to {FONTS_DIR}")
    else:
        print_error(f"Cannot install {font_name} for {distro}.")


def main():
    check_dependencies()
    print_teal(f"Detected OS: {detect_distro()}")
    print()

    font_names = list(FONTS.keys())
    options = font_names + ["Install All Fonts", "Exit"]

    while True:
        os.system("clear" if os.name == "posix" else "cls")
        show_menu("Choose fonts to install:", options)
        choice_idx = get_choice(len(options))
        choice = options[choice_idx - 1]

        if choice == "Exit":
            break
        elif choice == "Install All Fonts":
            if confirm("Install all available fonts?"):
                for name in font_names:
                    print_info(f"Installing {name}...")
                    install_font(name)
                    print()
                print_success("All fonts installed successfully!")
        else:
            if confirm(f"Install {choice} font?"):
                install_font(choice)
            else:
                print_warning("Installation cancelled.")

        print()
        try:
            input("Press Enter to continue...")
        except (KeyboardInterrupt, EOFError):
            print()
            sys.exit(0)


if __name__ == "__main__":
    main()
