#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(readlink -f "$0")")/_lib.sh"

# exclude alpha/beta/rc, and always get highest version number (as opposed to
# most recent release by date)
version=$(gh_tags helm/helm | grep -P '\d+\.\d+$' | sort -V | tail -1)

if helm version --template '{{.Version}}' | grep -qFx "$version"; then
	latest_already_installed
fi

filename=$(download https://get.helm.sh/helm-$version-linux-amd64.tar.gz)
tmpdir=$(mktemp -d)
tar xf $filename -C $tmpdir
install_bin $tmpdir/linux-amd64/helm
rm -rf $tmpdir
