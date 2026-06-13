#!/usr/bin/env python3
import glob
import os
import subprocess
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from carch_lib import (
    CYAN,
    GREEN,
    NC,
    RED,
    YELLOW,
    command_exists,
    confirm,
    print_error,
    print_msg,
    print_teal,
    run,
)

os.environ["PATH"] = os.environ.get("PATH", "") + ":/usr/sbin"

PLATFORM_MODULES = [
    ("Dell", "dell_rbtn", "blacklist-dell-rbtn.conf"),
    ("HP", "hp_wmi", "blacklist-hp-wmi.conf"),
    ("HP", "hp_wireless", "blacklist-hp-wireless.conf"),
    ("Lenovo IdeaPad", "ideapad_laptop", "blacklist-ideapad-laptop.conf"),
    ("Acer", "acer_wmi", "blacklist-acer-wmi.conf"),
    ("Asus", "asus_nb_wmi", "blacklist-asus-nb-wmi.conf"),
]


def is_module_loaded(module):
    result = subprocess.run(["lsmod"], capture_output=True, text=True, check=False)
    return module in result.stdout.splitlines()


def detect_wireless_hardware():
    print_teal("Detecting wireless hardware...")

    if command_exists("lspci"):
        result = subprocess.run(
            ["lspci", "-nn"],
            capture_output=True,
            text=True,
            check=False,
        )
        wireless = [
            line
            for line in result.stdout.splitlines()
            if any(
                k in line.lower()
                for k in (
                    "network",
                    "wireless",
                    "wifi",
                    "atheros",
                    "qualcomm",
                    "broadcom",
                    "intel",
                    "realtek",
                )
            )
        ]
        if wireless:
            print_msg(CYAN, "PCI Wireless devices detected:")
            for line in wireless:
                print(f"  {YELLOW}{line}{NC}")
        else:
            print_msg(YELLOW, "No PCI wireless devices found via lspci.")

    if command_exists("lsusb"):
        result = subprocess.run(
            ["lsusb"],
            capture_output=True,
            text=True,
            check=False,
        )
        wireless = [
            line
            for line in result.stdout.splitlines()
            if any(
                k in line.lower()
                for k in (
                    "wireless",
                    "wifi",
                    "bluetooth",
                    "atheros",
                    "qualcomm",
                    "broadcom",
                )
            )
        ]
        if wireless:
            print_msg(CYAN, "USB wireless devices detected:")
            for line in wireless:
                print(f"  {YELLOW}{line}{NC}")

    print_teal("Checking for loaded wireless drivers...")
    result = subprocess.run(["lsmod"], capture_output=True, text=True, check=False)
    for line in result.stdout.splitlines():
        if any(
            k in line.lower()
            for k in ("ath", "iwl", "b43", "brcm", "rtl", "wil621", "wl")
        ):
            print(f"  {GREEN}{line}{NC}")


def check_rfkill_status():
    print_teal("Checking rfkill status...")

    if not command_exists("rfkill"):
        print_msg(YELLOW, "rfkill not found. Ensure util-linux is installed.")
        return -1

    result = subprocess.run(
        ["rfkill", "list"], capture_output=True, text=True, check=False
    )
    output = result.stdout

    if not output.strip():
        print_msg(GREEN, "No rfkill devices found. Wireless should be unblocked.")
        return 0

    for line in output.splitlines():
        print(f"  {CYAN}{line}{NC}")

    hard_blocked = output.count("Hard blocked: yes")
    soft_blocked = output.count("Soft blocked: yes")

    if hard_blocked:
        print_msg(RED, f"Detected {hard_blocked} device(s) with HARD block.")
    else:
        print_msg(GREEN, "No hard-blocked devices detected.")

    if soft_blocked:
        print_msg(YELLOW, f"Detected {soft_blocked} device(s) with SOFT block.")
    else:
        print_msg(GREEN, "No soft-blocked devices detected.")

    return hard_blocked + soft_blocked


def check_platform_blockage():
    print_teal("Checking for platform modules known to falsely block wireless...")
    print()

    detected = []

    for vendor, module, conf in PLATFORM_MODULES:
        if is_module_loaded(module):
            print_msg(
                YELLOW,
                f"{vendor}: '{module}' module is currently loaded (known to falsely block wireless).",
            )
            detected.append((module, conf))

    if not detected:
        print_msg(GREEN, "No known problematic platform modules detected.")
        for _, module, conf in PLATFORM_MODULES:
            path = f"/etc/modprobe.d/{conf}"
            if os.path.isfile(path):
                print_msg(GREEN, f"  {module} is already blacklisted ({path}).")
        return False

    return True


