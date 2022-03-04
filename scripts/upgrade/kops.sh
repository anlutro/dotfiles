#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(realpath "$0")")/_lib.sh"

version=$(gh_tags kubernetes/kops | head -1)

if kops version | grep -qF "Version $version "; then
	latest_already_installed
fi

filename=$(download https://github.com/kubernetes/kops/releases/download/$version/kops-linux-amd64)
install_bin $filename kops
