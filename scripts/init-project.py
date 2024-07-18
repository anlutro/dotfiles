#!/usr/bin/env -S ${HOME}/code/dotfiles/.venv/bin/python

import argparse
import json
import os
import os.path
import subprocess
import sys
import readline
import textwrap


is_interactive = sys.__stdin__.isatty


def confirm(prompt, default=False):
    if is_interactive():
        prompt += " [%s/%s] " % (
            "Y" if default else "y",
            "n" if default else "N",
        )
        return input(prompt).lower().startswith("y")
    return default


def file_overwrite_confirm(path, default=False):
    if not os.path.exists(path):
        return True
    end = "!" if is_interactive() else "- not overwriting"
    print(path, "already exists", end)
    return confirm("overwrite?", default=default)


def input_with_prefill(prompt, text):
    if not is_interactive():
        return text

    def hook():
        readline.insert_text(text)
        readline.redisplay()

    readline.set_pre_input_hook(hook)
    result = input(prompt)
    readline.set_pre_input_hook()
    return result


def write_sublime_project(path, project_types):
    file_exclude_patterns = []
    folder_exclude_patterns = []
    default_indent = "spaces"
    default_spaces = ""

    for ptype in project_types:
        if ptype.startswith("python"):
            folder_exclude_patterns.extend(
                [".tox*", ".pytest_cache*", ".venv*", ".mypy_cache*"]
            )
        elif ptype == "node" or ptype == "nodejs":
            folder_exclude_patterns.append("node_modules*")
        elif ptype == "php":
            folder_exclude_patterns.append("vendor*")
        elif ptype == "tf" or ptype == "terraform":
            folder_exclude_patterns.append(".terraform*")
        elif ptype == "ansible":
            file_exclude_patterns.append("*.retry")
        elif ptype in ("kotlin", "kt", "java"):
            folder_exclude_patterns.append(".gradle")
        elif ptype in ("puppet", "elixir", "crystal", "ruby"):
            default_indent = "spaces"
            default_spaces = 2
        else:
            print("Unknown project type: %r" % ptype)

    data = {
        "folders": [
            {
                "path": ".",
                "file_exclude_patterns": file_exclude_patterns,
                "folder_exclude_patterns": folder_exclude_patterns,
            }
        ],
        "settings": {},
    }

    indent = input_with_prefill("Tabs or spaces for indentation? ", default_indent)
    data["settings"]["translate_tabs_to_spaces"] = "space" in indent.lower()

    spaces = input_with_prefill("Tab size? (leave empty for default) ", default_spaces)
    if spaces:
        data["settings"]["tab_size"] = int(spaces)

    if any(ptype.startswith("python") for ptype in project_types):
        pylsp_settings = (
            data["settings"]
            .setdefault("LSP", {})
            .setdefault("LSP-pylsp", {})
            .setdefault("settings", {})
        )
        if "VIRTUAL_ENV" in os.environ:
            bin_path = os.environ["VIRTUAL_ENV"]
            data["settings"]["python_interpreter"] = bin_path + "/python"
            pylsp_settings["pylsp.python_binary"] = bin_path + "/python"
            pylsp_settings["pylsp.plugins.jedi.environment"] = os.environ["VIRTUAL_ENV"]
            if os.path.exists(bin_path + "/pylint"):
                pylsp_settings["pylsp.plugins.pylint.enabled"] = True
                pylsp_settings["pylsp.plugins.pylint.executable"] = bin_path + "/pylint"

    with open(path, "w+") as f:
        f.write(json.dumps(data, indent=2) + "\n")
    print("Wrote", path)


