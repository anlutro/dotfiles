#!/bin/bash

BASEDIR=$(dirname $0)

for file in $BASEDIR/.*; do
	if [ -f $file ]; then
		filename=$(basename $file)
		srcpath=$(readlink -m $file)
		trgpath=~/$filename
		echo Linking $srcpath "->" $trgpath ...
		ln -fs $srcpath $trgpath
	fi
done

for file in $BASEDIR/bin/*; do
	if [ -f $file ]; then
		filename=$(basename $file)
		srcpath=$(readlink -m $file)
		trgpath=~/bin/$filename
		echo Linking $srcpath "->" $trgpath ...
		ln -fs $srcpath $trgpath
	fi
done
