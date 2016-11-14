#!/usr/bin/env python3

import json
import sys
import os
import os.path


def write_sublime_project(path, project_types):
	folder_exclude_patterns = ["build*"]

	for ptype in project_types:
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

	data = {
		"folders": [{
			"path": ".",
			"folder_exclude_patterns": folder_exclude_patterns,
		}],
	}

	with open(path, 'w+') as f:
		f.write(json.dumps(data, indent=2) + '\n')
	print('Wrote', path)


def write_gitignore(path, project_types):
	ignores = []
	if 'python' in project_types:
		ignores.append([
			'# python', '__pycache__', '*.pyc',
			'/pip-selfcheck.json', '*.egg-info',
		])
		ignores.append(['# pytest', '/.cache', '/.coverage'])
		if os.path.exists('.venv'):
			ignores.append(['# virtualenv', '.venv'])
		elif os.path.exists('.virtualenv'):
			ignores.append(['# virtualenv', '.virtualenv'])
		elif os.path.exists('lib') and os.path.exists('include'):
			ignores.append([
				'# virtualenv', 'bin', 'dist', 'include', 'lib', 'lib64', 'share',
			])

	if os.path.exists('Vagrantfile'):
		ignores.append(['# vagrant', '.vagrant'])

	gitignore_str = '\n\n'.join(['\n'.join(ign) for ign in ignores])
	if gitignore_str:
		with open(path, 'w+') as f:
			f.write(gitignore_str + '\n')
		print('Wrote', path)


def main():
	if len(sys.argv) < 2:
		print('Usage: %s [project_types ...]' % sys.argv[0])
		sys.exit(1)

	project_name = os.path.basename(os.getcwd())
	project_types = sys.argv[1:]
	print('Project name:', project_name)
	print('Project types:', project_types)
	file_func_map = {
		project_name + '.sublime-project': write_sublime_project,
		'.gitignore': write_gitignore,
	}
	for filename, func in file_func_map.items():
		if os.path.exists(filename):
			print(filename, 'already exists!')
			if not input('overwrite? [y/n] ').lower().startswith('y'):
				continue
		func(filename, project_types)

if __name__ == '__main__':
	main()
