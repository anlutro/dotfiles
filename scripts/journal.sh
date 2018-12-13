#!/bin/sh

if [ -z "$JOURNAL_FILE" ]; then
	JOURNAL_FILE=~/Dropbox/diary
fi

if [ ! -e $JOURNAL_FILE ]; then
	echo "$JOURNAL_FILE does not exist - create it!"
	exit 1
fi

tmpfile=/tmp/journal

vim -c 'setlocal tw=79' $tmpfile

if [ -e $tmpfile ] && [ -s $tmpfile ]; then
	if [ -s $JOURNAL_FILE ]; then
		printf "\n\n" >> $JOURNAL_FILE
	fi
	echo "=====  $(date)  =====" >> $JOURNAL_FILE
	cat $tmpfile >> $JOURNAL_FILE
	echo "Appended entry to $JOURNAL_FILE"
else
	echo "Entry file empty, not doing anything"
fi

rm -f $tmpfile
