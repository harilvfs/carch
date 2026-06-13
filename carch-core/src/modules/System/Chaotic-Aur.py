#!/usr/bin/env python3
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from carch_lib import (
    CYAN,
    GREEN,
    NC,
    RED,
    TEAL,
    YELLOW,
    confirm,
    detect_distro,
    print_error,
    print_info,
    print_msg,
    print_success,
    print_teal,
    print_warning,
    run,
)

PACMAN_CONF = "/etc/pacman.conf"
BACKUP_DIR = os.path.expanduser("~/.config/carch/backups")


def check_distro():
    if detect_distro() != "Arch":
        print_error("This script is only for Arch-based systems.")
        sys.exit(1)


def is_root():
    return os.geteuid() == 0


def is_chaotic_installed():
    result = run(["sudo", "cat", PACMAN_CONF], capture_output=True, text=True, check=False)
    return result.returncode == 0 and "[chaotic-aur]" in result.stdout


def install_chaotic_aur():
    if is_root():
        print_error("Please run this script as a normal user, not as root.")
        sys.exit(1)

    if is_chaotic_installed():
        print_msg(GREEN, "Chaotic AUR is already configured in /etc/pacman.conf.")
        return

    gnupg_dir = "/etc/pacman.d/gnupg"
    if not os.path.isdir(gnupg_dir):
        print_teal("Initializing pacman keys...")
        if run(["sudo", "pacman-key", "--init"], check=False).returncode != 0:
            print_error("Failed to initialize pacman keys.")
            sys.exit(1)

    print_teal("Fetching Chaotic AUR key...")
    if run(["sudo", "pacman-key", "--recv-key", "3056513887B78AEB", "--keyserver", "keyserver.ubuntu.com"], check=False).returncode != 0:
        print_error("Failed to fetch the Chaotic AUR key. Check your internet connection.")
        sys.exit(1)

    print_teal("Signing the key...")
    if run(["sudo", "pacman-key", "--lsign-key", "3056513887B78AEB"], check=False).returncode != 0:
        print_error("Failed to sign the key.")
        sys.exit(1)

    print_teal("Installing Chaotic AUR keyring...")
    if run(["sudo", "pacman", "-U", "--noconfirm", "https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst"], check=False).returncode != 0:
        print_error("Failed to install chaotic-keyring.")
        sys.exit(1)

    print_teal("Installing Chaotic AUR mirrorlist...")
    if run(["sudo", "pacman", "-U", "--noconfirm", "https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst"], check=False).returncode != 0:
        print_error("Failed to install chaotic-mirrorlist.")
        sys.exit(1)

    os.makedirs(BACKUP_DIR, exist_ok=True)
    import random
    backup_path = os.path.join(BACKUP_DIR, f"pacman.conf.bak.{random.randint(10000, 99999)}")
    if run(["sudo", "cp", PACMAN_CONF, backup_path], check=False).returncode == 0:
        print_msg(GREEN, f"Backup of pacman.conf created at {backup_path}")

    print_teal("Adding Chaotic AUR to pacman.conf...")
    entry = "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n"
    if run(["sudo", "tee", "-a", PACMAN_CONF], input=entry.encode(), check=False).returncode != 0:
        print_error("Failed to modify pacman.conf.")
        sys.exit(1)

    print_teal("Syncing Pacman database...")
    if run(["sudo", "pacman", "-Syy"], check=False).returncode != 0:
        print_error("Failed to sync pacman database.")
        sys.exit(1)

    print_msg(GREEN, "Chaotic AUR has been installed successfully!")
    print_msg(GREEN, "You can now install packages from Chaotic AUR using pacman.")


def main():
    check_distro()
    print_msg(CYAN, "This script will add the Chaotic-AUR repository to your system.")
    if confirm("Do you want to proceed with the installation?"):
        install_chaotic_aur()
    else:
        print_msg(YELLOW, "Installation cancelled.")


if __name__ == "__main__":
    main()
