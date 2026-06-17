#!/bin/sh
set -e

SCRIPTS_URL="https://raw.githubusercontent.com/harilvfs/carch/main/scripts"

usage() {
    printf "Usage: %s [command]\n\n" "$(basename "$0")"
    printf "Commands:\n"
    printf "  install          Install carch on your system\n"
    printf "  --stable         Download and run the stable binary (no install)\n"
    printf "  --dev            Download and run the latest prerelease (no install)\n"
    printf "  -h, --help       Show this help message\n"
    exit 0
}

[ $# -eq 0 ] && usage

case "$1" in
    install)
        curl -fsSL "$SCRIPTS_URL/install.sh" | sh
        ;;
    --stable)
        curl -fsSL "$SCRIPTS_URL/stable.sh" | sh
        ;;
    --dev)
        curl -fsSL "$SCRIPTS_URL/dev.sh" | sh
        ;;
    -h | --help)
        usage
        ;;
    *)
        printf "Error: Unknown command '%s'\n\n" "$1"
        usage
        ;;
esac
