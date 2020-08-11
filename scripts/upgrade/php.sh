#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(readlink -f "$0")")/_lib.sh"

if [ $# -lt 1 ];then
	fail "Must provide version!"
fi

version="$1"
minor_version=$(echo $version | cut -d. -f1-2)
dir="php-$version"
prefix=$(get_prefix php-$version)

filename=$(download https://www.php.net/distributions/$dir.tar.xz)
tar xf $filename && rm $filename
cd $dir

./configure --prefix=$prefix
make
make install

# symlink the CLI SAPI only
ln -sf $prefix/bin/php $BIN_DIR/php$version

# won't match alpha/beta/rc
if echo $version | grep -qxP '\d[\d\.]+'; then
    ln -sf $prefix/bin/php $BIN_DIR/php$minor_version
fi
