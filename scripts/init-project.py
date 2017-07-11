#!/usr/bin/env python3

import argparse
import json
import os
import os.path
import sys
import readline


def input_with_prefill(prompt, text):
	def hook():
		readline.insert_text(text)
		readline.redisplay()
	readline.set_pre_input_hook(hook)
	result = input(prompt)
	readline.set_pre_input_hook()
	return result


def write_sublime_project(path, project_types):
	file_exclude_patterns = []
	folder_exclude_patterns = ['build*']

	for ptype in project_types:
		if ptype.startswith('python'):
			folder_exclude_patterns.extend([
				'.tox*',
				'.venv*',
				'.virtualenv*',
				'bin*',
				'dist*',
				'include*',
				'lib*',
				'local*',
				'share*',
			])
		elif ptype == 'node' or ptype == 'nodejs':
			folder_exclude_patterns.append('node_modules*')
		elif ptype == 'php':
			folder_exclude_patterns.append('vendor*')
		elif ptype == 'go':
			folder_exclude_patterns.append('.gopath*')
		elif ptype == 'tf' or ptype == 'terraform':
			folder_exclude_patterns.append('.terraform*')
		else:
			print('Unknown project type: %r' % ptype)

	data = {
		'folders': [{
			'path': '.',
			'file_exclude_patterns': file_exclude_patterns,
			'folder_exclude_patterns': folder_exclude_patterns,
		}],
		'settings': {}
	}

	indent = input_with_prefill('Tabs or spaces for indentation? ', 'tabs')
	data['settings']['translate_tabs_to_spaces'] = ('space' in indent.lower())

	spaces = input_with_prefill('Tab size? (leave empty for default) ', '')
	if spaces:
		data['settings']['tab_size'] = int(spaces.strip())

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

	if 'vagrant' in project_types:
		ignores.append(['# vagrant', '/.vagrant'])

	gitignore_str = '\n\n'.join(['\n'.join(ign) for ign in ignores])
	if gitignore_str:
		with open(path, 'w+') as f:
			f.write(gitignore_str + '\n')
		print('Wrote', path)


def guess_project_types(root_dir=None):
	if not root_dir:
		root_dir = os.getcwd()
	files = os.listdir(root_dir)
	types = []
	if 'setup.py' in files or 'requirements.txt' in files:
		types.append('python')
	if 'composer.json' in files:
		types.append('php')
	if 'main.go' in files:
		types.append('go')
	if 'package.json' in files:
		types.append('nodejs')
	if 'main.tf' in files:
		types.append('terraform')
	if 'Vagrantfile' in files:
		types.append('vagrant')
	return types


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('-n', '--name', type=str, default=os.path.basename(os.getcwd()))
	parser.add_argument('types', nargs='*', type=str)
	args = parser.parse_args()

	project_name = args.name
	print('Project name:', project_name)
	if args.types:
		project_types = args.types
		print('Project types:', project_types)
	else:
		project_types = guess_project_types()
		if not project_types:
			print('Could not guess project type and no project type provided!')
			sys.exit(1)
		print('Project types (guessed):', project_types)
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
