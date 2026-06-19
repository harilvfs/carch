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
    curl -fsL "https://api.github.com/repos/$REPO/releases/latest" 2> /dev/null |
        grep '"tag_name"' | head -1 | cut -d'"' -f4
}

VERSION="${CARCH_VERSION:-latest}"
TARGET=$(detect_target)
if [ "$VERSION" = "latest" ]; then
    VERSION=$(get_latest_version)
fi

if [ -z "$VERSION" ]; then
    printf "Error: could not determine a release version.\n" >&2
    exit 1
fi

GITHUB="https://github.com/$REPO/releases/download"
ARCHIVE="carch-${TARGET}.tar.gz"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

printf "Platform: %s\n" "$TARGET"
printf "Version:  %s\n" "$VERSION"
printf "Downloading %s... " "$ARCHIVE"
if curl -fsSL "$GITHUB/$VERSION/$ARCHIVE" -o "$TMPDIR/$ARCHIVE"; then
    printf "done\n"
else
    printf "failed\n"
    exit 1
fi

printf "Downloading checksum... "
if curl -fsSL "$GITHUB/$VERSION/$ARCHIVE.sha256" -o "$TMPDIR/$ARCHIVE.sha256"; then
    printf "done\n"
else
    printf "failed\n"
    exit 1
fi

printf "Verifying checksum... "
cd "$TMPDIR"
sha256sum -c "$ARCHIVE.sha256"

tar xzf "$ARCHIVE"
RELEASE_DIR=$(basename "$ARCHIVE" .tar.gz)
cd "$RELEASE_DIR"

if [ "$IS_ANDROID" = "true" ]; then
    printf "Installing to Termux prefix... "
    if install -Dm755 "$BINARY" "$PREFIX/bin/$BINARY"; then
        printf "done\n"
    else
        printf "failed\n"
        exit 1
    fi
else
    printf "Installing to /usr/local/bin... "
    if sudo install -Dm755 "$BINARY" "/usr/local/bin/$BINARY"; then
        printf "done\n"
    else
        printf "failed\n"
        exit 1
    fi
fi

if [ -d "completions" ]; then
    printf "Installing shell completions... "
    if [ "$IS_ANDROID" = "true" ]; then
        mkdir -p "$PREFIX/share/bash-completion/completions"
        mkdir -p "$PREFIX/share/zsh/site-functions"
        mkdir -p "$PREFIX/share/fish/vendor_completions.d"
        [ -f "completions/carch.bash" ] && install -Dm644 "completions/carch.bash" "$PREFIX/share/bash-completion/completions/carch"
        [ -f "completions/carch.zsh" ] && install -Dm644 "completions/carch.zsh" "$PREFIX/share/zsh/site-functions/_carch"
        [ -f "completions/carch.fish" ] && install -Dm644 "completions/carch.fish" "$PREFIX/share/fish/vendor_completions.d/carch.fish"
    else
        sudo mkdir -p /usr/share/bash-completion/completions
        sudo mkdir -p /usr/share/zsh/site-functions
        sudo mkdir -p /usr/share/fish/vendor_completions.d
        [ -f "completions/carch.bash" ] && sudo install -Dm644 "completions/carch.bash" /usr/share/bash-completion/completions/carch
        [ -f "completions/carch.zsh" ] && sudo install -Dm644 "completions/carch.zsh" /usr/share/zsh/site-functions/_carch
        [ -f "completions/carch.fish" ] && sudo install -Dm644 "completions/carch.fish" /usr/share/fish/vendor_completions.d/carch.fish
    fi
    printf "done\n"
fi

if [ -f "man/carch.1" ]; then
    printf "Installing man page... "
    if [ "$IS_ANDROID" = "true" ]; then
        if install -Dm644 "man/carch.1" "$PREFIX/share/man/man1/carch.1"; then
            printf "done\n"
        else
            printf "failed\n"
            exit 1
        fi
    else
        if sudo install -Dm644 "man/carch.1" "/usr/share/man/man1/carch.1"; then
            printf "done\n"
        else
            printf "failed\n"
            exit 1
        fi
    fi
    mandb -q 2> /dev/null || true
fi

if [ "$IS_ANDROID" = "false" ] && [ -f "carch.desktop" ]; then
    printf "Installing desktop entry... "
    if sudo install -Dm644 "carch.desktop" "/usr/share/applications/carch.desktop"; then
        printf "done\n"
    else
        printf "failed\n"
        exit 1
    fi
fi

printf "Carch %s installed successfully!\n" "$VERSION"
printf "Run carch to get started.\n"
