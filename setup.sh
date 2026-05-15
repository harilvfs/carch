#!/bin/sh

red='\033[0;31m'
rc='\033[0m'
mode="stable"

while [ $# -gt 0 ]; do
    case "$1" in
        --dev)
            mode="dev"
            shift
            ;;
        --stable)
            mode="stable"
            shift
            ;;
        *)
            break
            ;;
    esac
done

check() {
    if [ "$1" -ne 0 ]; then
        printf "Error: %s\n" "$2" >&2
        exit "$1"
    fi
}

isAndroid() {
    [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ] || [ "$(uname -o 2> /dev/null)" = "Android" ]
}

findArch() {
    case "$(uname -m)" in
        x86_64 | amd64)
            arch="x86_64"
            ;;
        aarch64 | arm64)
            if isAndroid; then
                arch="aarch64-android"
            else
                arch="aarch64"
            fi
            ;;
        armv7* | armv8l | arm)
            if isAndroid; then
                arch="armv7-android"
            else
                check 1 "Unsupported architecture: 32-bit ARM is only supported on Android/Termux"
            fi
            ;;
        *)
            check 1 "Unsupported architecture: $(uname -m)"
            ;;
    esac
}

getStableUrl() {
    case "${arch}" in
        x86_64)
            printf "https://github.com/harilvfs/carch/releases/latest/download/carch\n"
            ;;
        aarch64)
            printf "https://github.com/harilvfs/carch/releases/latest/download/carch-aarch64\n"
            ;;
        aarch64-android)
            printf "https://github.com/harilvfs/carch/releases/latest/download/carch-aarch64-android\n"
            ;;
        armv7-android)
            printf "https://github.com/harilvfs/carch/releases/latest/download/carch-armv7-android\n"
            ;;
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

getDevUrl() {
    base_url="https://github.com/harilvfs/carch/releases/download/$1/carch"

    case "${arch}" in
        x86_64)
            printf "%s\n" "$base_url"
            ;;
        aarch64)
            printf "%s-aarch64\n" "$base_url"
            ;;
        aarch64-android)
            printf "%s-aarch64-android\n" "$base_url"
            ;;
        armv7-android)
            printf "%s-armv7-android\n" "$base_url"
            ;;
    esac
}

set_dev_url() {
    latest_release=$(get_latest_release)

    if [ -n "$latest_release" ]; then
        url="$(getDevUrl "$latest_release")"
    else
        printf '%bWARNING: Unable to determine latest release version. Falling back to latest.%b\n' "$red" "$rc"
        url="$(getStableUrl)"
    fi

    printf "Using URL: %s\n" "$url"
}

TIMEOUT=10
findArch

if [ "$mode" = "dev" ]; then
    set_dev_url
else
    url="$(getStableUrl)"
fi

temp_file=$(mktemp)
check $? "Creating the temporary file"

curl -L -s --connect-timeout "$TIMEOUT" --max-time 120 "$url" -o "$temp_file"
check $? "Downloading carch"

chmod +x "$temp_file"
check $? "Making carch executable"

"$temp_file" "$@"
check $? "Executing carch"

rm -f "$temp_file"
check $? "Deleting the temporary file"
