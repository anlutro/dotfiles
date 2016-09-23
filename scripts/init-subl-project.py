#!/usr/bin/env python3

import json
import sys


def main():
	if len(sys.argv) < 2:
		print('Usage: %s <project-name> [project-types ...]' % sys.argv[0])
		sys.exit(1)

	args = sys.argv[1:]
	project_name = args[0]

	folder_exclude_patterns = ["build*"]
	data = {
		"folders": [{
			"path": ".",
			"folder_exclude_patterns": folder_exclude_patterns,
		}],
	}

	for ptype in args[1:]:
		if ptype == 'python':
			folder_exclude_patterns.extend([
				".venv*",
				".virtualenv*",
				"bin*",
				"dist*",
				"include*",
				"lib*",
				"local*",
				"share*",
			])
		elif ptype == 'node' or ptype == 'nodejs':
			folder_exclude_patterns.append('node_modules*')
		elif ptype == 'php':
			folder_exclude_patterns.append('vendor*')
		else:
			print('Unknown project type: %r' % ptype)

	project_filename = project_name + '.sublime-project'
	with open(project_filename, 'w+') as f:
		f.write(json.dumps(data, indent=2) + '\n')


if __name__ == '__main__':
	main()
