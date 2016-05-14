#!/usr/bin/env python3
'''
Get the window ID of the next or previous window in the current workspace.

	$ i3-msg -t get_tree | i3-get.py next
	41943050
	$ i3-msg -t get_tree | i3-get.py prev
	39845898

Complete shell script to focus the next window:

	id=$(i3-msg -t get_tree | i3-get.py next)
	[ $? = 0 ] && [ "$id" ] && i3-msg [id="$id"] focus

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

	for node in tree_dict['nodes']:
		workspace = find_active_workspace(node, current_workspace)
		if workspace is not None:
			return workspace

	for node in tree_dict['floating_nodes']:
		workspace = find_active_workspace(node, current_workspace)
		if workspace is not None:
			return workspace


def find_windows(tree_dict, window_list):
	if tree_dict['nodes'] or tree_dict['floating_nodes']:
		for node in tree_dict['nodes']:
			find_windows(node, window_list)
		for node in tree_dict['floating_nodes']:
			find_windows(node, window_list)
	else:
		if (tree_dict['layout'] != 'dockarea' and
				not tree_dict['name'].startswith('i3bar for output') and
				not tree_dict['window'] == None):
			window_list.append(tree_dict)

	return window_list        


def get_window(find='next', all_workspaces=False):
	tree = json.load(sys.stdin)
	if not all_workspaces:
		tree = find_active_workspace(tree)
	window_list = find_windows(tree, [])

	window_count = len(window_list)
	if window_count < 2:
		return ''

	if find == 'next':
		next_index = -1
		for i in range(window_count):
			if window_list[i]['focused'] == True:
				next_index = i + 1
				break
	elif find == 'prev':
		next_index = window_count
		for i in range(window_count - 1, -1, -1):
			if window_list[i]['focused'] == True:
				if i == 0:
					next_index = window_count - 1
				else:
					next_index = i - 1
				break
	else:
		exit_help()

	next_id = 0
	if next_index == -1 or next_index == window_count:
		next_id = window_list[0]['window']
	else:
		next_id = window_list[next_index]['window']

	return next_id


def exit_help():
	print('Usage: i3-get.py (next|prev)')
	sys.exit(1)


def main():
	if len(sys.argv) < 2:
		exit_help()

	all_workspaces = '-a' in sys.argv or '--all' in sys.argv
	print(get_window(sys.argv[1], all_workspaces=all_workspaces))

if __name__ == '__main__':
	main()
