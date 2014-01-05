#!/bin/bash

BASEDIR=$(dirname $0)

for file in $BASEDIR/.*; do
	if [ -f $file ]; then
		FN=$(basename $file)
		echo "ln -s $BASEDIR/$FN ~/$FN"
		ln -s $BASEDIR/$FN ~/$FN
	fi
done