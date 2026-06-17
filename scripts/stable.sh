#!/bin/sh
set -e

REPO="harilvfs/carch"
BINARY="carch"

detect_target() {
    ARCH=$(uname -m)
    OS=$(uname -s)

    case "$OS" in
        Linux)
            if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
                case "$ARCH" in
                    aarch64 | arm64) echo "aarch64-android" ;;
                    armv7* | armv8l | arm) echo "armv7-android" ;;
                    *)
                        echo "Unsupported architecture: $ARCH" >&2
                        exit 1
                        ;;
                esac
            else
                case "$ARCH" in
                    x86_64 | amd64) echo "" ;;
                    aarch64 | arm64) echo "-aarch64" ;;
                    *)
                        echo "Unsupported architecture: $ARCH" >&2
                        exit 1
                        ;;
                esac
            fi
            ;;
        *)
            echo "Unsupported OS: $OS" >&2
            exit 1
            ;;
    esac
}

get_latest_version() {
    curl -fsL "https://api.github.com/repos/$REPO/releases/latest" 2> /dev/null |
        grep '"tag_name"' | cut -d'"' -f4
}

SUFFIX=$(detect_target)
VERSION=$(get_latest_version)

GITHUB="https://github.com/$REPO/releases/download"
BINARY_URL="${GITHUB}/${VERSION}/${BINARY}${SUFFIX}"
CHECKSUM_URL="${BINARY_URL}.sha256"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

printf "==> Platform: %s\n" "$(uname -m)"
printf "==> Version:  %s\n" "$VERSION"
printf "==> Downloading %s...\n" "${BINARY}${SUFFIX}"

curl -fsL "$BINARY_URL" -o "$TMPDIR/$BINARY"
curl -fsL "$CHECKSUM_URL" -o "$TMPDIR/$BINARY.sha256" 2> /dev/null ||
    printf "Warning: No checksum file found, skipping verification.\n"

if [ -f "$TMPDIR/$BINARY.sha256" ]; then
    printf "==> Verifying checksum...\n"
    (cd "$TMPDIR" && sha256sum -c "$BINARY.sha256")
fi

chmod +x "$TMPDIR/$BINARY"
"$TMPDIR/$BINARY"
