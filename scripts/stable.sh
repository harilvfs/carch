#!/usr/bin/env bash

rc='\033[0m'
red='\033[0;31m'

check_dependency() {
    if ! command -v "$1" > /dev/null 2>&1; then
        if command -v pacman > /dev/null 2>&1; then
            sudo pacman -Sy --noconfirm "$1"
        elif command -v dnf > /dev/null 2>&1; then
            sudo dnf install -y "$1"
        else
            printf '%bERROR: Package manager not supported%b\n' "$red" "$rc"
            exit 1
        fi
    fi
}

for pkg in fzf git grep; do
    check_dependency "$pkg"
done

check() {
    exit_code=$1
    message=$2
    if [ "$exit_code" -ne 0 ]; then
        printf '%bERROR: %s%b\n' "$red" "$message" "$rc"
        exit 1
    fi
}

findArch() {
    case "$(uname -m)" in
        x86_64 | amd64) arch="x86_64" ;;
        aarch64 | arm64) arch="aarch64" ;;
        *) check 1 "Unsupported architecture" ;;
    esac
}

getUrl() {
    case "${arch}" in
        x86_64) echo "https://github.com/harilvfs/carch/releases/latest/download/carch" ;;
        *) echo "https://github.com/harilvfs/carch/releases/latest/download/carch-${arch}" ;;
    esac
}

TIMEOUT=10

findArch
temp_file=$(mktemp)
check $? "Creating the temporary file"

url="$(getUrl)"
curl -L --progress-bar --connect-timeout "$TIMEOUT" --max-time 120 "$url" -o "$temp_file"
check $? "Downloading carch"

chmod +x "$temp_file"
check $? "Making carch executable"

"$temp_file" "$@"
check $? "Executing carch"

rm -f "$temp_file"
check $? "Deleting the temporary file"
