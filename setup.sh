#!/bin/sh

red='\033[0;31m'
green='\033[1;32m'
yellow='\033[1;33m'
nc='\033[0m'

usage() {
    printf "Usage: %s [command] [options]\n\n" "$(basename "$0")"
    printf "Commands:\n"
    printf "  install          Install carch on your system\n\n"
    printf "Options:\n"
    printf "  --stable         Download and run the stable binary\n"
    printf "  --dev            Download and run the dev binary\n"
    printf "  -h, --help       Help message\n"
    exit 0
}

check() {
    if [ "$1" -ne 0 ]; then
        printf "%bError:%b %s\n" "$red" "$nc" "$2" >&2
        exit "$1"
    fi
}

is_termux() {
    [ -n "$TERMUX_VERSION" ] ||
        [ -d "/data/data/com.termux" ] ||
        [ "$(uname -o 2> /dev/null)" = "Android" ]
}

detect_termux_arch() {
    case "$(uname -m)" in
        aarch64 | arm64) printf "aarch64" ;;
        armv7* | armv8l | arm | armeabi-v7a) printf "arm" ;;
        *)
            printf "%bError:%b Unsupported architecture for Termux: %s\n" "$red" "$nc" "$(uname -m)" >&2
            exit 1
            ;;
    esac
}

detect_distro() {
    if is_termux; then
        printf "termux"
    elif command -v pacman > /dev/null 2>&1; then
        printf "arch"
    elif command -v dnf > /dev/null 2>&1; then
        printf "fedora"
    elif command -v zypper > /dev/null 2>&1; then
        printf "opensuse"
    else
        printf "unsupported"
    fi
}

get_latest_release_url() {
    asset_name="$1"
    curl -sL https://api.github.com/repos/harilvfs/carch/releases/latest |
        grep browser_download_url |
        grep "$asset_name" |
        cut -d '"' -f 4 |
        head -n1
}

get_rpm_url() {
    curl -sL https://api.github.com/repos/harilvfs/carch/releases/latest |
        grep browser_download_url |
        grep '\.rpm"' |
        cut -d '"' -f 4
}

install_termux() {
    deb_arch=$(detect_termux_arch)
    printf "%b==>%b Detected Termux architecture: %s\n" "$green" "$nc" "$(uname -m)"
    printf "%b==>%b Fetching latest .deb package for %s...\n" "$green" "$nc" "$deb_arch"

    deb_url=$(get_latest_release_url "_${deb_arch}\\.deb")
    if [ -z "$deb_url" ]; then
        printf "%bError:%b Could not find .deb package for '%s'\n" "$red" "$nc" "$deb_arch" >&2
        exit 1
    fi

    tmp_deb="$(mktemp "$PREFIX/tmp/carch_XXXXXX.deb")"
    printf "%b==>%b Downloading .deb package...\n" "$green" "$nc"
    curl -sL "$deb_url" -o "$tmp_deb"
    check $? "Download failed"

    printf "%b==>%b Installing .deb package...\n" "$green" "$nc"
    dpkg -i "$tmp_deb"
    rm -f "$tmp_deb"

    printf "%b==>%b Run 'carch' to get started\n" "$green" "$nc"
}

install_arch() {
    printf "%b==>%b Cloning PKGBUILD\n" "$green" "$nc"
    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT
    git clone https://github.com/carch-org/pkgs "$tmpdir" > /dev/null 2>&1
    cd "$tmpdir/carch-bin" || exit 1
    makepkg -si --noconfirm
}

install_rpm() {
    distro="$1"
    printf "%b==>%b Downloading carch rpm\n" "$green" "$nc"

    rpm_url=$(get_rpm_url)
    if [ -z "$rpm_url" ]; then
        printf "%bError:%b Could not find RPM package URL\n" "$red" "$nc" >&2
        exit 1
    fi

    curl -L "$rpm_url" -o /tmp/carch.rpm

    case "$distro" in
        fedora)   sudo dnf install -y /tmp/carch.rpm ;;
        opensuse) sudo zypper install -y --allow-unsigned-rpm /tmp/carch.rpm ;;
    esac
}

