#!/bin/sh

url=$(curl -sSL https://www.terraform.io/downloads.html | grep -oP 'https://[A-z0-9/_.-]*_linux_amd64\.zip')
file=$(basename $url)
version=$(echo $url | sed -r 's/.*terraform_([0-9.]+)_linux_amd64.*/\1/')

if command -v terraform 2>&1 >/dev/null; then
	installed_version=$(terraform --version | grep -oP '[\d.]+')
fi

if [ "$version" = "$installed_version" ]; then
	echo "Latest version ($version) already installed!"
	exit
fi

cd ~/downloads
wget $url && unzip $file && mv ./terraform ~/bin
rm -f $file
