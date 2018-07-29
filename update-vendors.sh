#!/usr/bin/env sh

root=$(dirname "$(readlink -f "$0")")
cd $root/vendor || exit 1

update_fzf() {
	./install --bin
}

for dir in *; do
	if [ -d $dir ]; then
		echo "Updating $dir ..."
		cd $dir || exit 1
		git checkout .
		git pull
		if type "update_$dir" > /dev/null; then
			eval "update_$dir"
		fi
		cd ..
		echo
	fi
done
