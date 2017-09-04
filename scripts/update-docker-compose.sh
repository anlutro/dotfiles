#!/bin/sh

url=$(curl -s https://api.github.com/repos/docker/compose/releases | grep browser_download_url \
	| grep Linux-x86_64 | grep -v -- '-rc' | head -1 | cut -d\" -f4)
file=$(basename $url)
version=$(echo $url | sed -r 's|.*/download/([0-9.-]+)/.*|\1|')

if docker-compose --version | grep -F "version $version,"; then
	echo "Latest version ($version) already installed!"
	exit 1
fi

cd ~/downloads
wget $url
chmod +x $file
mv $file /usr/local/bin/docker-compose
