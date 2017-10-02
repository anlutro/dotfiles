#!/bin/sh

url=$(curl -s https://api.github.com/repos/keepassxreboot/keepassxc/releases | grep browser_download_url | grep \.AppImage | head -1 | cut -d\" -f4)
file=$(basename $url)
version=$(echo $file | grep -oP '[\d.]{3,}')

if command -v keepassxc 2>&1 >/dev/null; then
	installed_version=$(keepassxc --version | grep -oP '[\d.]{3,}')
fi

if [ "$installed_version" = "$version" ]; then
	echo "Latest version ($version) already installed!"
	exit
fi

cd ~/downloads
wget $url
chmod +x $file
mv $file /usr/local/bin/keepassxc
