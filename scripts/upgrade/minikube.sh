#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(readlink -f "$0")")/_lib.sh"

version=$(gh_latest_tag kubernetes/minikube)

if minikube version | grep -qF "version: $version"; then
	latest_already_installed
fi

filename=$(download https://github.com/kubernetes/minikube/releases/download/$version/minikube-linux-amd64)
install_bin $filename minikube
