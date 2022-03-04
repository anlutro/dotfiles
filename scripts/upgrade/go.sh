#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(realpath "$0")")/_lib.sh"

if [ $# -gt 0 ]; then
    version="$1"
    url="https://dl.google.com/go/go${version}.linux-amd64.tar.gz"
    filename=$(basename $url)
else
    path=$(
        curl -s 'https://golang.org/dl/' | grep -F 'href=' \
        | grep -oP '\/dl\/[^"]+linux-amd64\.tar\.gz' | head -1
    )
    url="https://golang.org${path}"
    filename=$(basename $path)
    version=$(echo $filename | grep -oP '\d+(\.\d+)+')
fi

# `go version` can print to stderr or stdout
# append a space to prevent 1.11beta2 from matching 1.11
if command go version | grep -qF "$version " >/dev/null 2>&1; then
    latest_already_installed
fi

filename=$(download $url)
prefix=$(get_prefix go-$version)
mkdir -p $prefix
tar xf $filename -C $prefix --strip-components=1
ln -sf $prefix/bin/go* $BIN_DIR/
