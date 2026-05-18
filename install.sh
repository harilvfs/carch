#!/bin/sh

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

show_usage() {
    printf "Usage: carch [install|uninstall|update]\n"
    printf "  install   - Install carch (default)\n"
    printf "  uninstall - Remove carch from system\n"
    printf "  update    - Update carch to latest version\n"
    exit 1
}

is_termux() {
    [ -n "$TERMUX_VERSION" ] ||
        [ -d "/data/data/com.termux" ] ||
        [ "$(uname -o 2> /dev/null)" = "Android" ]
}

detect_termux_arch() {
    case "$(uname -m)" in
        aarch64 | arm64)
            printf "aarch64"
            ;;
        armv7* | armv8l | arm | armeabi-v7a)
            printf "arm"
            ;;
        *)
            printf "${RED}Error:${NC} Unsupported architecture for Termux: %s\n" "$(uname -m)" >&2
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
        exit 1
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

    printf "${GREEN}==> ${NC}Detected Termux architecture: %s\n" "$(uname -m)"
    printf "${GREEN}==> ${NC}Fetching latest .deb package for %s...\n" "$deb_arch"

    deb_url=$(get_latest_release_url "_${deb_arch}\.deb")
    if [ -z "$deb_url" ]; then
        printf "${RED}Error:${NC} Could not find .deb package for '%s'\n" "$deb_arch" >&2
        exit 1
    fi

    tmp_deb="$(mktemp "$PREFIX/tmp/carch_XXXXXX.deb")"
    printf "${GREEN}==> ${NC}Downloading .deb package...\n"
    curl -sL "$deb_url" -o "$tmp_deb"
    if [ $? -ne 0 ]; then
        rm -f "$tmp_deb"
        printf "${RED}Error:${NC} Download failed\n" >&2
        exit 1
    fi

    printf "${GREEN}==> ${NC}Installing .deb package...\n"
    dpkg -i "$tmp_deb"
    rm -f "$tmp_deb"

    printf "${GREEN}==> ${NC}Run 'carch' to get started\n"
}

install_arch() {
    printf "${GREEN}==> ${NC}Cloning PKGBUILD\n"
    rm -rf ~/pkgs
    git clone https://github.com/carch-org/pkgs ~/pkgs > /dev/null 2>&1
    cd ~/pkgs/carch-bin || exit 1
    makepkg -si --noconfirm
}

install_rpm() {
    distro="$1"
    printf "${YELLOW}:: ${NC}Downloading carch rpm\n"

    rpm_url=$(get_rpm_url)
    if [ -z "$rpm_url" ]; then
        printf "${RED}Error:${NC} Could not find RPM package URL\n" >&2
        exit 1
    fi

    curl -sL "$rpm_url" -o /tmp/carch.rpm > /dev/null 2>&1

    case "$distro" in
        fedora)   sudo dnf install -y /tmp/carch.rpm ;;
        opensuse) sudo zypper install -y --allow-unsigned-rpm /tmp/carch.rpm ;;
    esac
}

uninstall_termux() {
    if dpkg -s carch > /dev/null 2>&1; then
        dpkg -r carch
        printf "${GREEN}==> ${NC}carch has been removed\n"
    else
        printf "${YELLOW}==> ${NC}carch is not installed\n"
    fi
}

uninstall_arch() {
    sudo pacman -R carch-bin carch-bin-debug --noconfirm
}

uninstall_rpm() {
    distro="$1"
    case "$distro" in
        fedora)   sudo dnf remove carch -y ;;
        opensuse) sudo zypper remove -y carch ;;
    esac
}

main() {
    action="${1:-install}"

    case "$action" in
        install | uninstall | update) ;;
        *)
            printf "${RED}Error:${NC} Invalid action '%s'\n" "$action"
            show_usage
            ;;
    esac

    distro=$(detect_distro)

    if [ "$distro" = "unsupported" ]; then
        printf "${RED}Error:${NC} carch is not supported on this distribution.\n"
        exit 1
    fi

    case "$action" in
        install)
            case "$distro" in
                termux)            install_termux ;;
                arch)              install_arch ;;
                fedora | opensuse) install_rpm "$distro" ;;
            esac
            ;;
        uninstall)
            case "$distro" in
                termux)            uninstall_termux ;;
                arch)              uninstall_arch ;;
                fedora | opensuse) uninstall_rpm "$distro" ;;
            esac
            ;;
        update)
            printf "${GREEN}==> ${NC}Updating carch...\n"
            case "$distro" in
                termux)            install_termux ;;
                arch)              install_arch ;;
                fedora | opensuse) install_rpm "$distro" ;;
            esac
            ;;
    esac
}

main "$@"
