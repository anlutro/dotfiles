#!/bin/sh
set -e

python=python3
while [ $# -gt 0 ]; do
	arg="$1"
	case $arg in
		-2|--two )
			python='python'
			;;
		-3|--three )
			python='python3'
			;;
	esac
	shift
done

pkgs="$python"
if [ "$python" = "python3" ]; then
	pkgs="$pkgs python3-venv"
fi
sudo apt install $pkgs

# install pip in ~/.local to avoid conflicting with system packages
curl -s https://bootstrap.pypa.io/get-pip.py | $python - --user

# prevent system pip from installing things into /usr/local if the user running
# it is part of the "staff" group
find /usr/local/lib/python* -maxdepth 1 -type d | xargs sudo chmod og-w
