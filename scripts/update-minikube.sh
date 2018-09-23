#!/bin/sh

version=$(curl -s https://api.github.com/repos/kubernetes/minikube/releases/latest | grep tag_name | cut -d '"' -f 4)

if minikube version | grep -qF "version: $version"; then
	echo "Latest version ($version) already installed!"
	exit 1
fi

if [ -w /usr/local ]; then
	DIR=/usr/local/bin
else
	DIR="$HOME/bin"
fi

cd ~/downloads || exit 1
wget https://github.com/kubernetes/minikube/releases/download/$version/minikube-linux-amd64
cp minikube-linux-amd64 $DIR/minikube
chmod 755 $DIR/minikube
