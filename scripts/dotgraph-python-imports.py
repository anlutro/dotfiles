#!/usr/bin/env python

from __future__ import print_function
import argparse
import ast
import os
import os.path
import logging
log = logging.getLogger('dpi')



def find_module_files(root_path, depth, exclude):
	# return tuples of (module, path)
	def dir_excluded(dir):
		if dir in exclude:
			return True
		if dir.startswith('.'):
			return True
		return False

	for root, dirs, files in os.walk(root_path):
		if os.path.basename(root) in exclude:
			dirs[:] = []
		else:
			dirs[:] = [d for d in dirs if not dir_excluded(d)]
		for file in files:
			module = None
			path = os.path.join(root, file)
			relpath = os.path.relpath(path, root_path)
			if file.endswith('.py'):
				if file == '__init__.py':
					relpath = relpath.replace('/__init__', '')
				module = relpath.replace('.py', '').replace('/', '.')
				yield module, path
			if module:
				log.debug('resolved %r to %r', path, module)


def find_imports_in_file(path):
	with open(path) as f:
		tree = ast.parse(f.read())

	for node in ast.walk(tree):
		if isinstance(node, ast.ImportFrom):
			for name in node.names:
				yield '%s.%s' % (node.module, name.name)
		elif isinstance(node, ast.Import):
			for name in node.names:
				yield name.name


def shorten_module(module, depth):
	return '.'.join(module.split('.')[:depth+1])


def find_imports(path, depth=0, extra=None, exclude=None):
	module_files = list(find_module_files(path, depth=depth, exclude=exclude))
	log.debug('found %d module files', len(module_files))

	imports_to_search_for = set(
		shorten_module(module, depth) for module, path in module_files
	)
	if extra:
		imports_to_search_for.update(extra)

	imports = set()
	for module, path in module_files:
		module = shorten_module(module, depth)
		for module_import in find_imports_in_file(path):
			for import_to_search_for in imports_to_search_for:
				module_import = shorten_module(module_import, depth)
				if module != module_import and (
					module_import == import_to_search_for or
					module_import.startswith(import_to_search_for + '.')
				):
					imports.add((module, module_import))
	return imports


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('path', type=str, nargs='?', default=os.getcwd())
	parser.add_argument('-d', '--depth', type=int, default=0)
	parser.add_argument('-e', '--extra', type=str, default='')
	parser.add_argument('-x', '--exclude', type=str, default='')
	args = parser.parse_args()

	imports = find_imports(
		args.path,
		depth=args.depth,
		extra=args.extra,
		exclude=args.exclude,
	)

	print('digraph {')
	for src_module, target_module in sorted(imports):
		print('    "%s" -> "%s";' % (src_module, target_module))
	print('}')

if __name__ == '__main__':
	main()
