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
                    aarch64 | arm64) echo "-aarch64-android" ;;
                    armv7* | armv8l | arm) echo "-armv7-android" ;;
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

get_latest_stable_version() {
    curl -fsL "https://api.github.com/repos/$REPO/releases/latest" 2> /dev/null |
        grep '"tag_name"' | head -1 | cut -d'"' -f4
}

get_latest_prerelease_version() {
    curl -fsL "https://api.github.com/repos/$REPO/releases" 2> /dev/null |
        awk '
            /"tag_name":/ {
                tag = $0
                sub(/.*"tag_name": *"/, "", tag)
                sub(/".*/, "", tag)
            }
            /"prerelease": *true/ {
                print tag
                exit
            }
        '
}

SUFFIX=$(detect_target)
VERSION=$(get_latest_prerelease_version)

if [ -z "$VERSION" ]; then
    printf "Warning: No prerelease found, falling back to stable.\n" >&2
    VERSION=$(get_latest_stable_version)
fi

if [ -z "$VERSION" ]; then
    printf "Error: could not determine a release version.\n" >&2
    exit 1
fi

GITHUB="https://github.com/$REPO/releases/download"
ARTIFACT="${BINARY}${SUFFIX}"
BINARY_URL="${GITHUB}/${VERSION}/${ARTIFACT}"
CHECKSUM_URL="${BINARY_URL}.sha256"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

printf "==> Platform: %s\n" "$(uname -m)"
printf "==> Version:  %s\n" "$VERSION"
printf "==> Downloading %s...\n" "$ARTIFACT"
curl -fsSL "$BINARY_URL" -o "$TMPDIR/$ARTIFACT"

curl -fsL "$CHECKSUM_URL" -o "$TMPDIR/$ARTIFACT.sha256" 2> /dev/null ||
    printf "Warning: No checksum file found, skipping verification.\n"

if [ -f "$TMPDIR/$ARTIFACT.sha256" ]; then
    printf "==> Verifying checksum...\n"
    (cd "$TMPDIR" && sha256sum -c "$ARTIFACT.sha256")
fi

chmod +x "$TMPDIR/$ARTIFACT"
"$TMPDIR/$ARTIFACT"
