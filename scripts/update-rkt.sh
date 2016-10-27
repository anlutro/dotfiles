#!/bin/sh

url=$(curl -s https://api.github.com/repos/coreos/rkt/releases | grep browser_download_url | grep amd64\.deb | head -1 | cut -d\" -f4)
file=$(basename $url)
version=$(echo $file | sed -r 's/.*rkt_([0-9.-]+)_amd64\.deb/\1/')

if dpkg -s rkt 2>/dev/null | grep "Version: $version" > /dev/null; then
	echo "Latest version ($version) already installed!"
	exit 0
fi

cd ~/Downloads
gpg --recv-key 18AD5014C99EF7E3BA5F6CE950BDD3E0FC8A365E
wget $url
wget $url.asc
gpg --verify $file.asc
sudo dpkg -i $file
