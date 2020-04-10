#!/usr/bin/env /home/andreas/code/dotfiles/.venv/bin/python

import re
import textwrap

WRAP_CHARS = 80


def wrap_markdown(s):
    new_lines = []
    in_code_block = False
    for line in s.splitlines():
        if line.startswith("```"):
            in_code_block = not in_code_block
            new_lines.append(line)
            continue

        is_list_item = (not in_code_block) and bool(re.match(r"^\s*[-*].*", line))
        is_code = in_code_block or (
            (not is_list_item) and line.startswith(("    ", "\t"))
        )

        if is_code:
            line = line.replace("\t", "    ")
        else:
            line = line.replace("\t", "  ")

        if len(line) < WRAP_CHARS or is_code:
            new_lines.append(line)
        else:
            subsequent_indent = re.search(r"^\s*", line).group(0)
            if is_list_item:
                subsequent_indent += "  "
            new_lines.extend(
                textwrap.wrap(line, WRAP_CHARS, subsequent_indent=subsequent_indent)
            )
    return "\n".join(new_lines)


def process_file(file):
    with open(file, "rt") as fh:
        md_text = fh.read()
    new_md_text = wrap_markdown(md_text)
    with open(file, "wt") as fh:
        fh.write(new_md_text)


def process_files(files):
    for file in files:
        print("processing", file, "...")
        process_file(file)


def main():
    import argparse

    p = argparse.ArgumentParser()
    p.add_argument("-t", "--test", action="store_true")
    p.add_argument("files", nargs="*")
    args = p.parse_args()

    if args.test:
        pass  # TODO
    elif args.files:
        process_files(args.files)
    else:
        print("Must provide at least one file!")


if __name__ == "__main__":
    main()
