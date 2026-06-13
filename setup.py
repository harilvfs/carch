#!/usr/bin/env python3
import os
import subprocess
import sys
import tempfile

RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[0;33m"
NC = "\033[0m"


def run(cmd, check=True):
    r = subprocess.run(cmd, shell=isinstance(cmd, str))
    if check and r.returncode != 0:
        print(f"{RED}Error: command failed: {cmd}{NC}", file=sys.stderr)
        sys.exit(r.returncode)
    return r


def is_termux():
    return (
        os.environ.get("TERMUX_VERSION")
        or os.path.isdir("/data/data/com.termux")
        or subprocess.run(
            ["uname", "-o"], capture_output=True, text=True
        ).stdout.strip()
        == "Android"
    )


def detect_distro():
    if is_termux():
        return "termux"
    if (
        subprocess.run(
            ["command", "-v", "pacman"], shell=True, capture_output=True
        ).returncode
        == 0
    ):
        return "arch"
    if (
        subprocess.run(
            ["command", "-v", "dnf"], shell=True, capture_output=True
        ).returncode
        == 0
    ):
        return "fedora"
    if (
        subprocess.run(
            ["command", "-v", "zypper"], shell=True, capture_output=True
        ).returncode
        == 0
    ):
        return "opensuse"
    return "unsupported"


def detect_arch():
    machine = subprocess.run(
        ["uname", "-m"], capture_output=True, text=True
    ).stdout.strip()
    if machine in ("x86_64", "amd64"):
        return "x86_64"
    if machine in ("aarch64", "arm64"):
        return "aarch64-android" if is_termux() else "aarch64"
    if machine.startswith("armv7") or machine.startswith("armv8l") or machine == "arm":
        if is_termux():
            return "armv7-android"
        print(
            f"{RED}Error:{NC} 32-bit ARM only supported on Android/Termux",
            file=sys.stderr,
        )
        sys.exit(1)
    print(f"{RED}Error:{NC} Unsupported architecture: {machine}", file=sys.stderr)
    sys.exit(1)


def get_stable_url(arch):
    suffix = "" if arch == "x86_64" else f"-{arch}"
    return f"https://github.com/harilvfs/carch/releases/latest/download/carch{suffix}"


def get_latest_tag():
    r = subprocess.run(
        ["curl", "-s", "https://api.github.com/repos/harilvfs/carch/releases"],
        capture_output=True,
        text=True,
    )
    for line in r.stdout.splitlines():
        if "tag_name" in line:
            return line.split('"tag_name": "')[-1].strip('", ')
    return None


def get_dev_url(arch):
    tag = get_latest_tag()
    base = f"https://github.com/harilvfs/carch/releases/download/{tag}/carch"
    suffix = "" if arch == "x86_64" else f"-{arch}"
    return f"{base}{suffix}"


def install_arch():
    print(f"{GREEN}==> {NC}Cloning PKGBUILD")
    tmp = tempfile.mkdtemp(prefix="carch_")
    run(f"git clone https://github.com/carch-org/pkgs {tmp}/pkgs", check=True)
    run(f"cd {tmp}/pkgs/carch-bin && makepkg -si --noconfirm", check=True)
    run(f"rm -rf {tmp}")


def install_rpm(distro):
    print(f"{YELLOW}:: {NC}Downloading carch rpm")
    url = "https://api.github.com/repos/harilvfs/carch/releases/latest"
    r = subprocess.run(["curl", "-sL", url], capture_output=True, text=True)
    rpm_url = None
    for line in r.stdout.splitlines():
        if ".rpm" in line and "browser_download_url" in line:
            rpm_url = line.split('"browser_download_url": "')[-1].strip('", ')
            break
    if not rpm_url:
        print(f"{RED}Error:{NC} Could not find RPM package URL", file=sys.stderr)
        sys.exit(1)
    subprocess.run(["curl", "-sL", rpm_url, "-o", "/tmp/carch.rpm"], check=True)
    if distro == "fedora":
        run("sudo dnf install -y /tmp/carch.rpm", check=True)
    elif distro == "opensuse":
        run("sudo zypper install -y --allow-unsigned-rpm /tmp/carch.rpm", check=True)


def install_termux():
    arch = (
        "aarch64"
        if subprocess.run(
            ["uname", "-m"], capture_output=True, text=True
        ).stdout.strip()
        == "aarch64"
        else "arm"
    )
    print(f"{GREEN}==> {NC}Fetching latest .deb package for {arch}...")
    url = "https://api.github.com/repos/harilvfs/carch/releases/latest"
    r = subprocess.run(["curl", "-sL", url], capture_output=True, text=True)
    deb_url = None
    for line in r.stdout.splitlines():
        if f"_{arch}.deb" in line and "browser_download_url" in line:
            deb_url = line.split('"browser_download_url": "')[-1].strip('", ')
            break
    if not deb_url:
        print(
            f"{RED}Error:{NC} Could not find .deb package for {arch}", file=sys.stderr
        )
        sys.exit(1)
    tmp = tempfile.mktemp(suffix=".deb")
    subprocess.run(["curl", "-sL", deb_url, "-o", tmp], check=True)
    run(f"dpkg -i {tmp}", check=True)
    os.remove(tmp)
    print(f"{GREEN}==> {NC}Run 'carch' to get started")


def cmd_install():
    distro = detect_distro()
    if distro == "unsupported":
        print(
            f"{RED}Error:{NC} carch is not supported on this distribution.",
            file=sys.stderr,
        )
        sys.exit(1)
    if distro == "termux":
        install_termux()
    elif distro == "arch":
        install_arch()
    elif distro in ("fedora", "opensuse"):
        install_rpm(distro)


def cmd_run(mode):
    arch = detect_arch()
    if mode == "dev":
        url = get_dev_url(arch)
    else:
        url = get_stable_url(arch)
    print(f"{GREEN}==> {NC}Using URL: {url}")
    tmp = tempfile.mktemp()
    subprocess.run(
        [
            "curl",
            "-L",
            "-s",
            "--connect-timeout",
            "10",
            "--max-time",
            "120",
            url,
            "-o",
            tmp,
        ],
        check=True,
    )
    os.chmod(tmp, 0o755)
    r = subprocess.run([tmp] + sys.argv[2:])
    os.remove(tmp)
    sys.exit(r.returncode)


def main():
    args = sys.argv[1:]
    if not args:
        print(f"{RED}Usage:{NC} setup.py [--install|--dev|--stable]")
        print(f"  {YELLOW}--install{NC}  Install via package manager")
        print(f"  {YELLOW}--dev{NC}      Download and run dev binary")
        print(f"  {YELLOW}--stable{NC}   Download and run stable binary")
        sys.exit(1)
    elif args[0] == "--install":
        cmd_install()
    elif args[0] == "--dev":
        cmd_run("dev")
    elif args[0] == "--stable":
        cmd_run("stable")
    else:
        print(f"{RED}Usage:{NC} setup.py [--install|--dev|--stable]")
        sys.exit(1)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print()
        sys.exit(130)
