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

for pkg in fzf git grep; do
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

findArch() {
    case "$(uname -m)" in
        x86_64|amd64) arch="x86_64" ;;
        aarch64|arm64) arch="aarch64" ;;
        *) check 1 "Unsupported architecture"
    esac
}

get_latest_release() {
    latest_release=$(curl -s "https://api.github.com/repos/harilvfs/carch/releases" |
        grep "tag_name" |
        head -n 1 |
        sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
    if [ -z "$latest_release" ]; then
        printf "Error fetching release data\n" >&2
        return 1
    fi
    printf "%s\n" "$latest_release"
}

set_download_url() {
    latest_release=$(get_latest_release)
    if [ -n "$latest_release" ]; then
        url="https://github.com/harilvfs/carch/releases/download/$latest_release/carch"
    else
        printf "Unable to determine latest release version.\n" >&2
        printf "Using latest Full Release\n"
        url="https://github.com/harilvfs/carch/releases/latest/download/carch"
    fi
    addArch
    printf "Using URL: %s\n" "$url"
}

addArch() {
    case "${arch}" in
        x86_64);;
        *) url="${url}-${arch}";;
    esac
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

findArch
set_download_url

temp_file=$(mktemp)
check $? "Creating the temporary file"

curl -fsL "$url" -o "$temp_file" &
spinner $!

check $? "Downloading carch"
chmod +x "$temp_file"
check $? "Making carch executable"
"$temp_file" "$@"
check $? "Executing carch"
rm -f "$temp_file"
check $? "Deleting the temporary file"
