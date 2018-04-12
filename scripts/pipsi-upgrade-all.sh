#!/bin/sh
if [ -z "$PIPSI_HOME" ] || [ ! -d "$PIPSI_HOME" ]; then
	echo "PIPSI_HOME not set or does not exist!"
	exit 1
fi

echo "Upgrading pip ..."
find "$PIPSI_HOME" -mindepth 1 -maxdepth 1 -type d \
	-exec {}/bin/pip install -qU pip \;

echo "Upgrading packages ..."
pipsi list | grep 'Package ' | cut -d\" -f2 | xargs -n1 pipsi upgrade
