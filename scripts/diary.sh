#!/bin/sh
set -eu

if [ -z "${DIARY_FILE-}" ]; then
    DIARY_FILE=~/Dropbox/diary.md
fi

if [ ! -e "$DIARY_FILE" ]; then
    echo "$DIARY_FILE does not exist - create it!"
    exit 1
fi

draftfile=$DIARY_FILE.draft
tmpfile=$DIARY_FILE.swap

vim $draftfile

if [ -e $draftfile ] && [ -s $draftfile ]; then
    dt=$(date -R)
    { echo "# $dt"
      cat "$draftfile"
      printf "\n\n"
      cat "$DIARY_FILE"
    } >> "$tmpfile"

    mv "$tmpfile" "$DIARY_FILE"
    echo "Prepended entry to $DIARY_FILE ($dt)"
else
    echo "Entry file empty, not doing anything"
fi

rm -f $draftfile $tmpfile
