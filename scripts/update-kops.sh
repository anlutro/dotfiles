#!/bin/sh

version=$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)

if kops version | grep -qF "Version $version "; then
	echo "Latest version ($version) already installed!"
	exit 1
fi

cd ~/downloads || exit 1
wget https://github.com/kubernetes/kops/releases/download/$version/kops-linux-amd64
cp kops-linux-amd64 /usr/local/bin/kops
chmod 755 /usr/local/bin/kops
