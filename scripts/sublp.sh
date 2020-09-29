#!/bin/sh
set -eu

if ! command -v subl >/dev/null 2>&1; then
    echo "Sublime Text (subl) not installed!"
    exit 1
fi

dir=$(readlink -f "${1-$PWD}")
cd $dir || exit 1

find_sublime_project_file() {
    find "$1" -maxdepth 1 -name '*.sublime-project'
}

sp="$(find_sublime_project_file "$dir")"

# if not found, try looking in parent directories, but not outside of $HOME
while [ -z "$sp" ] && echo "$dir" | grep -q "^$HOME"; do
    dir="$(dirname "$dir")"
    sp="$(find_sublime_project_file "$dir")"
done

if [ -z "$sp" ]; then
    echo "No sublime-project found, running init-project ..."
    init-project --noninteractive --allow-no-type
    dir=$(readlink -f "${1-$PWD}")
    sp="$(find_sublime_project_file "$dir")"
fi
if [ -z "$sp" ]; then
    echo "No sublime-project file found, just opening as directory"
    sp=$dir
fi

# rename i3 workspace
~/code/dotfiles/scripts/i3-rename-workspace.sh --dir "$dir"

# open sublime text
subl -n "$sp"
