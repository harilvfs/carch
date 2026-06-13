import os
import shutil
import subprocess
import sys

RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[0;33m"
BLUE = "\033[0;34m"
CYAN = "\033[0;36m"
TEAL = "\033[38;2;129;200;190m"
BOLD = "\033[1m"
NC = "\033[0m"


def print_msg(color, message):
    print(f"{color}:: {message}{NC}")


def print_success(msg):
    print_msg(GREEN, msg)


def print_warning(msg):
    print_msg(YELLOW, msg)


def print_error(msg):
    print_msg(RED, msg)


def print_info(msg):
    print_msg(CYAN, msg)


def print_teal(msg):
    print_msg(TEAL, msg)


def confirm(prompt):
    while True:
        try:
            answer = input(f"{CYAN}:: {prompt} [y/N]: {NC}").strip().lower()
        except (KeyboardInterrupt, EOFError):
            print()
            sys.exit(0)
        if answer in ("y", "yes"):
            return True
        if answer in ("n", "no", ""):
            return False
        print_msg(YELLOW, "Please answer with y/yes or n/no.")


def show_menu(title, options):
    print(f"\n{CYAN}:: === {title} ==={NC}\n")
    for i, opt in enumerate(options, 1):
        print(f"  {GREEN}[{i}]{NC} {opt}")
    print()


def get_choice(max_option):
    while True:
        try:
            choice = int(input(f"{YELLOW}:: Enter your choice (1-{max_option}): {NC}"))
            if 1 <= choice <= max_option:
                return choice
        except (KeyboardInterrupt, EOFError):
            print()
            sys.exit(0)
        except ValueError:
            pass
        print_msg(
            RED, f"Invalid choice. Please enter a number between 1 and {max_option}."
        )


def command_exists(cmd):
    return shutil.which(cmd) is not None


def detect_distro():
    if command_exists("pacman"):
        return "Arch"
    if command_exists("dnf"):
        return "Fedora"
    if command_exists("zypper"):
        return "openSUSE"
    return "Unknown"


def run(cmd, check=True, sudo=False, **kwargs):
    if sudo and os.geteuid() != 0:
        cmd = ["sudo"] + cmd
    result = subprocess.run(cmd, **kwargs)
    if check and result.returncode != 0:
        print_error(f"Command failed: {' '.join(cmd)}")
        sys.exit(1)
    return result


def detect_aur_helper():
    for helper in ("paru", "yay"):
        if command_exists(helper):
            return helper
    return None


def install_aur_helper():
    if detect_aur_helper():
        return detect_aur_helper()
    print_warning("No AUR helper found. Installing yay...")
    run(["sudo", "pacman", "-S", "--needed", "--noconfirm", "git", "base-devel"])
    tmp = subprocess.check_output(["mktemp", "-d"]).decode().strip()
    run(["git", "clone", "https://aur.archlinux.org/yay.git", f"{tmp}/yay"])
    run(["makepkg", "-si", "--noconfirm"], cwd=f"{tmp}/yay")
    shutil.rmtree(tmp, ignore_errors=True)
    print_success("yay installed successfully.")
    return "yay"


def install_flatpak():
    if not command_exists("flatpak"):
        print_warning("Flatpak not found. Installing...")
        distro = detect_distro()
        if distro == "Fedora":
            run(["sudo", "dnf", "install", "-y", "flatpak"])
        elif distro == "openSUSE":
            run(["sudo", "zypper", "install", "-y", "flatpak"])
        elif distro == "Arch":
            run(["sudo", "pacman", "-S", "--noconfirm", "flatpak"])
    run(
        [
            "flatpak",
            "remote-add",
            "--if-not-exists",
            "flathub",
            "https://dl.flathub.org/repo/flathub.flatpakrepo",
        ],
        check=False,
    )


def install_package(package_name, flatpak_id=None, aur_name=None):
    distro = detect_distro()
    aur_name = aur_name or package_name
    print_info(f"Installing {package_name}...")

    if distro == "Arch":
        _install_arch(package_name, aur_name, flatpak_id)
    elif distro == "Fedora":
        _install_fedora(package_name, flatpak_id)
    elif distro == "openSUSE":
        _install_opensuse(package_name, flatpak_id)
    elif flatpak_id:
        install_flatpak()
        run(["flatpak", "install", "-y", "flathub", flatpak_id])
    else:
        print_error(
            f"Cannot install {package_name}. Unsupported distro and no Flatpak ID."
        )


def _install_arch(pkg, aur_pkg, flatpak_id):
    if run(["pacman", "-Q", pkg], check=False).returncode == 0:
        print_success(f"{pkg} is already installed.")
        return
    aur = detect_aur_helper()
    if aur and run([aur, "-Q", aur_pkg], check=False).returncode == 0:
        print_success(f"{aur_pkg} is already installed.")
        return
    if run(["pacman", "-Si", pkg], check=False).returncode == 0:
        print_success(f"Installing {pkg} from official repositories...")
        run(["sudo", "pacman", "-S", "--noconfirm", "--needed", pkg])
    elif aur and run([aur, "-Si", aur_pkg], check=False).returncode == 0:
        print_success(f"Installing {aur_pkg} from AUR...")
        run([aur, "-S", "--noconfirm", "--needed", aur_pkg])
    elif flatpak_id:
        install_flatpak()
        run(["flatpak", "install", "-y", "flathub", flatpak_id])
    else:
        print_error(f"Cannot install {pkg}. Not found anywhere.")


def _install_fedora(pkg, flatpak_id):
    if run(["rpm", "-q", pkg], check=False).returncode == 0:
        print_success(f"{pkg} is already installed.")
        return
    if run(["sudo", "dnf", "info", pkg], check=False).returncode == 0:
        run(["sudo", "dnf", "install", "-y", pkg])
    elif flatpak_id:
        install_flatpak()
        run(["flatpak", "install", "-y", "flathub", flatpak_id])
    else:
        print_error(f"Cannot install {pkg}.")


def _install_opensuse(pkg, flatpak_id):
    if run(["rpm", "-q", pkg], check=False).returncode == 0:
        print_success(f"{pkg} is already installed.")
        return
    if run(["sudo", "zypper", "info", pkg], check=False).returncode == 0:
        run(["sudo", "zypper", "install", "-y", pkg])
    elif flatpak_id:
        install_flatpak()
        run(["flatpak", "install", "-y", "flathub", flatpak_id])
    else:
        print_error(f"Cannot install {pkg}.")
