#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(realpath "$0")")/_lib.sh"

repo=fluxcd/flux
version=$(gh_tags $repo | head -1)

if fluxctl version | grep -qF "$version"; then
	latest_already_installed
fi

filename=fluxctl_linux_amd64
download_gh_release $repo $version $filename
install_bin $filename fluxctl
