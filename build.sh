#!/bin/sh
set -e

# Check and extract version number
[ $# != 1 ] && echo "Usage:  $0 <latest_releases_tag>" && exit 1
VERSION=$(echo "$1" | sed -n 's|[^0-9]*\([^_]*\).*|\1|p') && test "$VERSION"

# PACKAGE=frp
REPO=fatedier/frp

ARCH_LIST="amd64 arm64"
AMD64_FILENAME=frp_"$VERSION"_linux_amd64.tar.gz
ARM64_FILENAME=frp_"$VERSION"_linux_arm64.tar.gz

prepare() {
    mkdir -p output tmp
    curl -fs https://api.github.com/repos/$REPO/releases/latest | jq -r '.body' | gzip > tmp/changelog.gz
}

build() {
    BASE_DIR="$PACKAGE"_"$ARCH" && rm -rf "$BASE_DIR"
    # Download and move file
    DOC_DIR="$BASE_DIR/usr/share/doc/$PACKAGE" && \
    mkdir -p "$DOC_DIR" && \
    cp templates/copyright "$DOC_DIR" && \
    cp tmp/changelog.gz "$DOC_DIR"
    install -D -m 755 tmp/"$FRP_DIR/$PACKAGE" -t "$BASE_DIR/usr/bin"
    install -D -m 644 tmp/"$FRP_DIR/$PACKAGE.toml" -t "$BASE_DIR/etc/frp"

    # Debian package control
    mkdir -p "$BASE_DIR/DEBIAN"
    echo "/etc/frp/$PACKAGE.toml" > "$BASE_DIR/DEBIAN/conffiles"

    if [ "$PACKAGE" = "frps" ]; then
        install -D -m 644 "templates/frps/frps.service" -t "$BASE_DIR/usr/lib/systemd/system"
        cp templates/frps/p* "$BASE_DIR/DEBIAN"
    fi

    SIZE=$(du -sk "$BASE_DIR"/usr | cut -f1)
    echo "Package: $PACKAGE
Version: $VERSION+1
Architecture: $ARCH
Installed-Size: $SIZE
Maintainer: wcbing <i@wcbing.top>
Section: web
Priority: optional
Homepage: https://gofrp.org/
Description: A fast reverse proxy to help you expose a local server
 behind a NAT or firewall to the internet. 
" > "$BASE_DIR/DEBIAN/control"

    # Package deb
    dpkg-deb -b --root-owner-group -Z xz "$BASE_DIR" output
}

get_url_by_arch() {
    DOWNLOAD_PREFIX="https://github.com/$REPO/releases/latest/download"
    case $1 in
    "amd64") echo "$DOWNLOAD_PREFIX/$AMD64_FILENAME" ;;
    "arm64") echo "$DOWNLOAD_PREFIX/$ARM64_FILENAME" ;;
    esac
}

prepare

for ARCH in $ARCH_LIST; do
    echo "Building $ARCH package..."
    cd tmp
    curl -fsLO "$(get_url_by_arch "$ARCH")"
    FRP_DIR=frp_"$VERSION"_linux_"$ARCH"
    tar -xf "$FRP_DIR".tar.gz
    cd ..
    PACKAGE="frps"
    build
    PACKAGE="frpc"
    build
done

# Create repo files
cd output && apt-ftparchive packages . > Packages && apt-ftparchive release . > Release
