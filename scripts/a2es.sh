#!/bin/sh

adir='/etc/apache2/sites-available'
edir='/etc/apache2/sites-enabled'

if [ $USER != "vagrant" ]; then
	echo "ABORTED: Not running in vagrant!"
	exit 1
fi

if [ ! -f $adir/$1 ]; then
	echo "ABORTED: No such site available!"
	exit 2
fi

if [ "$(ls -A $edir)" ]; then
	sudo rm $edir/*
fi

sudo ln -s $adir/$1 $edir/$1 && sudo service apache2 reload
