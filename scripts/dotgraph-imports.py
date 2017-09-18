#!/usr/bin/env python

from __future__ import print_function
import argparse
import ast
import os
import os.path
import logging
import sys

log = logging.getLogger()


def find_module_files(root_path, depth, exclude):
    # return tuples of (module, path)
    def dir_excluded(d):
        return d in exclude or d.startswith('.')

    for root, dirs, files in os.walk(root_path):
        dirs[:] = [d for d in dirs if not dir_excluded(d)]
        for file in files:
            path = os.path.join(root, file)
            relpath = os.path.relpath(path, root_path)
            if file.endswith('.py'):
                module = relpath.replace('.py', '').replace('/', '.')
                if file == '__init__.py':
                    module = module.replace('.__init__', '')
                log.debug('resolved %r to %r', path, module)
                yield module, path


def find_imports_in_file(path):
    with open(path) as f:
        try:
            tree = ast.parse(f.read())
        except SyntaxError:
            log.exception('SyntaxError in %r', path)
            return

    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom):
            for name in node.names:
                yield '%s.%s' % (node.module, name.name)
        elif isinstance(node, ast.Import):
            for name in node.names:
                yield name.name


def shorten_module(module, depth):
    return '.'.join(module.split('.')[:depth+1])


def module_matches(module, searches):
    for search in searches:
        if module == search or module.startswith(search + '.'):
            return True
    return False


def guess_path(module, path):
    module_path = os.path.join(path, module.replace('.', '/'))
    return os.path.isdir(module_path) or os.path.isfile(module_path + '.py')


def find_imports(path, depth=0, extra=None, exclude=None):
    module_files = list(find_module_files(path, depth=depth, exclude=exclude))
    log.debug('found %d module files', len(module_files))

    imports_to_search_for = set(
        shorten_module(module, depth) for module, path in module_files
    )
    if extra:
        imports_to_search_for.update(extra)

    imports = set()
    for module, module_path in module_files:
        if exclude in module.split('.') or exclude in module_path.split('/'):
            continue
        module = shorten_module(module, depth)
        for module_import in find_imports_in_file(module_path):
            module_import = shorten_module(module_import, depth)
            if (
                module != module_import and
                module_matches(module_import, imports_to_search_for) and (
                    guess_path(module_import, path) or
                    module_matches(module_import, extra)
                )
            ):
                imports.add((module, module_import))
    return imports


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('path', type=str, nargs='?', default=os.getcwd())
    parser.add_argument('-d', '--depth', type=int, default=0)
    parser.add_argument('-e', '--extra', type=str, default='')
    parser.add_argument('-v', '--verbose', action='store_true')
    parser.add_argument('-x', '--exclude', type=str, default='')
    args = parser.parse_args()

    logging.basicConfig(
        format='%(asctime)s [%(levelname)8s] %(message)s',
        level=logging.DEBUG if args.verbose else logging.INFO,
    )

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
