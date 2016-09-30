#!/bin/sh

LIBSASS_PATH=${1:-libsass}
SASSC_PATH="${LIBSASS_PATH}/sassc"

if [ ! -d $LIBSASS_PATH ]; then
	echo "[ERROR] Directory not found: $LIBSASS_PATH"
	echo "git clone https://github.com/sass/libsass $LIBSASS_PATH"
	exit 1
elif [ ! -d $LIBSASS_PATH/.git ]; then
	echo "[ERROR] Not a git repository: $LIBSASS_PATH"
	echo "rm -rf $LIBSASS_PATH && git clone https://github.com/sass/libsass $LIBSASS_PATH"
	exit 1
elif [ ! -d $SASSC_PATH ]; then
	echo "[ERROR] Directory not found: $SASSC_PATH"
	echo "git clone https://github.com/sass/sassc $SASSC_PATH"
	exit 1
elif [ ! -d $SASSC_PATH/.git ]; then
	echo "[ERROR] Not a git repository: $SASSC_PATH"
	echo "rm -rf $SASSC_PATH && git clone https://github.com/sass/sassc $SASSC_PATH"
	exit 1
fi

cd $LIBSASS_PATH || exit 1
git pull
cd sassc || exit 1
git pull
cd ..
make sassc || make sassc || exit 1
cp sassc/bin/sassc ~/bin/sassc
