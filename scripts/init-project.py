#!/usr/bin/env python3

import json
import os
import os.path
import readline
import sys


def input_with_prefill(prompt, text):
	def hook():
		readline.insert_text(text)
		readline.redisplay()
	readline.set_pre_input_hook(hook)
	result = input(prompt)
	readline.set_pre_input_hook()
	return result


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
		"settings": {}
	}

	indent = input_with_prefill('Tabs or spaces for indentation? ', 'tabs')
	data['settings']['translate_tabs_to_spaces'] = ('space' in indent.lower())

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
		ignores.append([
			'# virtualenv', '/.venv', '/.virtualenv',
			'/bin', '/dist', '/include', '/lib', '/lib64', '/share',
		])

	if 'php' in project_types:
		ignores.append(['/vendor'])

	if os.path.exists('Vagrantfile'):
		ignores.append(['# vagrant', '/.vagrant'])

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
	file_funcs = (
		(project_name + '.sublime-project', write_sublime_project),
		('.gitignore', write_gitignore),
	)
	for filename, func in file_funcs:
		if os.path.exists(filename):
			print(filename, 'already exists!')
			if not input('overwrite? [y/n] ').lower().startswith('y'):
				continue
		func(filename, project_types)

if __name__ == '__main__':
	main()
