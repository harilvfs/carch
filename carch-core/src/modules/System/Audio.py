#!/usr/bin/env python3
import os
import re
import shutil
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from carch_lib import (
    detect_distro,
    print_error,
    print_info,
    print_success,
    print_teal,
    print_warning,
    run,
)

PACMAN_CONF = "/etc/pacman.conf"
BACKUP_DIR = os.path.expanduser("~/.config/carch/backups")


def check_multilib():
    print_teal("Checking multilib repository status...")

    result = run(
        ["sudo", "cat", PACMAN_CONF], capture_output=True, text=True, check=False
    )
    if result.returncode != 0:
        print_error("Failed to read /etc/pacman.conf")
        return False
    content = result.stdout

    if re.search(r"^\[multilib\]", content, re.MULTILINE):
        print_success("32-bit multilib repository is already enabled.")
        return True

    if re.search(r"^#\s*\[multilib\]", content, re.MULTILINE):
        print_warning("Multilib repository found but is commented out.")

        os.makedirs(BACKUP_DIR, exist_ok=True)
        backup_path = os.path.join(BACKUP_DIR, "pacman.conf.bak")
        shutil.copy2(PACMAN_CONF, backup_path)
        print_info(f"Backed up {PACMAN_CONF} to {backup_path}")

        new_content = re.sub(
            r"^(#\s*\[multilib\])",
            "[multilib]",
            content,
            count=1,
            flags=re.MULTILINE,
        )
        new_content = re.sub(
            r"^(#\s*Include\s=/etc/pacman\.d/mirrorlist)",
            r"",
            new_content,
            count=1,
            flags=re.MULTILINE,
        )

        run(["sudo", "tee", PACMAN_CONF], input=new_content.encode())
        print_success("Multilib repository has been enabled.")
        print_info("Updating package databases...")
        run(["sudo", "pacman", "-Sy"], check=False)
        return True

    print_error("Multilib repository not found in pacman.conf.")
    return False


def install_pipewire():
    distro = detect_distro()
    print_teal("Installing PipeWire and related packages...")

    if distro == "Arch":
        print_info("Installing PipeWire packages for Arch Linux...")
        multilib_ok = check_multilib()
        pkgs = [
            "pipewire",
            "pipewire-alsa",
            "pipewire-jack",
            "pipewire-pulse",
            "gst-plugin-pipewire",
            "wireplumber",
            "rtkit",
        ]
        if multilib_ok:
            pkgs.append("lib32-pipewire")
        run(["sudo", "pacman", "-S", "--noconfirm"] + pkgs)

    elif distro == "Fedora":
        print_info("Installing PipeWire packages for Fedora...")
        run(["sudo", "dnf", "install", "-y", "pipewire"])

    elif distro == "openSUSE":
        print_info("Installing PipeWire packages for openSUSE...")
        run(
            [
                "sudo",
                "zypper",
                "install",
                "-y",
                "pipewire",
                "rtkit",
                "wireplumber",
                "pipewire-alsa",
                "gstreamer-plugin-pipewire",
                "pipewire-pulseaudio",
            ]
        )

    print_success("PipeWire packages installed successfully.")


def setup_user_and_services():
    print_teal("Configuring user permissions and services...")

    print_info("Adding user to rtkit group for realtime audio processing...")
    run(["sudo", "usermod", "-a", "-G", "rtkit", os.environ.get("USER", "")])

    print_info("Enabling PipeWire services...")
    run(["systemctl", "--user", "enable", "pipewire", "pipewire-pulse", "wireplumber"])

    print_success("User settings and services configured successfully.")


def main():
    install_pipewire()
    setup_user_and_services()
    print_success("PipeWire setup completed successfully!")
    print_info("Please log out or reboot your system later to apply changes.")


if __name__ == "__main__":
    main()
