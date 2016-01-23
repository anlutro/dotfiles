#!/bin/sh

NIM_PATH=${1:-nim}

if [ ! -d $NIM_PATH ]; then
	echo "[ERROR] Not a directory: $NIM_PATH"
	echo "Download from http://nim-lang.org/download.html and tar xf"
	exit 1
fi

cd $NIM_PATH || exit 1
./build.sh || exit 1
cp bin/nim ~/bin/nim
