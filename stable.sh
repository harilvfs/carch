#!/bin/sh

set -eu

check() {
    if [ "$1" -ne 0 ]; then
        printf "Error: %s\n" "$2" >&2
        exit "$1"
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
        x86_64) printf "https://github.com/harilvfs/carch/releases/latest/download/carch\n" ;;
        *) printf "https://github.com/harilvfs/carch/releases/latest/download/carch-%s\n" "${arch}" ;;
    esac
}

TIMEOUT=10
findArch
temp_file=$(mktemp)
check $? "Creating the temporary file"
url="$(getUrl)"
curl -L -s --connect-timeout "$TIMEOUT" --max-time 120 "$url" -o "$temp_file"
check $? "Downloading carch"
chmod +x "$temp_file"
check $? "Making carch executable"
"$temp_file" "$@"
check $? "Executing carch"
rm -f "$temp_file"
check $? "Deleting the temporary file"
