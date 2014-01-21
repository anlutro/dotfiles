#!/bin/bash

BASEDIR=$(dirname $0)

for file in $BASEDIR/.*; do
	if [ -f $file ]; then
		filename=$(basename $file)
		srcpath=$(readlink -m $file)
		trgpath=~/$filename
		echo Linking $filename ...

		if [ -f $trgpath ]; then
			rm $trgpath
		fi

		ln -s $srcpath $trgpath
	fi
done

for file in $BASEDIR/bin/*; do
	if [ -f $file ]; then
		filename=$(basename $file)
		srcpath=$(readlink -m $file)
		trgpath=~/bin/$filename
		echo Linking $filename ...

		if [ -f $trgpath ]; then
			rm $trgpath
		fi

		ln -s $srcpath $trgpath
	fi
done
