#!/bin/sh
set -eu

rel=$(lsb_release -s -i)
if [ $rel = 'Debian' ] || [ $rel = 'Ubuntu' ]; then
	url=$(curl -sSL https://www.sublimetext.com/3dev | grep -oP 'https://[A-z0-9/_.-]*_amd64\.deb')
	version=$(echo $url | sed -r 's/.*build-([0-9]+)_amd64.*/\1/')
else
	url=$(curl -sSL https://www.sublimetext.com/3dev | grep -oP 'https://[A-z0-9/_.-]*_x64\.tar\.bz2')
	version=$(echo $url | sed -r 's/.*build_([0-9]+)_x64.*/\1/')
fi

filename=$(basename $url)

if [ -z "$url" ]; then
	echo 'Could not find appropriate download link!'
	exit 1
fi

if [ $rel = 'Debian' ] || [ $rel = 'Ubuntu' ]; then
	installed_version=$(dpkg -s sublime-text | grep "Version:" | cut -d' ' -f2)
else
	installed_version=$(grep -oE 'Build [0-9]+' /opt/sublime_text_3/changelog.txt | head -1 | cut -d' ' -f2)
fi

if [ $installed_version -ge $version ]; then
	echo "Latest version ($version) already installed!"
	exit 0
fi

cd ~/Downloads
wget $url

if [ $rel = 'Debian' ] || [ $rel = 'Ubuntu' ]; then
	sudo dpkg -i $filename
else
	tar xf $filename
	sudo mv -f sublime_text_3 /opt
	sudo ln -sf /opt/sublime_text_3/sublime_text /usr/local/bin/subl
fi
