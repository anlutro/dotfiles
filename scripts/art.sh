#!/bin/sh

if [ -f ./bin/artisan ]; then
	php ./bin/artisan "$@"
elif [ -f ./artisan ]; then
	php ./artisan "$@"
else
	echo "No artisan file found!"
	return 1
fi
