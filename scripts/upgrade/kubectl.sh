#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(realpath "$0")")/_lib.sh"

if [ -n "${1-}" ]; then
    version=$1
else
    version=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
fi

if kubectl version --client --short | grep -q "$version\$"; then
	latest_already_installed
fi

filename=$(download https://storage.googleapis.com/kubernetes-release/release/$version/bin/linux/amd64/kubectl)
install_bin $filename
