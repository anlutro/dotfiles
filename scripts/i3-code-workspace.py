#!/usr/bin/env python3

import json
import subprocess
import os


def find_code_dirs(root_dir, max_depth=3):
    max_depth += root_dir.rstrip(os.path.sep).count(os.path.sep)
    for dirpath, dirs, files in os.walk(root_dir):
        depth = dirpath.count(os.path.sep)
        # don't recurse further
        if depth > max_depth:
            del dirs[:]
            continue
        # if the directory has a .git subdirectory, yield it
        if ".git" in dirs:
            yield dirpath


def rofi_pick_from_options(options, prompt=None):
    cmd = ["rofi", "-dmenu"]
    if prompt:
        cmd += ["-p", prompt]
    result = subprocess.run(
        cmd,
        input="\n".join(options),
        encoding="ascii",
        check=True,
        capture_output=True,
    )
    return result.stdout


def i3_get_workspaces():
    out = subprocess.check_output(["i3-msg", "-t", "get_workspaces"])
    return json.loads(out)


def find_workspace(code_dir, workspaces):
    dirname = os.path.basename(code_dir)
    for workspace in workspaces:
        name = workspace["name"]
        if ":" in name:
            name = name.split(":", maxsplit=1)[1]
        if name == dirname:
            return workspace


def i3_switch_to_workspace(workspace):
    cmd = f"workspace {workspace['name']}"
    subprocess.check_call(["i3-msg", cmd])


def i3_create_workspace(code_dir):
    dirname = os.path.basename(code_dir)
    # 4 is an arbitrary number
    cmd = (
        f"workspace 4:{dirname}; layout tabbed;"
        f"exec ~/code/dotfiles/scripts/term.sh -w {code_dir};"
        f"exec ~/code/dotfiles/scripts/sublp.sh {code_dir};"
    )
    subprocess.check_call(["i3-msg", cmd])


def main():
    code_dirs = find_code_dirs("/home/andreas/code")
    code_dir = rofi_pick_from_options(code_dirs, prompt="select code dir")
    if not code_dir:
        print("no code dir selected")
        return
    workspaces = i3_get_workspaces()
    if workspace := find_workspace(code_dir, workspaces):
        i3_switch_to_workspace(workspace)
    else:
        i3_create_workspace(code_dir)


if __name__ == "__main__":
    main()
