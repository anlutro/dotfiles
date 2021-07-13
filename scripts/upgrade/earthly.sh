#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(readlink -f "$0")")/_lib.sh"

version=$(gh_releases earthly/earthly | head -1)

if earthly --version | grep -qF "$version"; then
	latest_already_installed
fi

filename=$(download https://github.com/earthly/earthly/releases/download/$version/earthly-linux-amd64)
install_bin $filename earthly
