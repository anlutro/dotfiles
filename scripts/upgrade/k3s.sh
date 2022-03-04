#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(realpath "$0")")/_lib.sh"

version=$(gh_tags rancher/k3s | head -1)

if k3s --version | grep -qF "$version"; then
	latest_already_installed
fi

filename=$(download https://github.com/rancher/k3s/releases/download/$version/k3s)
install_bin $filename