def fix_wifi_blockage(detected):
    print_teal("Applying fix for wireless blockage...")

    for module, conf in detected:
        blacklist_path = f"/etc/modprobe.d/{conf}"

        if is_module_loaded(module):
            print_msg(CYAN, f"Removing {module} module...")
            if run(["sudo", "modprobe", "-r", module], check=False).returncode != 0:
                print_error(f"Failed to remove {module} module.")
                sys.exit(1)
            print_msg(GREEN, f"{module} module removed successfully.")
        else:
            print_msg(CYAN, f"{module} is not currently loaded, skipping removal.")

        if not os.path.isfile(blacklist_path):
            print_msg(CYAN, f"Blacklisting {module} to prevent loading on boot...")
            if (
                run(
                    ["sudo", "tee", blacklist_path],
                    input=f"blacklist {module}\n".encode(),
                    check=False,
                ).returncode
                != 0
            ):
                print_error(f"Failed to create {blacklist_path}")
                sys.exit(1)
            print_msg(GREEN, f"{module} blacklisted in {blacklist_path}")
        else:
            print_msg(GREEN, f"{module} is already blacklisted in {blacklist_path}")

    print_msg(CYAN, "Unblocking all wireless devices via rfkill...")
    if run(["sudo", "rfkill", "unblock", "all"], check=False).returncode != 0:
        print_error("Failed to unblock rfkill devices.")
        sys.exit(1)
    print_msg(GREEN, "All wireless devices unblocked.")

    print_msg(CYAN, "Bringing wireless interfaces up...")
    for pattern in ("/sys/class/net/wl*", "/sys/class/net/wlan*"):
        for iface_dir in glob.glob(pattern):
            if os.path.isdir(iface_dir):
                name = os.path.basename(iface_dir)
                print_msg(CYAN, f"  Bringing up {name}...")
                if (
                    run(
                        ["sudo", "ip", "link", "set", name, "up"], check=False
                    ).returncode
                    == 0
                ):
                    print_msg(GREEN, f"  {name} is now up.")
                else:
                    print_msg(
                        YELLOW, f"  Could not bring {name} up (may not exist yet)."
                    )

    print_msg(GREEN, "Fix applied successfully!")


def main():
    print_teal("=== Wireless Blockage Fix ===")
    print()

    detect_wireless_hardware()
    print()

    rfkill_result = check_rfkill_status()
    print()

    platform_detected = check_platform_blockage()
    print()

    if rfkill_result == 0 and not platform_detected:
        print_msg(
            GREEN,
            "No wireless blockage detected. Your wireless should be working correctly.",
        )
        print()

        if confirm("Run rfkill unblock and bring interfaces up as a safety measure?"):
            print_msg(CYAN, "Unblocking all wireless devices via rfkill...")
            run(["sudo", "rfkill", "unblock", "all"], check=False)
            print_msg(CYAN, "Bringing wireless interfaces up...")
            for pattern in ("/sys/class/net/wl*", "/sys/class/net/wlan*"):
                for iface_dir in glob.glob(pattern):
                    if os.path.isdir(iface_dir):
                        run(
                            [
                                "sudo",
                                "ip",
                                "link",
                                "set",
                                os.path.basename(iface_dir),
                                "up",
                            ],
                            check=False,
                        )
            print_msg(GREEN, "Done.")
        else:
            print_msg(GREEN, "No changes made.")
    else:
        if platform_detected:
            print_msg(
                YELLOW, "Detected platform module(s) known to falsely block wireless."
            )
        print()
        if confirm("Do you want to apply the fix for wireless blockage?"):
            detected = []
            for vendor, module, conf in PLATFORM_MODULES:
                if is_module_loaded(module):
                    detected.append((module, conf))
            fix_wifi_blockage(detected)
            print()
            print_msg(
                GREEN,
                "Fix completed. Please restart your network manager or reboot for changes to take full effect.",
            )

            if command_exists("systemctl"):
                if confirm("Do you want to restart NetworkManager now?"):
                    run(["sudo", "systemctl", "restart", "NetworkManager"], check=False)
        else:
            print_msg(YELLOW, "Fix skipped. You can re-run the script anytime.")


if __name__ == "__main__":
    main()
