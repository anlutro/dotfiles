#!/bin/sh

version=$(curl -s https://api.github.com/repos/kubernetes/minikube/releases/latest | grep tag_name | cut -d '"' -f 4)

if minikube version | grep -qF "version: $version"; then
    echo "Latest version ($version) already installed!"
    exit 1
fi

cd ~/downloads || exit 1
wget https://github.com/kubernetes/minikube/releases/download/$version/minikube-linux-amd64
cp minikube-linux-amd64 $HOME/.local/bin/minikube
chmod 755 $HOME/.local/bin/minikube
