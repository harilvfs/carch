#!/usr/bin/env bash

rc='\033[0m'
red='\033[0;31m'

check_dependency() {
    if ! command -v "$1" >/dev/null 2>&1; then
        if command -v pacman >/dev/null 2>&1; then
            sudo pacman -Sy --noconfirm "$1"
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y "$1"
        else
            printf '%sERROR: Package manager not supported%s\n' "$red" "$rc"
            exit 1
        fi
    fi
}

for pkg in fzf figlet; do
    check_dependency "$pkg"
done

check() {
    exit_code=$1
    message=$2
    if [ "$exit_code" -ne 0 ]; then
        printf '%sERROR: %s%s\n' "$red" "$message" "$rc"
        exit 1
    fi
}

spinner() {
    local pid=$1
    local spin="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r%s" "${spin:i++%${#spin}:1}"
        sleep 0.1
    done
    printf "\r✔\n"
}

temp_file=$(mktemp)
check $? "Creating the temporary file"

curl -fsL "https://github.com/harilvfs/carch/releases/latest/download/carch-installer" -o "$temp_file" &
spinner $!

check $? "Downloading carch-installer"
chmod +x "$temp_file"
check $? "Making carch-installer executable"
"$temp_file" "$@"
check $? "Executing carch-installer"
rm -f "$temp_file"
check $? "Deleting the temporary file" 