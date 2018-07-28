#!/bin/sh

# psm -- python script manager
# replacement for pipsi.

_psm_list_scripts() {
	venv=~/.local/share/psm/$1
	$venv/bin/python -c "
import pkg_resources
dist = pkg_resources.get_distribution('$1')
scripts = dist.get_entry_map()['console_scripts'].values()
for script in scripts:
	print(script.name)
"
}

_psm_install() {
	for pkg in $@; do
		echo "Creating virtual environment for $pkg ..."
		venv=~/.local/share/psm/$pkg
		python3.6 -m venv $venv
	done
	_psm_upgrade $@
}

_psm_upgrade() {
	for pkg in $@; do
		echo "Installing pip and setuptools for $pkg ..."
		$venv/bin/pip install -q -U pip setuptools
		echo "Installing package: $pkg ..."
		$venv/bin/pip install -q -U $pkg
		echo "Creating script symlinks for $pkg ..."
		_psm_list_scripts $pkg | xargs -r -n1 -I% ln -sf $venv/bin/% ~/.local/bin/
	done
}

_psm_upgrade_all() {
	pkgs=$(find ~/.local/share/psm -mindepth 1 -maxdepth 1 -type d | xargs -n1 basename)
	_psm_upgrade $pkgs
}

_psm_uninstall() {
	for pkg in $@; do
		echo "Uninstalling package: $pkg ..."
		_psm_list_scripts $pkg | xargs -r -n1 -I% rm -f ~/.local/bin/%
		rm -rf ~/.local/share/psm/$pkg
	done
}

psm() {
	func="$(echo "$1" | tr -s - _)" && shift
	eval _psm_$func $@
}

psm $@
