#!/bin/sh
set -eu

if [ -z "${DIARY_FILE-}" ]; then
    DIARY_FILE=~/Dropbox/diary
fi

if [ ! -e "$DIARY_FILE" ]; then
    echo "$DIARY_FILE does not exist - create it!"
    exit 1
fi

tmpfile=$DIARY_FILE.draft

vim -c 'setlocal tw=79' $tmpfile

if [ -e $tmpfile ] && [ -s $tmpfile ]; then
    if [ -s "$DIARY_FILE" ]; then
        printf "\n\n" >> "$DIARY_FILE"
    fi
    echo "=====  $(date -R)  =====" >> "$DIARY_FILE"
    cat $tmpfile >> "$DIARY_FILE"
    echo "Appended entry to $DIARY_FILE"
else
    echo "Entry file empty, not doing anything"
fi

rm -f $tmpfile
