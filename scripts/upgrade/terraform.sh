#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(readlink -f "$0")")/_lib.sh"

url=$(curl -sSL https://www.terraform.io/downloads.html | grep -oP 'https://[A-z0-9/_.-]*_linux_amd64\.zip')
version=$(echo $url | sed -r 's/.*terraform_([0-9.]+)_linux_amd64.*/\1/')

if terraform --version | grep -qxF "Terraform v$version"; then
	latest_already_installed
fi

filename=$(download $url)
unzip $filename
install_bin ./terraform
rm -f $filename
