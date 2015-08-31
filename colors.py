#!/usr/bin/env python
import sys
def write_color(color):
	sys.stdout.write("\33[%sm %s \33[m " % (color, color))
for i in range(2):
	for j in range(30, 38):
		write_color('%d;%d' % (i, j))
		for k in range(40, 48):
			write_color('%d;%d;%d' % (i, j, k))
		sys.stdout.write("\n")
