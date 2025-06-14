#!/usr/bin/env bash

set -e

error_exit() {
    echo "Error: $1" >&2
    exit 1
}

check_requirements() {
    for tool in curl jq; do
        if ! command -v "$tool" &> /dev/null; then
            error_exit "Required tool not found: $tool"
        fi
    done
}

spinner() {
    local pid=$1
    local spin="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local i=0

    tput civis 2>/dev/null || true

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r%s" "${spin:i++%${#spin}:1}"
        sleep 0.1
    done

    tput cnorm 2>/dev/null || true
    printf "\r✔\n"
}

detect_architecture() {
    local arch
    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64) echo "amd64" ;;
        aarch64|arm64) echo "arm64" ;;
        *) error_exit "Unsupported architecture: $arch" ;;
    esac
}

fetch_releases_json() {
    curl -s "https://api.github.com/repos/harilvfs/carch/releases"
}

find_tag() {
    local json=$1
    local tag

    tag="$(echo "$json" | jq -r '.[] | select(.prerelease == true) | .tag_name' | head -n1)"

    if [ -z "$tag" ] || [ "$tag" == "null" ]; then
        tag="$(echo "$json" | jq -r '.[] | select(.prerelease == false) | .tag_name' | head -n1)"
    fi

    if [ -z "$tag" ] || [ "$tag" == "null" ]; then
        error_exit "No release found"
    fi

    echo "$tag"
}

find_asset_url() {
    local json=$1
    local tag=$2
    local arch=$3
    local asset_name
    local url

    asset_name="carch-installer-linux-${arch}"

    url="$(echo "$json" | jq -r ".[] | select(.tag_name == \"$tag\") | .assets[] | select(.name == \"$asset_name\") | .browser_download_url")"

    if [ -z "$url" ] || [ "$url" == "null" ]; then
        error_exit "Release asset not found for $asset_name"
    fi

    echo "$url"
}

main() {
    if [ "$#" -gt 1 ]; then
        error_exit "Too many arguments. Only one optional command (update, uninstall, help) allowed."
    fi

    check_requirements

    arch="$(detect_architecture)"
    json="$(fetch_releases_json)"
    tag="$(find_tag "$json")"
    url="$(find_asset_url "$json" "$tag" "$arch")"

    tmp_file="$(mktemp)"

    (
        curl -Ls "$url" -o "$tmp_file"
    ) &

    spinner $!

    wait $!

    chmod +x "$tmp_file"
    "$tmp_file" "$1"
    rm -f "$tmp_file"
}

main "$@"
