#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(realpath "$0")")/_lib.sh"

version=$(gh_latest_tag koalaman/shellcheck)
version_num=$(echo "$version" | sed s/^v//)

if shellcheck --version | grep -qF "version: $version_num"; then
	latest_already_installed
fi

filename=$(download https://github.com/koalaman/shellcheck/releases/download/$version/shellcheck-$version.linux.x86_64.tar.xz)
tar xf $filename
install_bin shellcheck-$version/shellcheck
rm -rf shellcheck-$version $filename
