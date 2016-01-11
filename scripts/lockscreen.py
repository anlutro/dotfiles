#!/usr/bin/env python3

from os import system
from sys import argv

cmd = 'ssh-add -D && i3lock -c 000000'

if '-s' in argv or '--suspend' in argv:
	 cmd += ' && systemctl suspend'

system(cmd)
