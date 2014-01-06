#!/bin/bash

BASEDIR=$(dirname $0)

for file in $BASEDIR/.*; do
	if [ -f $file ]; then
		FN=$(basename $file)
		echo Linking $FN ...

		if [ -f ~/$FN ]; then
			rm ~/$FN
		fi

		ln -s $file ~/$FN
	fi
done
