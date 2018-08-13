#!/bin/sh
set -eu

if [ $# -lt 1 ]; then
	echo "Must provide version!"
	exit 1
fi

warn=no
if ! dpkg -l | grep -q 'libsqlite.*-dev'; then
	echo "warning: libsqlite not installed!"
	warn=yes
fi
if ! dpkg -l | grep -q 'libreadline.*-dev'; then
	echo "warning: libreadline not installed!"
	warn=yes
fi
if ! dpkg -l | grep -q 'libssl.*-dev'; then
	echo "warning: libssl not installed!"
	warn=yes
fi
if ! dpkg -l | grep -q 'zlib.*-dev'; then
	echo "warning: zlib not installed!"
	warn=yes
fi
if ! dpkg -l | grep -q 'libncurses.*-dev'; then
	echo "warning: libncurses not installed!"
	warn=yes
fi
if [ $warn = 'yes' ]; then
	exit 1
fi

VERSION="$1"
NAME="Python-$VERSION"
FILE="$NAME.tar.xz"
URL="https://www.python.org/ftp/python/$VERSION/$FILE"

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

ln -sf $PREFIX/bin/python?.? $PRE_PREFIX/bin/
ln -sf $PREFIX/bin/python?.? $PRE_PREFIX/bin/python$VERSION
