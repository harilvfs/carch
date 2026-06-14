#!/usr/bin/env python3
import os
import shutil
import subprocess
import sys

ROOT = os.path.dirname(os.path.abspath(__file__))
IGNORED = {"build", ".git", "target"}
IGNORED_FILES = {"Extensions.sh"}


def find_files(ext):
    result = []
    for dirpath, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d not in IGNORED]
        for f in files:
            if f.endswith(ext) and f not in IGNORED_FILES:
                result.append(os.path.join(dirpath, f))
    return sorted(result)


def run_cmd(cmd):
    result = subprocess.run(cmd)
    return result.returncode


def main():
    check_only = "--check" in sys.argv
    exit_code = 0

    print("Formatting shell scripts...")
    if shutil.which("shfmt"):
        sh_files = find_files(".sh")
        if sh_files:
            if check_only:
                exit_code |= run_cmd(
                    ["shfmt", "-i", "4", "-ci", "-sr", "-kp", "-d"] + sh_files
                )
            else:
                run_cmd(["shfmt", "-i", "4", "-ci", "-sr", "-kp", "-w"] + sh_files)
        print("Shell formatting complete.")
    else:
        print("WARNING: shfmt not found. Skipping shell formatting.")

    print("\nFormatting Python scripts...")
    if shutil.which("ruff"):
        py_files = find_files(".py")
        if py_files:
            if check_only:
                exit_code |= run_cmd(["ruff", "format", "--check"] + py_files)
                exit_code |= run_cmd(["ruff", "check"] + py_files)
            else:
                run_cmd(["ruff", "format"] + py_files)
                run_cmd(["ruff", "check", "--fix"] + py_files)
        print("Python formatting complete.")
    else:
        print("WARNING: ruff not found. Skipping Python formatting.")

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
