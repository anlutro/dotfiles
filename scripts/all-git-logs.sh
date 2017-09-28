#!/bin/bash
# collect git logs from all subdirectories in $PWD
# ./my-git-log.sh --since=2017-09-24 | sort

root=$(pwd)
for d in $root/*/; do
	if [ ! -d $d ] || [ ! -d $d/.git ]; then
		continue
	fi
	cd $d
	repo=$(basename $d)
	git log --all --author='[aA]ndreas' --pretty=tformat:"%C(green)%ai%C(reset) %C(yellow)[$repo]%C(reset) %s" "$@"
done
