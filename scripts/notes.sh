#!/bin/sh

if [ -z "$NOTES_DIR" ]; then
	NOTES_DIR=~/Dropbox/notes
fi

main() {
	if [ $# -lt 1 ]; then
		echo "Usage: notes.sh [OPTIONS] <name>"
		echo "Available options:"
		echo "    -n --new (default)"
		echo "    -l --ls --list"
		echo "    -s --search"
		echo "    -r --rm --remove -d --delete"
		exit 0
	fi

	func="new"
	name=""

	for arg in "$@"; do
		case $arg in
			-n|--new )
				func="new"
				;;
			-l|--ls|--list )
				func="list"
				;;
			-s|--search )
				func="search"
				;;
			-r|--rm|--remove|-d|--delete )
				func="delete"
				;;
			-* )
				echo "Unknown option $arg"
				exit 1
				;;
			* )
				break;;
		esac
		shift
	done

	eval note_$func $@
}

note_new() {
	name="$1"

	if [ ! -f "$NOTES_DIR/$name.md" ]; then
		if command -v fzf >/dev/null 2>&1; then
			match=$(
				find $NOTES_DIR -name '*.md' | sed -e "s|$NOTES_DIR/||" -e 's/\.md$//' \
				| fzf --query "$*" --print-query --select-1
			)
			if [ -n "$match" ]; then
				name="$(echo "$match" | tail -1)"
			fi
		else
			match=$(note_list "$@")
			count=$(echo "$match" | wc -w)
			if [ $count -gt 1 ]; then
				note_list "$name"
				return
			elif [ $count -eq 1 ]; then
				name="$match"
			fi
		fi
	fi

	eval $EDITOR "$NOTES_DIR/$name.md"
}

note_delete() {
	name="$1"
	count=$(note_list $name | wc -w)
	if [ $count -gt 1 ]; then
		note_list $name
	elif [ $count -eq 0 ]; then
		rm "$NOTES_DIR/$name.md"
	else
		rm "$NOTES_DIR/$(note_list $name)"
	fi
}

note_list() {
	cd $NOTES_DIR || exit 1
	if [ $# = 0 ]; then
		ls -- *.md
	else
		files=$(find -name '*.md' -print0 | xargs -0 -r -n1 basename | grep -- "$*")
		if [ -n "$files" ]; then
			ls $files
		fi
	fi
}

note_search() {
	if command -v ag >/dev/null 2>&1; then
		ag "$*" $NOTES_DIR
	else
		grep -r "$*" $NOTES_DIR
	fi
}

main "$@"
