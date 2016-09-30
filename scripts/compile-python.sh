#!/bin/sh
set -eu

if [ $# -lt 1 ]; then
	echo "Must provide version!"
	exit 1
fi

VERSION="$1"
NAME="Python-$VERSION"
FILE="$NAME.tar.xz"
URL="https://www.python.org/ftp/python/$VERSION/$FILE"
PREFIX="/opt/python-$VERSION"

cd ~/Downloads
wget $URL
tar xf $FILE
cd $NAME

./configure --prefix=$PREFIX
make
make test

if [ ! -d $PREFIX ]; then
	sudo mkdir $PREFIX
fi
sudo chown $USER:$USER $PREFIX

make install

sudo chown -R root:staff $PREFIX
