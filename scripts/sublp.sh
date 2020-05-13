#!/bin/sh
set -eu

if ! command -v subl >/dev/null 2>&1; then
    echo "Sublime Text (subl) not installed!"
    exit 1
fi

dir=$(readlink -f "${1-$PWD}")
cd $dir || exit 1

# find the sublime-project file
sp=$(find "$dir" -maxdepth 1 -name '*.sublime-project')
if [ -z "$sp" ]; then
    echo "No sublime-project found, running init-project ..."
    init-project --noninteractive --allow-no-type
    sp=$(find "$dir" -maxdepth 1 -name '*.sublime-project')
fi
if [ -z "$sp" ]; then
    sp="$dir"
fi

# rename i3 workspace
if command -v i3-rename-workspace >/dev/null 2>&1; then
	i3-rename-workspace --dir $dir
fi

# open sublime text
subl -n "$sp"
