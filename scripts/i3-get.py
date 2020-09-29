#!/usr/bin/env /home/andreas/code/dotfiles/.venv/bin/python
"""
Get the window ID of the next or previous window in the current workspace.

    $ i3-msg -t get_tree | i3-get.py next
    41943050
    $ i3-msg -t get_tree | i3-get.py prev
    39845898

Complete shell script to focus the next window:

    id=$(i3-msg -t get_tree | i3-get.py next)
    [ $? = 0 ] && [ "$id" ] && i3-msg [id="$id"] focus
"""

import json
import sys


def find_active_workspace(tree_dict, current_workspace=None):
    if tree_dict.get("focused"):
        return current_workspace
    if tree_dict.get("type") == "workspace":
        current_workspace = tree_dict

    for node in tree_dict["nodes"]:
        workspace = find_active_workspace(node, current_workspace)
        if workspace is not None:
            return workspace

    for node in tree_dict["floating_nodes"]:
        workspace = find_active_workspace(node, current_workspace)
        if workspace is not None:
            return workspace


def find_windows(tree_dict, window_list):
    if tree_dict["nodes"] or tree_dict["floating_nodes"]:
        for node in tree_dict["nodes"]:
            find_windows(node, window_list)
        for node in tree_dict["floating_nodes"]:
            find_windows(node, window_list)
    else:
        if (
            tree_dict["layout"] != "dockarea"
            and not tree_dict["name"].startswith("i3bar for output")
            and not tree_dict["window"] == None
        ):
            window_list.append(tree_dict)

    return window_list


def get_window(tree, find="next", all_workspaces=False):
    if not all_workspaces:
        tree = find_active_workspace(tree)
    window_list = find_windows(tree, [])

    window_count = len(window_list)
    if window_count < 2:
        return ""

    if find == "next":
        window_idx = -1
        for i in range(window_count):
            if window_list[i]["focused"] == True:
                window_idx = i + 1
                break
    elif find == "prev":
        window_idx = window_count
        # iterate backwards by 1, starting at window_count-1
        for i in range(window_count - 1, -1, -1):
            if window_list[i]["focused"] == True:
                window_idx = i - 1
                break
    else:
        raise ValueError("unknown find/direction: %r" % find)

    while window_idx >= window_count:
        window_idx -= window_count

    return window_list[window_idx]["window"]


def main():
    tree = json.loads(sys.stdin.read())
    print(get_window(tree, sys.argv[1]))


if __name__ == "__main__":
    main()
