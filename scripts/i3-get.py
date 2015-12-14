#!/usr/bin/env python3

# TODO: only toggle between applications in current workspace

import json
import sys
import subprocess


def find_windows(tree_dict, window_list):
	if 'nodes' in tree_dict and len(tree_dict['nodes']) > 0:
		for node in tree_dict['nodes']:
			find_windows(node, window_list)
	else:
		if (tree_dict['layout'] != 'dockarea' and
				not tree_dict['name'].startswith('i3bar for output') and
				not tree_dict['window'] == None):
			window_list.append(tree_dict)

	return window_list        


def get_window(next=None, prev=None):
	if next == prev:
		raise Exception('next and prev cannot be same value')

	p = subprocess.Popen(
		'i3-msg -t get_tree',
		shell=True,
		stdout=subprocess.PIPE,
		stderr=subprocess.STDOUT
	)
	tree = json.loads(p.stdout.read().decode())
	window_list = find_windows(tree, [])

	if next is True:
		next_index = -1
		for i in range(len(window_list)):
			if window_list[i]['focused'] == True:
				next_index = i + 1
				break
	elif prev is True:
		next_index = len(window_list)
		for i in range(len(window_list)-1, -1, -1):
			if window_list[i]['focused'] == True:
				next_index = i - 1
				break
	else:
		raise Exception('either next or prev must be True')

	next_id = 0
	if next_index == -1 or next_index == len(window_list):
		next_id = window_list[0]['window']
	else:
		next_id = window_list[next_index]['window']
	return next_id


def print_help():
	print('Usage: i3-switch (next|prev)'.format(sys.argv[0]))


def main():
	if len(sys.argv) < 2:
		print_help()
		sys.exit(1)

	if sys.argv[1] == 'next':
		print(get_window(next=True))
	elif sys.argv[1] == 'prev':
		print(get_window(prev=True))
	else:
		print_help()
		sys.exit(1)

if __name__ == '__main__':
	main()
