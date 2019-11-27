#!/usr/bin/env sh

root=$(dirname "$(readlink -f "$0")")
cd $root/vendor || exit 1

for dir in *; do
    if [ -d $dir ]; then
        echo "Updating $dir ..."
        cd $dir || exit 1
        git checkout .
        git pull
        cd ..
        echo
    fi
done
