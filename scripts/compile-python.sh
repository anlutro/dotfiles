#!/bin/sh
set -eu

if [ $# -lt 1 ]; then
	echo "Must provide version!"
	exit 1
fi

warn=no
if ! dpkg -l | grep libsqlite.*-dev > /dev/null; then
	echo "warning: libsqlite not installed!"
	warn=yes
fi
if ! dpkg -l | grep libreadline.*-dev > /dev/null; then
	echo "warning: libsqlite not installed!"
	warn = yes
fi
if [ $warn = 'yes' ]; then
	exit 1
fi

VERSION="$1"
NAME="Python-$VERSION"
FILE="$NAME.tar.xz"
URL="https://www.python.org/ftp/python/$VERSION/$FILE"
PREFIX="/opt/python-$VERSION"

cd ~/downloads
if [ ! -f $FILE ]; then
	wget $URL
fi
tar xf $FILE
cd $NAME

./configure --prefix=$PREFIX \
	--enable-optimizations --enable-loadable-sqlite-extensions

make

if [ ! -d $PREFIX ]; then
	sudo mkdir $PREFIX
fi
sudo chown -R $USER:$USER $PREFIX

make install

sudo chown -R root:staff $PREFIX

sudo ln -sf $PREFIX/bin/python?.? /usr/local/bin/
