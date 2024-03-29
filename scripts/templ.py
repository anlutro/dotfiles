#!/usr/bin/env -S ${HOME}/code/dotfiles/.venv/bin/python

import sys


def exit_msg(code, msg):
    sys.stderr.write(msg + "\n")
    sys.exit(code)


def get_var_dict(var_list):
    var_dict = {}

    for item in var_list:
        try:
            k, v = item.split("=", 1)
            var_dict[k] = v
        except ValueError as e:
            msg = (
                "Invalid argument: {}\n".format(item)
                + "Variables must be provided in key=value format"
            )
            exit_msg(1, msg)

    return var_dict


def main():
    if len(sys.argv) < 2 or sys.argv[1] == "-h":
        print("Usage: templ <file> var1=value1")
        return

    input_file = sys.argv[1]

    if input_file == "-":
        input_file = sys.stdin
    else:
        try:
            input_file = open(input_file)
        except FileNotFoundError as e:
            exit_msg(2, "File not found: {}".format(e.filename))

    content = input_file.read()
    input_file.close()

    variables = get_var_dict(sys.argv[2:])

    try:
        sys.stdout.write(content.format(**variables))
    except KeyError as e:
        exit_msg(1, "Undefined variable: {}".format(e.args[0]))


if __name__ == "__main__":
    main()
