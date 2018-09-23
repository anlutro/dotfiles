#!/bin/sh

url=$(curl -s https://api.github.com/repos/docker/machine/releases | grep browser_download_url \
	| grep Linux-x86_64 | grep -v -- '-rc' | head -1 | cut -d\" -f4)
file=$(basename $url)
version=$(echo $url | sed -r 's|.*/download/v([0-9.-]+)/.*|\1|')

if docker-machine --version 2>&1 | grep -qF "version $version,"; then
	echo "Latest version ($version) already installed!"
	exit 1
fi

if [ -w /usr/local ]; then
	DIR=/usr/local/bin
else
	DIR="$HOME/bin"
fi

cd ~/downloads || exit 1
wget $url
cp $file $DIR/docker-machine
chmod +x $DIR/docker-machine
