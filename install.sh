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
            printf "aarch64-android"
            ;;
        armv7* | armv8l | arm | armeabi-v7a)
            printf "armv7-android"
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

download_and_install_binary() {
    bin_url="$1"

    tmp_file="$(mktemp)"

    curl -sL "$bin_url" -o "$tmp_file"

    if [ $? -ne 0 ]; then
        rm -f "$tmp_file"
        printf "${RED}Error:${NC} Download failed\n" >&2
        exit 1
    fi

    chmod +x "$tmp_file"

    mv "$tmp_file" "$PREFIX/bin/carch"

    if [ $? -ne 0 ]; then
        rm -f "$tmp_file"
        printf "${RED}Error:${NC} Failed to install binary\n" >&2
        exit 1
    fi
}

install_termux() {
    termux_arch=$(detect_termux_arch)

    case "$termux_arch" in
        aarch64-android) asset="carch-aarch64-android" ;;
        armv7-android)   asset="carch-armv7-android" ;;
    esac

    printf "${GREEN}==> ${NC}Detected Termux architecture: %s\n" "$(uname -m)"
    printf "${GREEN}==> ${NC}Fetching latest release asset: %s\n" "$asset"

    bin_url=$(get_latest_release_url "$asset")

    if [ -z "$bin_url" ]; then
        printf "${RED}Error:${NC} Could not find download URL for asset '%s'\n" "$asset" >&2
        exit 1
    fi

    printf "${GREEN}==> ${NC}Downloading %s...\n" "$asset"
    download_and_install_binary "$bin_url"

    printf "${GREEN}==> ${NC}carch installed to %s/bin/carch\n" "$PREFIX"
    printf "${GREEN}==> ${NC}Run 'carch' to get started\n"
}

install_arch() {
    printf "${GREEN}==> ${NC}Cloning PKGBUILD\n"

    rm -rf ~/pkgs

    git clone https://github.com/carch-org/pkgs ~/pkgs > /dev/null 2>&1

    cd ~/pkgs/carch-bin || exit 1

    makepkg -si --noconfirm
}

install_fedora() {
    printf "${YELLOW}:: ${NC}downloading carch rpm\n"

    rpm_url=$(curl -sL https://api.github.com/repos/harilvfs/carch/releases/latest |
        grep browser_download_url |
        grep '\.rpm"' |
        cut -d '"' -f 4)

    if [ -z "$rpm_url" ]; then
        printf "${RED}Error:${NC} Could not find RPM package URL\n"
        exit 1
    fi

    curl -sL "$rpm_url" -o /tmp/carch.rpm > /dev/null 2>&1

    sudo dnf install -y /tmp/carch.rpm
}

install_opensuse() {
    printf "${YELLOW}:: ${NC}downloading carch rpm\n"

    rpm_url=$(curl -sL https://api.github.com/repos/harilvfs/carch/releases/latest |
        grep browser_download_url |
        grep '\.rpm"' |
        cut -d '"' -f 4)

    if [ -z "$rpm_url" ]; then
        printf "${RED}Error:${NC} Could not find RPM package URL\n"
        exit 1
    fi

    curl -sL "$rpm_url" -o /tmp/carch.rpm > /dev/null 2>&1

    sudo zypper install -y /tmp/carch.rpm
}

uninstall_termux() {
    if [ -f "$PREFIX/bin/carch" ]; then
        rm -f "$PREFIX/bin/carch"
        printf "${GREEN}==> ${NC}carch removed from %s/bin\n" "$PREFIX"
    else
        printf "${YELLOW}==> ${NC}carch is not installed in %s/bin\n" "$PREFIX"
    fi
}

uninstall_arch() {
    sudo pacman -R carch-bin carch-bin-debug --noconfirm
}

uninstall_fedora() {
    sudo dnf remove carch -y
}

uninstall_opensuse() {
    sudo zypper remove -y carch
}

update_termux() {
    printf "${GREEN}==> ${NC}Updating carch...\n"
    install_termux
}

update_arch() {
    printf "${GREEN}==> ${NC}Updating carch...\n"
    install_arch
}

update_fedora() {
    printf "${GREEN}==> ${NC}Updating carch...\n"
    install_fedora
}

update_opensuse() {
    printf "${GREEN}==> ${NC}Updating carch...\n"
    install_opensuse
}

main() {
    action="${1:-install}"

    case "$action" in
        install | uninstall | update)
            ;;
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
                termux)   install_termux ;;
                arch)     install_arch ;;
                fedora)   install_fedora ;;
                opensuse) install_opensuse ;;
            esac
            ;;
        uninstall)
            case "$distro" in
                termux)   uninstall_termux ;;
                arch)     uninstall_arch ;;
                fedora)   uninstall_fedora ;;
                opensuse) uninstall_opensuse ;;
            esac
            ;;
        update)
            case "$distro" in
                termux)   update_termux ;;
                arch)     update_arch ;;
                fedora)   update_fedora ;;
                opensuse) update_opensuse ;;
            esac
            ;;
    esac
}

main "$@"
