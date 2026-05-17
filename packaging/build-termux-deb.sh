#!/usr/bin/env bash
set -e

PKGNAME="carch"
PKGVER="${PKGVER:-5.3.5}"
PKGVER="${PKGVER#v}"
PKGREL="1"
ARCH="${1:-aarch64}"  # aarch64 or arm
PKGDIR="${PKGNAME}_${PKGVER}-${PKGREL}_${ARCH}"

PREFIX="/data/data/com.termux/files/usr"

URL_RAW="https://raw.githubusercontent.com/harilvfs/carch/refs/tags/v${PKGVER}"
URL_RELEASE="https://github.com/harilvfs/carch/releases/download/v${PKGVER}"

case "$ARCH" in
    aarch64) BINARY="carch-aarch64-android" ;;
    arm)     BINARY="carch-armv7-android" ;;
    *)
             echo "Unknown arch: $ARCH (use aarch64 or arm)"
                                                              exit 1
                                                                     ;;
esac

echo "==> Building Termux .deb for carch ${PKGVER} [${ARCH}] (binary: ${BINARY})"

rm -rf "$PKGDIR"
rm -f "${PKGDIR}.deb"

mkdir -p "$PKGDIR${PREFIX}/bin"
mkdir -p "$PKGDIR${PREFIX}/share/man/man1"
mkdir -p "$PKGDIR${PREFIX}/share/doc/carch"
mkdir -p "$PKGDIR${PREFIX}/share/bash-completion/completions"
mkdir -p "$PKGDIR${PREFIX}/share/zsh/site-functions"
mkdir -p "$PKGDIR${PREFIX}/share/fish/vendor_completions.d"
mkdir -p "$PKGDIR/DEBIAN"

echo "==> Downloading binary..."
curl -fsSL "$URL_RELEASE/$BINARY" -o "$PKGDIR${PREFIX}/bin/carch"
chmod 0755 "$PKGDIR${PREFIX}/bin/carch"

echo "==> Downloading completions & docs..."
curl -fsSL "$URL_RAW/completions/bash/carch"      -o "$PKGDIR${PREFIX}/share/bash-completion/completions/carch"
curl -fsSL "$URL_RAW/completions/zsh/_carch"      -o "$PKGDIR${PREFIX}/share/zsh/site-functions/_carch"
curl -fsSL "$URL_RAW/completions/fish/carch.fish" -o "$PKGDIR${PREFIX}/share/fish/vendor_completions.d/carch.fish"
curl -fsSL "$URL_RAW/man/carch.1"                 -o "$PKGDIR${PREFIX}/share/man/man1/carch.1"
curl -fsSL "$URL_RAW/LICENSE"                     -o "$PKGDIR${PREFIX}/share/doc/carch/copyright"
curl -fsSL "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/.github/README.md" \
                                                  -o "$PKGDIR${PREFIX}/share/doc/carch/README.md"

INSTALLED_SIZE=$(du -sk "$PKGDIR" | cut -f1)

echo "==> Writing DEBIAN/control..."
cat > "$PKGDIR/DEBIAN/control" << CONTROL
Package: carch
Version: ${PKGVER}-${PKGREL}
Architecture: ${ARCH}
Maintainer: Hari Chalise <harilvfs@chalisehari.com.np>
Installed-Size: ${INSTALLED_SIZE}
Depends: git
Description: A Rust-based CLI tool for Linux system setup
 carch streamlines and automates your Linux system's initial setup.
 It provides an interactive menu to install packages, configure
 dotfiles, and set up your environment quickly.
Homepage: https://github.com/harilvfs/carch
Section: utils
Priority: optional
CONTROL

echo "==> Writing DEBIAN/postinst..."
cat > "$PKGDIR/DEBIAN/postinst" << 'POSTINST'
#!/bin/bash
echo ""
echo "  Carch installed successfully!"
echo ""
echo "  Run it with: carch"
echo "  Docs: https://carch.chalisehari.com.np"
echo ""
POSTINST
chmod 0755 "$PKGDIR/DEBIAN/postinst"

echo "==> Building .deb..."
dpkg-deb --build --root-owner-group "$PKGDIR"

echo ""
echo " Built: ${PKGDIR}.deb"
echo " Install in Termux with: dpkg -i ${PKGDIR}.deb"
