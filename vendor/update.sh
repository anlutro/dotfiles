#!/bin/sh

root=$(dirname $(readlink -f "$0"))
cd $root

for dir in *; do
	if [ -d $dir ]; then
		echo "Updating $dir ..."
		cd $dir
		git pull
		cd ..
		echo
	fi
done
