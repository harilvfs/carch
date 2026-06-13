#!/usr/bin/env python3
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from carch_lib import (
    CYAN,
    GREEN,
    RED,
    TEAL,
    YELLOW,
    command_exists,
    confirm,
    get_choice,
    print_error,
    print_msg,
    run,
    show_menu,
)

OVERRIDE_DIR = "/etc/systemd/system/getty@tty1.service.d"
OVERRIDE_FILE = os.path.join(OVERRIDE_DIR, "autologin.conf")


def get_current_user():
    return os.environ.get("SUDO_USER") or os.environ.get("USER", "root")


def check_autologin_enabled():
    return os.path.isfile(OVERRIDE_FILE)


def print_current_status():
    print()
    print_msg(CYAN, "=== Current Autologin Status ===")
    if check_autologin_enabled():
        print_msg(GREEN, "Autologin is currently ENABLED")
        try:
            result = run(
                ["sudo", "cat", OVERRIDE_FILE],
                capture_output=True,
                text=True,
                check=False,
            )
            if result.returncode == 0:
                match = re.search(r"--autologin\s+(\S+)", result.stdout)
                if match:
                    print_msg(TEAL, f"Configured for user: {match.group(1)}")
        except SystemExit:
            pass
    else:
        print_msg(RED, "Autologin is currently DISABLED")
    print()


def print_security_warning():
    print()
    print_msg(RED, "WARNING")
    print_msg(
        YELLOW, "Enabling autologin allows anyone with physical access to your system"
    )
    print_msg(YELLOW, "to login without entering a password or username.")
    print()


def enable_autologin():
    username = get_current_user()
    print_security_warning()

    if not confirm(
        f"Do you want to continue and enable autologin for user '{username}'?"
    ):
        print_msg(GREEN, "Autologin setup cancelled.")
        return

    print_msg(GREEN, "Creating autologin configuration...")

    if run(["sudo", "mkdir", "-p", OVERRIDE_DIR], check=False).returncode != 0:
        print_error("Failed to create autologin directory.")
        return

    content = (
        f"[Service]\n"
        f"ExecStart=\n"
        f"ExecStart=-/sbin/agetty --autologin {username} --noclear %I 38400 linux\n"
    )

    try:
        run(["sudo", "tee", OVERRIDE_FILE], input=content.encode())
    except SystemExit:
        print_error("Failed to create autologin configuration.")
        return

    print_msg(GREEN, "Autologin configuration created successfully.")
    print_msg(GREEN, "Reloading systemd daemon...")

    if run(["sudo", "systemctl", "daemon-reload"], check=False).returncode == 0:
        print_msg(GREEN, f"Autologin enabled for user '{username}' on tty1.")
        print_msg(TEAL, "Changes will take effect after next reboot.")
    else:
        print_error("Failed to reload systemd daemon.")


def remove_autologin():
    if not check_autologin_enabled():
        print_msg(RED, "Autologin is not currently enabled.")
        print_msg(YELLOW, "Nothing to remove.")
        return

    print_msg(GREEN, "Autologin configuration found.")

    if confirm("Remove autologin configuration?"):
        print_msg(GREEN, "Removing autologin configuration...")
        if run(["sudo", "rm", "-rf", OVERRIDE_DIR], check=False).returncode == 0:
            print_msg(GREEN, "Autologin configuration removed successfully.")
            print_msg(GREEN, "Reloading systemd daemon...")
            if run(["sudo", "systemctl", "daemon-reload"], check=False).returncode == 0:
                print_msg(GREEN, "Autologin disabled successfully.")
                print_msg(TEAL, "Changes will take effect after next reboot.")
            else:
                print_error("Failed to reload systemd daemon.")
        else:
            print_error("Failed to remove autologin configuration.")
    else:
        print_msg(GREEN, "Autologin removal cancelled.")


def main():
    if not command_exists("systemctl"):
        print_error("systemctl not found. This script requires systemd.")
        sys.exit(1)

    print_current_status()

    options = ["Enable autologin", "Remove autologin", "Exit"]
    show_menu("TTY Autologin Manager:", options)

    choice_idx = get_choice(len(options))
    choice = options[choice_idx - 1]

    if choice == "Enable autologin":
        enable_autologin()
    elif choice == "Remove autologin":
        remove_autologin()


if __name__ == "__main__":
    main()
