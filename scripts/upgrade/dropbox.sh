#!/bin/sh
set -eu

rm -rf $HOME/.dropbox-dist-old-*
rm -rf /tmp/.dropbox-dist-*

echo "Checking for Dropbox updates ..." >&2
url=$(curl -ILs --http1.1 -o /dev/null -w '%{url_effective}' 'https://www.dropbox.com/download?plat=lnx.x86_64')
latest_version=$(echo "$url" | sed -r 's/.*-([0-9\.]+)\.tar\.gz/\1/')

if [ -e $HOME/.dropbox-dist ]; then
	version=$(cat $HOME/.dropbox-dist/VERSION)
	if [ "$version" = "$latest_version" ]; then
		echo "Latest version ($latest_version) already installed!" >&2
		exit 0
	fi
fi

cd $HOME/downloads
wget -nv "$url" -O "dropbox-$latest_version.tar.gz"
tar xf "dropbox-$latest_version.tar.gz" -C $HOME
rm "dropbox-$latest_version.tar.gz"
echo "Updated to version $latest_version !" >&2
