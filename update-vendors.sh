#!/bin/sh

root=$(dirname $(readlink -f "$0"))
cd $root/vendor

update_fzf() {
	./install --bin
}

for dir in *; do
	if [ -d $dir ]; then
		echo "Updating $dir ..."
		cd $dir
		git checkout .
		git pull
		if type "update_$dir" > /dev/null; then
			eval "update_$dir"
		fi
		cd ..
		echo
	fi
done
