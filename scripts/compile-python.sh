#!/bin/sh
set -eu

if [ $# -lt 1 ]; then
    echo "Must provide version!"
    exit 1
fi

check_pkg() {
    pattern="$1"
    if ! dpkg -l | grep -q "$pattern"; then
        echo "warning: package matching pattern '$pattern' not found!"
        exit 1
    fi
}
check_pkg 'libsqlite.*-dev'
check_pkg 'libreadline.*-dev'
check_pkg 'libssl.*-dev'
check_pkg 'zlib.*-dev'
check_pkg 'libncurses.*-dev'
check_pkg 'libbz2.*-dev'
check_pkg 'libffi.*-dev'

VERSION="$1"
NAME="Python-$VERSION"
FILE="$NAME.tar.xz"
DIR=$(echo $VERSION | grep -oP '^\d[\d\.]+')
URL="https://www.python.org/ftp/python/$DIR/$FILE"

if [ -w /usr/local ]; then
    PRE_PREFIX="/usr/local"
else
    PRE_PREFIX="$HOME/.local"
fi
PREFIX="$PRE_PREFIX/share/python-$VERSION"

cd ~/downloads
if [ ! -f $FILE ]; then
    wget $URL
fi
tar xf $FILE
cd $NAME

./configure --prefix=$PREFIX --enable-loadable-sqlite-extensions

make

make install

ln -sf $PREFIX/bin/python?.? $PRE_PREFIX/bin/python$VERSION

# won't match alpha/beta/rc
if echo $VERSION | grep -qxP '\d[\d\.]+'; then
    ln -sf $PREFIX/bin/python?.? $PRE_PREFIX/bin/
fi
