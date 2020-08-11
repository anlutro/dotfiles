#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(readlink -f "$0")")/_lib.sh"

if [ $# -lt 1 ]; then
    fail "Must provide version!"
fi

check_apt_pkg 'libsqlite.*-dev'
check_apt_pkg 'libreadline.*-dev'
check_apt_pkg 'libssl.*-dev'
check_apt_pkg 'zlib.*-dev'
check_apt_pkg 'libncurses.*-dev'
check_apt_pkg 'libbz2.*-dev'
check_apt_pkg 'libffi.*-dev'

version="$1"
name="Python-$version"
dir=$(echo $version | grep -oP '^\d[\d\.]+')
url="https://www.python.org/ftp/python/$dir/$name.tar.xz"

prefix=$(get_prefix python-$version)
filename=$(download $url)
tar xf $filename
cd $name

./configure --prefix=$prefix --enable-loadable-sqlite-extensions

make

make install

ln -sf $prefix/bin/python?.? $BIN_DIR/python$version

# won't match alpha/beta/rc
if echo $version | grep -qxP '\d[\d\.]+'; then
    ln -sf $prefix/bin/python?.? $BIN_DIR/
fi
