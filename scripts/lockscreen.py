#!/usr/bin/env python3

from os import system
from sys import argv

system('ssh-add -D')

cmd = 'i3lock -c 000000'

if '-s' in argv or '--suspend' in argv:
	 cmd += ' && systemctl suspend'

system(cmd)
