#!/bin/sh

version=$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)

if kops version | grep -qF "Version $version "; then
	echo "Latest version ($version) already installed!"
	exit 1
fi

if [ -w /usr/local ]; then
	DIR=/usr/local/bin
else
	DIR="$HOME/bin"
fi

cd ~/downloads || exit 1
wget https://github.com/kubernetes/kops/releases/download/$version/kops-linux-amd64
cp kops-linux-amd64 $DIR/kops
chmod 755 $DIR/kops
