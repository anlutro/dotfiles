#!/bin/sh

# psm -- python script manager
# replacement for pipsi.

VENV_DIR=~/.local/share/psm
PYTHON=$(
	find /usr/local/bin /usr/bin -regex .*/python[3-9]\.[0-9]+ -printf '%f\n' \
	| sort -n | tail -1
)
PYTHON_VER=$($PYTHON --version 2>&1 | cut -d' ' -f2)

_psm_list_scripts() {
	venv=~/.local/share/psm/$1
	$venv/bin/python -c "
from pkg_resources import get_distribution
from os.path import abspath, basename, join
dist = get_distribution('$1')
scripts = dist.get_entry_map().get('console_scripts', {}).values()
for script in scripts:
	print(script.name)
if dist.has_metadata('installed-files.txt'):
	for line in dist.get_metadata_lines('installed-files.txt'):
		path = abspath(join(dist.egg_info, line.split(',')[0]))
		if path.startswith('$venv/bin/'):
			print(basename(path))
"
}

_psm_install() {
	for pkg in "$@"; do
		echo "Creating virtual environment for $pkg ..."
		$PYTHON -m venv $VENV_DIR/$pkg
	done
	_psm_upgrade "$@"
}

_psm_upgrade() {
	for pkg in "$@"; do
		venv=$VENV_DIR/$pkg
		venv_pyver=$($venv/bin/python --version 2>&1 | cut -d' ' -f2)
		if [ $venv_pyver != $PYTHON_VER ]; then
			echo "Recreating venv with new python for $pkg ..."
			$PYTHON -m venv --clear $VENV_DIR/$pkg
		fi
		echo "Installing pip and setuptools for $pkg ..."
		$venv/bin/pip install -q -U pip setuptools
		echo "Installing package: $pkg ..."
		$venv/bin/pip install -q -U $pkg
		echo "Creating script symlinks for $pkg ..."
		_psm_list_scripts $pkg | xargs -r -n1 -I% ln -sf $venv/bin/% ~/.local/bin/
	done
}

_psm_upgrade_all() {
	pkgs=$(
		find ~/.local/share/psm -mindepth 1 -maxdepth 1 -type d -print0 \
		| xargs -r -0 -n1 basename
	)
	_psm_upgrade $pkgs
}

_psm_uninstall() {
	for pkg in "$@"; do
		echo "Uninstalling package: $pkg ..."
		_psm_list_scripts $pkg | xargs -r -n1 -I% rm -f ~/.local/bin/%
		rm -rf ~/.local/share/psm/$pkg
	done
}

_psm_help() {
	echo "psm - python script manager"
	echo
	echo "psm install pkg [pkg ...]"
	echo "psm uninstall pkg [pkg ...]"
	echo "psm upgrade pkg [pkg ...]"
	echo "psm upgrade-all"
}

psm() {
	cmd="$(echo "$1" | tr -s - _)" && shift

	if [ -z "$cmd" ] || [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
		func=_psm_help
	else
		func="_psm_$cmd"
	fi

	if ! type $func >/dev/null 2>&1; then
		echo "Unknown command $1"
		exit 1
	fi

	eval $func "$@"
}

psm "$@"
