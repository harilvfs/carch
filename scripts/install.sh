#!/usr/bin/env bash

set -euo pipefail

REPO="harilvfs/carch"
API_BASE="https://api.github.com"
TIMEOUT=10

error_exit() {
    echo "Error: $1" >&2
    exit 1
}

check_requirements() {
    local missing=()
    for tool in curl jq; do
        command -v "$tool" > /dev/null || missing+=("$tool")
    done
    [[ ${#missing[@]} -eq 0 ]] || error_exit "Missing required tools: ${missing[*]}"
}

detect_architecture() {
    case "$(uname -m)" in
        x86_64 | amd64) echo "amd64" ;;
        aarch64 | arm64) echo "arm64" ;;
        *) error_exit "Unsupported architecture: $(uname -m)" ;;
    esac
}

get_latest_release() {
    local url="${API_BASE}/repos/${REPO}/releases/latest"
    curl -sSL --connect-timeout "$TIMEOUT" --max-time 30 "$url" || error_exit "Failed to fetch release info"
}

get_download_url() {
    local json=$1
    local arch=$2
    local asset_name="carch-installer-linux-${arch}"

    echo "$json" | jq -r ".assets[] | select(.name == \"$asset_name\") | .browser_download_url" | head -1
}

download_installer() {
    local url=$1
    local tmp_file=$2

    curl -L --progress-bar --connect-timeout "$TIMEOUT" --max-time 120 "$url" -o "$tmp_file" || {
        rm -f "$tmp_file"
        error_exit "Download failed"
    }
}

main() {
    [[ $# -le 1 ]] || error_exit "Too many arguments"

    check_requirements

    local arch tmp_file json url
    arch="$(detect_architecture)"
    tmp_file="$(mktemp)"

    trap 'rm -f "$tmp_file"' EXIT

    json="$(get_latest_release)"

    url="$(get_download_url "$json" "$arch")"
    [[ -n "$url" && "$url" != "null" ]] || error_exit "No binary found for $arch"

    download_installer "$url" "$tmp_file"

    chmod +x "$tmp_file"
    exec "$tmp_file" "${1:-}"
}

main "$@"
