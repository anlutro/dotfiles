#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(readlink -f "$0")")/_lib.sh"

version="${1-$(gh_latest_tag gruntwork-io/terragrunt)}"

if terragrunt --version | grep -qF "version $version"; then
	latest_already_installed
fi

filename=$(download https://github.com/gruntwork-io/terragrunt/releases/download/$version/terragrunt_linux_amd64)
install_bin $filename terragrunt
