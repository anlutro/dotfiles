#!/bin/sh
set -eu

if [ -n "$1" ]; then
	VERSION="$1"
	URL="https://dl.google.com/go/go${VERSION}.linux-amd64.tar.gz"
	FILENAME=$(basename $URL)
else
	URL=$(
		curl -s 'https://golang.org/dl/' | grep -F 'href=' \
		| grep -oP 'https?://[^"]+linux-amd64\.tar\.gz' | head -1
	)
	FILENAME=$(basename $URL)
	VERSION=$(echo $FILENAME | grep -oP '\d+\.\d+\.\d+')
fi
PREFIX=/opt/go-${VERSION}

if command go version | grep -F $VERSION >/dev/null 2>&1; then
	echo "Go already at the latest version ($VERSION)"
	exit 1
fi

if [ ! -d $PREFIX ]; then
	cd ~/downloads
	wget $URL
	mkdir /tmp/go-${VERSION}
	tar xf $FILENAME -C /tmp/go-${VERSION}
	sudo mv /tmp/go-${VERSION} $PREFIX
	sudo chown -R root:staff $PREFIX
fi

ln -sf $PREFIX/go/bin/go* /usr/local/bin/
