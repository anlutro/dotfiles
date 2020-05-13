#!/bin/sh
set -eu

version=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)

if kubectl version --client --short | grep -q $version$; then
    echo "Latest version ($version) already installed!"
    exit 1
fi

cd ~/downloads || exit 1
wget -nc https://storage.googleapis.com/kubernetes-release/release/$version/bin/linux/amd64/kubectl
mv -f kubectl $HOME/.local/bin/
chmod 755 $HOME/.local/bin/kubectl
