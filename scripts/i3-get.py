#!/usr/bin/env python3
'''
Get the window ID of the next or previous window in the current workspace.

	$ i3-msg -t get_tree | i3-get.py next
	41943050
	$ i3-msg -t get_tree | i3-get.py prev
	39845898

Add --all or -a to find the next/previous window in all workspaces, not just the
active one.
'''

import json
import sys


def find_active_workspace(tree_dict, current_workspace=None):
	if tree_dict.get('focused'):
		return current_workspace
	if tree_dict.get('type') == 'workspace':
		current_workspace = tree_dict
	if 'nodes' in tree_dict and len(tree_dict['nodes']) > 0:
		for node in tree_dict['nodes']:
			workspace = find_active_workspace(node, current_workspace)
			if workspace is not None:
				return workspace


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


def get_window(next=None, prev=None, all_workspaces=False):
	if next == prev:
		raise Exception('next and prev cannot be same value')

	tree = json.load(sys.stdin)
	if not all_workspaces:
		tree = find_active_workspace(tree)
	window_list = find_windows(tree, [])

	window_count = len(window_list)
	if window_count == 0:
		return ''
	if window_count == 1:
		return window_list[0]['window']

	if next is True:
		next_index = -1
		for i in range(window_count):
			if window_list[i]['focused'] == True:
				next_index = i + 1
				break
	elif prev is True:
		next_index = window_count
		for i in range(window_count - 1, -1, -1):
			if window_list[i]['focused'] == True:
				if i == 0:
					next_index = window_count - 1
				else:
					next_index = i - 1
				break
	else:
		raise Exception('either next or prev must be True')

	next_id = 0
	if next_index == -1 or next_index == window_count:
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

	all_workspaces = '-a' in sys.argv or '--all' in sys.argv

	if sys.argv[1] == 'next':
		print(get_window(next=True, all_workspaces=all_workspaces))
	elif sys.argv[1] == 'prev':
		print(get_window(prev=True, all_workspaces=all_workspaces))
	else:
		print_help()
		sys.exit(1)

if __name__ == '__main__':
	main()
