#!/bin/sh

if [ -z "$JOURNAL_FILE" ]; then
	JOURNAL_FILE=~/Dropbox/diary
fi

tmpfile=/tmp/journal

vim -c 'setlocal tw=79' $tmpfile

if [ -e $tmpfile ] && [ -s $tmpfile ]; then
	if [ -e $JOURNAL_FILE ] && [ -s $JOURNAL_FILE ]; then
		echo "\n" >> $JOURNAL_FILE
	fi
	echo "=====  $(date)  =====" >> $JOURNAL_FILE
	cat $tmpfile >> $JOURNAL_FILE
	echo "Appended entry to $JOURNAL_FILE"
else
	echo "Entry file empty, not doing anything"
fi

rm -f $tmpfile
