#!/bin/sh
set -eu

url=$(curl -sSL https://www.terraform.io/downloads.html | grep -oP 'https://[A-z0-9/_.-]*_linux_amd64\.zip')
file=$(basename $url)
version=$(echo $url | sed -r 's/.*terraform_([0-9.]+)_linux_amd64.*/\1/')

if command -v terraform >/dev/null 2>&1; then
    installed_version=$(terraform --version | grep -oP '[\d.]+')
	if [ "$version" = "$installed_version" ]; then
	    echo "Latest version ($version) already installed!"
	    exit
	fi
fi

if [ -w /usr/local ]; then
    DIR=/usr/local/bin
else
    DIR="$HOME/.local/bin"
fi

cd ~/downloads || exit 1
wget -nc $url && unzip $file && mv ./terraform $DIR/
rm -f $file
