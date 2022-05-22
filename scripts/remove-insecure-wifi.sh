#!/bin/sh
grep --null --recursive --files-with-matches --fixed-strings '[wifi]' /etc/NetworkManager/system-connections/ \
	| xargs -r -0 grep --null --files-without-match --fixed-strings '[wifi-security]' \
	| xargs -r -0 -p rm