def write_gitignore(path, project_types):
    ignores = []
    if "python" in project_types:
        ignores.append(
            [
                "# python",
                "__pycache__",
                "*.pyc",
                "/pip-selfcheck.json",
                "*.egg-info",
                ".eggs",
                "/dist",
            ]
        )
        ignores.append(["# pytest", "/.pytest_cache", "/.cache", "/.coverage"])
        ignores.append(["# mypy", "/.mypy_cache"])
        ignores.append(["# virtualenv", "/.venv", "/.virtualenv", ".tox"])

    if "php" in project_types:
        ignores.append(["/vendor"])

    if "vagrant" in project_types:
        ignores.append(["# vagrant", "/.vagrant"])

    gitignore_str = "\n\n".join(["\n".join(ign) for ign in ignores])
    if gitignore_str:
        with open(path, "w+") as f:
            f.write(gitignore_str + "\n")
        print("Wrote", path)


GIT_HOOK_SIGNATURE = "###managed by init-project###"


def is_hook_file_managed(path):
    if not os.path.exists(path):
        return True
    with open(path, "rt") as fh:
        for line in fh:
            if line.strip() == GIT_HOOK_SIGNATURE:
                return True
    return file_overwrite_confirm(path)


BLACK_HOOK = """
py_files=$(git diff --cached --name-only --diff-filter=AM | grep '\\.py$')
if [ -n "$py_files" ]; then
    echo $py_files | xargs black
    git add $py_files
fi
"""


def write_git_hooks(hooks_dir, project_types):
    if not os.path.exists(hooks_dir):
        print(hooks_dir, "does not exist, skipping")
        return

    write_paths = {}
    if "python" in project_types:
        write_paths[os.path.join(hooks_dir, "pre-commit")] = BLACK_HOOK
    for path, lines in write_paths.items():
        if not is_hook_file_managed(path):
            continue
        with open(path, "wt") as fh:
            fh.write("#!/bin/sh\n" + GIT_HOOK_SIGNATURE + "\n\n")
            if isinstance(lines, (str, bytes)):
                fh.write(textwrap.dedent(lines))
            else:
                fh.write("\n".join(lines))
            fh.write("\n")
        os.chmod(path, 0o755)
        print("Wrote to", path)


python_files = {
    "setup.py",
    "setup.cfg",
    "pyproject.toml",
    "requirements",
    "requirements.txt",
}


def guess_project_types(root_dir=None):
    if not root_dir:
        root_dir = os.getcwd()
    files = set(os.listdir(root_dir))
    types = []
    if files & python_files:
        types.append("python")
    if "composer.json" in files:
        types.append("php")
    if "main.go" in files:
        types.append("go")
    if "package.json" in files:
        types.append("nodejs")
    if "main.tf" in files:
        types.append("terraform")
    if "ansible.cfg" in files or "inventory" in files or "roles" in files:
        types.append("ansible")
    if "Vagrantfile" in files:
        types.append("vagrant")
    return types


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-n", "--name", type=str, default=os.path.basename(os.getcwd()))
    parser.add_argument("--noninteractive", action="store_true")
    parser.add_argument("--allow-no-type", action="store_true")
    parser.add_argument("types", nargs="*", type=str)
    args = parser.parse_args()

    if args.noninteractive:
        global is_interactive
        is_interactive = lambda: False

    project_name = args.name
    print("Project name:", project_name)
    if args.types:
        project_types = args.types
        print("Project types:", ",".join(project_types))
    else:
        project_types = guess_project_types()
        if project_types:
            print("Project types (guessed):", ",".join(project_types))
        else:
            print("Could not guess project type and no project type provided!")
            if not args.allow_no_type:
                sys.exit(1)

    file_funcs = (
        (project_name + ".sublime-project", write_sublime_project),
        (".gitignore", write_gitignore),
    )
    for filename, func in file_funcs:
        if not file_overwrite_confirm(filename):
            continue
        func(filename, project_types)

    for project_type in project_types:
        skel_path = os.path.expanduser("~/.local/skel/project-%s/" % project_type)
        if os.path.exists(skel_path) and confirm(
            "copy files from %s if they don't already exist?" % skel_path
        ):
            subprocess.run(["rsync", "-rv", "--ignore-existing", skel_path, "."])

    write_git_hooks(".git/hooks", project_types)


if __name__ == "__main__":
    main()
