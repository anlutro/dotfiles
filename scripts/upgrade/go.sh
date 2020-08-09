#!/bin/sh
set -eu

if [ $# -gt 0 ]; then
    VERSION="$1"
    URL="https://dl.google.com/go/go${VERSION}.linux-amd64.tar.gz"
    FILENAME=$(basename $URL)
else
    URL=$(
        curl -s 'https://golang.org/dl/' | grep -F 'href=' \
        | grep -oP 'https?://[^"]+linux-amd64\.tar\.gz' | head -1
    )
    FILENAME=$(basename $URL)
    VERSION=$(echo $FILENAME | grep -oP '\d+(\.\d+)+')
fi

# `go version` can print to stderr or stdout
# append a space to prevent 1.11beta2 from matching 1.11
if command go version | grep -F "$VERSION " >/dev/null 2>&1; then
    echo "Go already at the latest version ($VERSION)"
    exit 1
fi

if [ -w /usr/local ]; then
    PRE_PREFIX="/usr/local"
else
    PRE_PREFIX="$HOME/.local"
fi
PREFIX="$PRE_PREFIX/share/go-$VERSION"

cd ~/downloads
wget -nv $URL
mkdir -p $PREFIX
tar xf $FILENAME -C $PREFIX --strip-components=1
ln -sf $PREFIX/bin/go* $PRE_PREFIX/bin/
