#!/bin/sh
set -e

REPO="harilvfs/carch"
BINARY="carch"

if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
    IS_ANDROID=true
else
    IS_ANDROID=false
fi

if [ "$IS_ANDROID" = "true" ] && [ -z "$PREFIX" ]; then
    PREFIX="/data/data/com.termux/files/usr"
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

get_latest_version() {
    tag=$(curl -fsL "https://api.github.com/repos/$REPO/releases/latest" 2> /dev/null |
        grep '"tag_name"' | head -1 | cut -d'"' -f4)
    case "$tag" in
        v[0-9]*) echo "$tag" ;;
        *) echo "" ;;
    esac
}

VERSION="${CARCH_VERSION:-latest}"
TARGET=$(detect_target)

if [ "$VERSION" = "latest" ]; then
    VERSION=$(get_latest_version)
fi

if [ -z "$VERSION" ]; then
    echo "Error: could not determine a release version." >&2
    exit 1
fi

echo "$BINARY $VERSION ($TARGET)"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

ASSET="$BINARY-$TARGET"
curl -fsSL "https://github.com/$REPO/releases/download/$VERSION/$ASSET" -o "$TMPDIR/$ASSET"
curl -fsSL "https://github.com/$REPO/releases/download/$VERSION/$ASSET.sha256" -o "$TMPDIR/$ASSET.sha256"

cd "$TMPDIR"
sha256sum -c "$ASSET.sha256"
chmod 755 "$ASSET"

if [ "$IS_ANDROID" = "true" ]; then
    install -Dm755 "$ASSET" "$PREFIX/bin/$BINARY"
else
    sudo mkdir -p /usr/local/bin
    sudo install -m755 "$ASSET" "/usr/local/bin/$BINARY"
    mandb -q 2> /dev/null || true
fi

echo "$BINARY installed successfully"
echo "Run 'carch setup' to install shell completions, man page, and desktop file."
