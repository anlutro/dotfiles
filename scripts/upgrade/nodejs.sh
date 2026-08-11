#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(realpath "$0")")/_lib.sh"

if [ $# -gt 0 ]; then
	version="$1"
else
    version=$(curl -sSL https://nodejs.org/dist/latest/ | grep -oP 'v\d+(\.\d+)+' | uniq)
fi

if command node --version | grep -qxF "$version"; then
	latest_already_installed
fi

url=https://nodejs.org/dist/$version/node-$version-linux-x64.tar.xz
filename=$(download $url)
prefix=$(get_prefix nodejs-$version)
mkdir -p $prefix
tar xf $filename -C $prefix --strip-components=1
ln -sf $prefix/bin/node $prefix/bin/npm $prefix/bin/npx $BIN_DIR/
