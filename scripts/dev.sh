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

get_latest_release() {
    latest_release=$(curl -s "https://api.github.com/repos/harilvfs/carch/releases" |
        grep "tag_name" |
        head -n 1 |
        sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
    if [ -z "$latest_release" ]; then
        printf '%bERROR: Failed to fetch release data%b\n' "$red" "$rc" >&2
        return 1
    fi
    printf "%s\n" "$latest_release"
}

addArch() {
    case "${arch}" in
        x86_64) ;;
        *) url="${url}-${arch}" ;;
    esac
}

set_download_url() {
    latest_release=$(get_latest_release)
    if [ -n "$latest_release" ]; then
        url="https://github.com/harilvfs/carch/releases/download/$latest_release/carch"
    else
        printf '%bWARNING: Unable to determine latest release version. Falling back to latest.%b\n' "$red" "$rc"
        url="https://github.com/harilvfs/carch/releases/latest/download/carch"
    fi
    addArch
    printf "Using URL: %s\n" "$url"
}

TIMEOUT=10

findArch
set_download_url

temp_file=$(mktemp)
check $? "Creating the temporary file"

curl -L --progress-bar --connect-timeout "$TIMEOUT" --max-time 120 "$url" -o "$temp_file"
check $? "Downloading carch"

chmod +x "$temp_file"
check $? "Making carch executable"

"$temp_file" "$@"
check $? "Executing carch"

rm -f "$temp_file"
check $? "Deleting the temporary file"
