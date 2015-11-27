#!/bin/sh

root=$(dirname $(readlink -f "$0"))
cd $root/vendor

for dir in *; do
	if [ -d $dir ]; then
		echo "Updating $dir ..."
		cd $dir
		git checkout .
		git pull
		cd ..
		echo
	fi
done