do_install() {
    distro=$(detect_distro)

    if [ "$distro" = "unsupported" ]; then
        printf "%bError:%b carch is not supported on this distribution.\n" "$red" "$nc"
        exit 1
    fi

    case "$distro" in
        termux)            install_termux ;;
        arch)              install_arch ;;
        fedora | opensuse) install_rpm "$distro" ;;
    esac
}

find_arch() {
    case "$(uname -m)" in
        x86_64 | amd64) arch="x86_64" ;;
        aarch64 | arm64)
            if is_termux; then
                arch="aarch64-android"
            else
                arch="aarch64"
            fi
            ;;
        armv7* | armv8l | arm)
            if is_termux; then
                arch="armv7-android"
            else
                check 1 "Unsupported architecture: 32-bit ARM is only supported on Android/Termux"
            fi
            ;;
        *) check 1 "Unsupported architecture: $(uname -m)" ;;
    esac
}

get_stable_url() {
    case "${arch}" in
        x86_64)           printf "https://github.com/harilvfs/carch/releases/latest/download/carch" ;;
        aarch64)          printf "https://github.com/harilvfs/carch/releases/latest/download/carch-aarch64" ;;
        aarch64-android)  printf "https://github.com/harilvfs/carch/releases/latest/download/carch-aarch64-android" ;;
        armv7-android)    printf "https://github.com/harilvfs/carch/releases/latest/download/carch-armv7-android" ;;
    esac
}

get_latest_release() {
    latest_release=$(curl -s "https://api.github.com/repos/harilvfs/carch/releases" |
        grep "tag_name" |
        head -n 1 |
        sed -E 's/.*"tag_name": "([^"]+)".*/\1/')

    if [ -z "$latest_release" ]; then
        printf "%bError:%b Failed to fetch release data\n" "$red" "$nc" >&2
        return 1
    fi

    printf "%s\n" "$latest_release"
}

get_dev_url() {
    base_url="https://github.com/harilvfs/carch/releases/download/$1/carch"

    case "${arch}" in
        x86_64)          printf "%s" "$base_url" ;;
        aarch64)         printf "%s-aarch64" "$base_url" ;;
        aarch64-android) printf "%s-aarch64-android" "$base_url" ;;
        armv7-android)   printf "%s-armv7-android" "$base_url" ;;
    esac
}

set_dev_url() {
    latest_release=$(get_latest_release)

    if [ -n "$latest_release" ]; then
        url="$(get_dev_url "$latest_release")"
    else
        printf "%bWARNING:%b Unable to determine latest release version. Falling back to latest.\n" "$yellow" "$nc"
        url="$(get_stable_url)"
    fi

    printf "Using URL: %s\n" "$url"
}

do_run() {
    mode="$1"
    TIMEOUT=10
    find_arch

    if [ "$mode" = "dev" ]; then
        set_dev_url
    else
        url="$(get_stable_url)"
    fi

    temp_file=$(mktemp)
    check $? "Creating the temporary file"

    printf "%b==>%b Downloading carch...\n" "$green" "$nc"
    curl -L --connect-timeout "$TIMEOUT" --max-time 120 "$url" -o "$temp_file"
    check $? "Downloading carch"

    chmod +x "$temp_file"
    check $? "Making carch executable"

    "$temp_file"
    check $? "Executing carch"

    rm -f "$temp_file"
    check $? "Deleting the temporary file"
}

if [ $# -eq 0 ]; then
    usage
fi

case "$1" in
    install)
        do_install
        ;;
    --stable)
        do_run stable
        ;;
    --dev)
        do_run dev
        ;;
    -h | --help)
        usage
        ;;
    *)
        printf "%bError:%b Unknown command '%s'\n\n" "$red" "$nc" "$1"
        usage
        ;;
esac
