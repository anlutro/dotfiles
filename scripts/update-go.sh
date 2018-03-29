#!/bin/sh
set -eu

URL=$(
	curl -s 'https://golang.org/dl/' | grep -F 'href=' \
	| grep -oP 'https?://[^"]+linux-amd64\.tar\.gz' | head -1
)
FILENAME=$(basename $URL)
VERSION=$(echo $FILENAME | grep -oP '\d+\.\d+\.\d+')
PREFIX=/opt/go-${VERSION}

if [ ! -d $PREFIX ]; then
	cd ~/downloads
	wget $URL
	mkdir /tmp/go-${VERSION}
	tar -C /tmp/go-${VERSION} $FILENAME
	sudo mv /tmp/go-${VERSION} $PREFIX
	sudo chown -R root:staff $PREFIX
fi

if ! command go version | grep -qF $VERSION >/dev/null 2>&1; then
	ln -sf $PREFIX/go/bin/go* /usr/local/bin
else
	echo "Go already at the latest version ($VERSION)"
fi
