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

ARCHIVE="${BINARY}-${TARGET}.tar.gz"

curl -fsSL "https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE" -o "$TMPDIR/$ARCHIVE"
curl -fsSL "https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE.sha256" -o "$TMPDIR/$ARCHIVE.sha256"

cd "$TMPDIR"
sha256sum -c "$ARCHIVE.sha256"
tar xzf "$ARCHIVE"
cd "${BINARY}-${TARGET}"

if [ "$IS_ANDROID" = "true" ]; then
    install -Dm755 "$BINARY" "$PREFIX/bin/$BINARY"

    if [ -d "completions" ]; then
        mkdir -p "$PREFIX/share/bash-completion/completions" \
            "$PREFIX/share/zsh/site-functions" \
            "$PREFIX/share/fish/vendor_completions.d"

        [ -f "completions/$BINARY.bash" ] && cp "completions/$BINARY.bash" \
            "$PREFIX/share/bash-completion/completions/$BINARY"
        [ -f "completions/$BINARY.zsh" ] && cp "completions/$BINARY.zsh" \
            "$PREFIX/share/zsh/site-functions/_$BINARY"
        [ -f "completions/$BINARY.fish" ] && cp "completions/$BINARY.fish" \
            "$PREFIX/share/fish/vendor_completions.d/$BINARY.fish"
    fi

    if [ -f "man/$BINARY.1" ]; then
        install -Dm644 "man/$BINARY.1" "$PREFIX/share/man/man1/$BINARY.1"
    fi
else
    sudo install -Dm755 "$BINARY" "/usr/local/bin/$BINARY"

    if [ -d "completions" ]; then
        sudo mkdir -p /usr/share/bash-completion/completions \
            /usr/share/zsh/site-functions \
            /usr/share/fish/vendor_completions.d

        [ -f "completions/$BINARY.bash" ] && sudo cp "completions/$BINARY.bash" \
            /usr/share/bash-completion/completions/$BINARY
        [ -f "completions/$BINARY.zsh" ] && sudo cp "completions/$BINARY.zsh" \
            /usr/share/zsh/site-functions/_$BINARY
        [ -f "completions/$BINARY.fish" ] && sudo cp "completions/$BINARY.fish" \
            /usr/share/fish/vendor_completions.d/$BINARY.fish
    fi

    if [ -f "man/$BINARY.1" ]; then
        sudo install -Dm644 "man/$BINARY.1" /usr/share/man/man1/$BINARY.1
    fi

    if [ -f "$BINARY.desktop" ]; then
        sudo install -Dm644 "$BINARY.desktop" /usr/share/applications/$BINARY.desktop
    fi

    mandb -q 2> /dev/null || true
fi

echo "$BINARY installed successfully"
