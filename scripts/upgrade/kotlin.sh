#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(realpath "$0")")/_lib.sh"

url=$(gh_url JetBrains/kotlin | grep -F linux-x64 | head -1)
version=$(basename $url | grep -oP '\d+(\.\d+)+')

if kotlin -version | grep -qF "$version"; then
	latest_already_installed
fi

filename=$(download $url)
unzip $filename
prefix=$(get_prefix kotlin-$version)
rsync -r ./kotlinc/ $prefix
rm -rf ./kotlinc
for bin in kotlin kotlinc; do
    ln -sf $prefix/bin/$bin $BIN_DIR/bin
done
