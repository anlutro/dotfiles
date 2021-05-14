#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(readlink -f "$0")")/_lib.sh"

versions=$(gh_tags python/cpython | sed -r 's/^v//g' | grep -xP "\d+\.\d+\.\d+" | sort -V)
if [ $# -gt 0 ]; then
    versions=$(echo "$versions" | grep "^$1")
    if [ -z "$versions" ]; then
        fail "No versions found matching pattern: $1"
    fi
fi
version=$(echo "$versions" | tail -1)
prefix=$(get_prefix python-$version)

if [ -e "$prefix" ]; then
    confirm "$prefix exists, install anyway?" || exit 0
fi

header_files="
bzlib.h
ffi.h
ncurses.h
openssl/ssl.h
readline/readline.h
sqlite3.h
zlib.h
"
for f in $header_files; do
	if [ ! -e /usr/include/$f ] && [ ! -e /usr/include/x86_64-linux-gnu/$f ]; then
        echo "warning: missing $f"
        header_missing=true
    fi
done
if [ "${header_missing-}" = 'true' ]; then
	confirm "continue anyway?" || exit 0
fi

name="Python-$version"
dir=$(echo $version | grep -oP '^\d[\d\.]+')
url="https://www.python.org/ftp/python/$dir/$name.tar.xz"

builddir=$(mktemp -d)
filename=$(download $url)
tar xf $filename -C $builddir
cd $builddir/$name

./configure --prefix=$prefix --enable-loadable-sqlite-extensions

make

make install

ln -sf $prefix/bin/python?.? $BIN_DIR/python$version

# won't match alpha/beta/rc
if echo $version | grep -qxP '\d[\d\.]+'; then
    ln -sf $prefix/bin/python?.? $BIN_DIR/
fi

rm -rf ${builddir:?}/$name
