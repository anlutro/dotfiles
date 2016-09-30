#!/bin/sh
set -eu

url=$(curl -sSL https://www.sublimetext.com/3dev | grep -o 'https://.*_amd64\.deb')
version=$(echo $url | sed -r 's/.*build-([0-9]+)_amd64.*/\1/')
filename=$(echo $url | rev | cut -d/ -f 1 | rev)

if [ -z "$url" ]; then
	echo 'Could not find amd64.deb!'
	exit 1
fi

if dpkg -s sublime-text | grep "Version: $version" > /dev/null; then
	echo "Latest version ($version) already installed!"
	exit 0
fi

cd ~/Downloads
wget $url
sudo dpkg -i $filename
