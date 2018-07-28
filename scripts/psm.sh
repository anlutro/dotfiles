#!/bin/sh

# psm -- python script manager
# replacement for pipsi.

_get_scripts() {
	$venv/bin/python -c "
import pkg_resources
for s in pkg_resources.iter_entry_points('console_scripts', '$1'):
	print(s.name)
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
		_get_scripts $pkg | xargs -r -n1 -I% ln -sf $venv/bin/% ~/.local/bin/
	done
}

_psm_upgrade_all() {
	pkgs=$(find ~/.local/share/psm -mindepth 1 -maxdepth 1 -type d | xargs -n1 basename)
	_psm_upgrade $pkgs
}

_psm_uninstall() {
	for pkg in $@; do
		echo "Uninstalling package: $pkg ..."
		_get_scripts $pkg | xargs -r -n1 -I% rm -f ~/.local/bin/%
		rm -rf ~/.local/share/psm/$pkg
	done
}

psm() {
	func="$1" && shift
	eval _psm_$func $@
}

psm $@
