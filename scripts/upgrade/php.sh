#!/bin/sh
set -eu

if [ $# -lt 1 ];then
	echo "Must provide version!"
	exit 1
fi

VERSION="$1"
MINOR_VERSION=$(echo $VERSION | cut -d. -f1-2)
DIR="php-$VERSION"
FILE="$DIR.tar.xz"
if [ -w /usr/local ]; then
    PRE_PREFIX="/usr/local"
else
    PRE_PREFIX="$HOME/.local"
fi
PREFIX="$PRE_PREFIX/share/php-$VERSION"

cd ~/downloads
wget -nv https://www.php.net/distributions/$FILE
tar xf $FILE && rm $FILE
cd $DIR

./configure --prefix=$PREFIX
make
make install

# symlink the CLI SAPI only
ln -sf $PREFIX/bin/php $PRE_PREFIX/bin/php$VERSION

# won't match alpha/beta/rc
if echo $VERSION | grep -qxP '\d[\d\.]+'; then
    ln -sf $PREFIX/bin/php $PRE_PREFIX/bin/php$MINOR_VERSION
fi
