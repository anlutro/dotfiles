#!/bin/sh

cd ${1-nim} || exit 1
./build.sh
cp bin/nim ~/bin/nim
