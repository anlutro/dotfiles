#!/bin/sh

version=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)

if kubectl version --client --short | grep -q $version$; then
    echo "Latest version ($version) already installed!"
    exit 1
fi

if [ -w /usr/local ]; then
    DIR=/usr/local/bin
else
    DIR="$HOME/bin"
fi

cd ~/downloads || exit 1
wget https://storage.googleapis.com/kubernetes-release/release/$version/bin/linux/amd64/kubectl
cp kubectl $DIR/
chmod 755 $DIR/kubectl
