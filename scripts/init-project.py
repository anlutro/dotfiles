#!/usr/bin/env python3

import argparse
import json
import os
import os.path
import subprocess
import sys
import readline

interactive = False


def confirm(prompt, default=False):
	if interactive:
		prompt += ' [%s/%s] ' % (
			'Y' if default else 'y',
			'n' if default else 'N',
		)
		return input(prompt).lower().startswith('y')
	return default


def input_with_prefill(prompt, text):
	if not interactive:
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
	folder_exclude_patterns = ['build*']
	default_indent = 'tabs'
	default_spaces = ''

	for ptype in project_types:
		if ptype.startswith('python'):
			folder_exclude_patterns.extend(['.tox*', '.pytest_cache*', '.venv*', '.virtualenv*'])
		elif ptype == 'node' or ptype == 'nodejs':
			folder_exclude_patterns.append('node_modules*')
		elif ptype == 'php':
			folder_exclude_patterns.append('vendor*')
		elif ptype == 'go':
			folder_exclude_patterns.append('.gopath*')
		elif ptype == 'tf' or ptype == 'terraform':
			folder_exclude_patterns.append('.terraform*')
		elif ptype == 'ansible':
			file_exclude_patterns.append('*.retry')
		elif ptype in ('kotlin', 'kt', 'java'):
			folder_exclude_patterns.append('.gradle')
		elif ptype == 'puppet':
			default_indent = 'spaces'
			default_spaces = 2
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

	indent = input_with_prefill('Tabs or spaces for indentation? ', default_indent)
	data['settings']['translate_tabs_to_spaces'] = ('space' in indent.lower())

	spaces = input_with_prefill('Tab size? (leave empty for default) ', default_spaces)
	if spaces:
		data['settings']['tab_size'] = int(spaces.strip())

	if ptype.startswith('python'):
		python_path = None
		if 'VIRTUAL_ENV' in os.environ:
			python_path = os.environ['VIRTUAL_ENV'] + '/bin/python'
		if python_path:
			data['settings']['python_interpreter'] = python_path

	with open(path, 'w+') as f:
		f.write(json.dumps(data, indent=2) + '\n')
	print('Wrote', path)


def write_gitignore(path, project_types):
	ignores = []
	if 'python' in project_types:
		ignores.append([
			'# python', '__pycache__', '*.pyc', '/pip-selfcheck.json',
			'*.egg-info', '.eggs', '/dist',
		])
		ignores.append(['# pytest', '/.pytest_cache', '/.cache', '/.coverage'])
		ignores.append([
			'# virtualenv', '/.venv', '/.virtualenv',
			'/include', '/lib', '/lib64', '/share',
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
	files = set(os.listdir(root_dir))
	types = []
	if files & {'setup.py', 'setup.cfg', 'requirements', 'requirements.txt'}:
		types.append('python')
	if 'composer.json' in files:
		types.append('php')
	if 'main.go' in files:
		types.append('go')
	if 'package.json' in files:
		types.append('nodejs')
	if 'main.tf' in files:
		types.append('terraform')
	if 'ansible.cfg' in files or 'inventory' in files or 'roles' in files:
		types.append('ansible')
	if 'Vagrantfile' in files:
		types.append('vagrant')
	return types


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('-n', '--name', type=str, default=os.path.basename(os.getcwd()))
	parser.add_argument('--noninteractive', action='store_true')
	parser.add_argument('types', nargs='*', type=str)
	args = parser.parse_args()

	if args.noninteractive:
		global interactive
		interactive = False

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
			if not confirm('overwrite?'):
				continue
		func(filename, project_types)

	for project_type in project_types:
		skel_path = os.path.expanduser('~/.local/skel/project-%s/' % project_type)
		if (
			os.path.exists(skel_path) and
			confirm("copy files from %s if they don't already exist?" % skel_path)
		):
			subprocess.run(['rsync', '-rv', '--ignore-existing', skel_path, '.'])

if __name__ == '__main__':
	main()
