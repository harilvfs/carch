#!/bin/sh
set -e

REPO="harilvfs/carch"
BINARY="carch"

if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
    IS_ANDROID=true
else
    IS_ANDROID=false
fi

detect_target() {
    ARCH=$(uname -m)
    OS=$(uname -s)
    case "$OS" in
        Linux)
            if [ "$IS_ANDROID" = "true" ]; then
                case "$ARCH" in
                    aarch64 | arm64) echo "aarch64-linux-android" ;;
                    armv7* | armv8l | arm) echo "armv7-linux-androideabi" ;;
                    *)
                        echo "Unsupported architecture: $ARCH" >&2
                        exit 1
                        ;;
            esac
        else
                case "$ARCH" in
                    x86_64 | amd64) echo "x86_64-unknown-linux-musl" ;;
                    aarch64 | arm64) echo "aarch64-unknown-linux-musl" ;;
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

detect_suffix() {
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64 | amd64) echo "" ;;
        aarch64 | arm64)
            if [ "$IS_ANDROID" = "true" ]; then echo "-aarch64-android"; else echo "-aarch64"; fi
            ;;
        armv7* | armv8l | arm) echo "-armv7-android" ;;
        *)
            echo "Unsupported architecture: $ARCH" >&2
            exit 1
            ;;
    esac
}

get_latest_version() {
    curl -fsL "https://api.github.com/repos/$REPO/releases/latest" 2> /dev/null |
        grep '"tag_name"' | head -1 | cut -d'"' -f4
}

VERSION="${CARCH_VERSION:-latest}"
if [ "$VERSION" = "latest" ]; then
    VERSION=$(get_latest_version)
fi

if [ -z "$VERSION" ]; then
    echo "Error: could not determine a release version." >&2
    exit 1
fi

TARGET=$(detect_target)
SUFFIX=$(detect_suffix)
ARTIFACT="${BINARY}${SUFFIX}"

echo "$BINARY $VERSION ($TARGET)"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

curl -fsSL "https://github.com/$REPO/releases/download/$VERSION/$ARTIFACT" -o "$TMPDIR/$ARTIFACT"
curl -fsL "https://github.com/$REPO/releases/download/$VERSION/$ARTIFACT.sha256" -o "$TMPDIR/$ARTIFACT.sha256" 2> /dev/null || true

if [ -f "$TMPDIR/$ARTIFACT.sha256" ]; then
    (cd "$TMPDIR" && sha256sum -c "$ARTIFACT.sha256")
fi

chmod +x "$TMPDIR/$ARTIFACT"
"$TMPDIR/$ARTIFACT"
