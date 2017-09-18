#!/usr/bin/env python

from __future__ import print_function
import argparse
import ast
from collections import defaultdict
import os
import os.path
import logging
import sys

log = logging.getLogger()


def find_module_files(root_path, depth, exclude):
    """
    Given a path, find all python files in that path and guess their module
    names. Generates tuples of (module, path).
    """
    def dir_excluded(d):
        return d in exclude or d.startswith('.')

    for root, dirs, files in os.walk(root_path):
        # prevents os.walk from recursing excluded directories
        dirs[:] = [d for d in dirs if not dir_excluded(d)]
        for file in files:
            path = os.path.join(root, file)
            relpath = os.path.relpath(path, root_path)
            if file.endswith('.py'):
                module = relpath.replace('.py', '').replace('/', '.')
                if file == '__init__.py':
                    module = module.replace('.__init__', '')
                log.debug('resolved %r to %r', relpath, module)
                yield module, path


def find_imports_in_file(path):
    with open(path) as f:
        try:
            tree = ast.parse(f.read())
        except SyntaxError:
            log.exception('SyntaxError in %r', path)
            return

    for node in ast.walk(tree):
        # note that there's no way for us to know if from x import y imports a
        # variable or submodule from x, so that will need to be figured out
        # later on in this script
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
    if exclude is None:
        exclude = []
    module_files = list(find_module_files(path, depth=depth, exclude=exclude))
    log.debug('found %d module files', len(module_files))

    imports_to_search_for = set(
        shorten_module(module, depth) for module, path in module_files
    )
    if extra:
        imports_to_search_for.update(extra)
    log.debug('imports_to_search_for: %r', imports_to_search_for)

    imports = set()
    for module, module_path in module_files:
        module_parts = module.split('.')
        module_path_parts = module_path.split('/')
        if exclude and (
            any(e in module_parts for e in exclude) or
            any(e in module_path_parts for e in exclude)
        ):
            log.debug('skipping: %r (%s)', module_path, module)
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


def locate_clusters(imports, depth=0):
    all_modules = set()
    for src_module, target_module in sorted(imports):
        all_modules.add(src_module)
        all_modules.add(target_module)
    clusters = defaultdict(lambda: set())
    for module in all_modules:
        clusters[shorten_module(module, depth)].add(module)
    return clusters.items()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('path', type=str, nargs='?', default=os.getcwd(),
        help='path to your Python code. defaults to pwd')
    parser.add_argument('-c', '--clusters', action='store_true',
        help='draw boxes around top-level modules')
    parser.add_argument('-d', '--depth', type=int, default=0,
        help='inspect submodules as well as top-level modules')
    parser.add_argument('-e', '--extra', type=str, default='',
        help='specify external modules that should be included in the graph, '
             'if they are imported')
    parser.add_argument('-x', '--exclude', type=str, default='',
        help='patterns of directories/submodules that should not be graphed. '
              'useful for tests, for example')
    parser.add_argument('-v', '--verbose', action='store_true')
    args = parser.parse_args()

    logging.basicConfig(
        format='%(asctime)s [%(levelname)8s] %(message)s',
        level=logging.DEBUG if args.verbose else logging.INFO,
    )

    extra = args.extra.split(',') if args.extra else []
    if args.path:
        extra.append(args.path.replace('/', '.'))
    exclude = args.exclude.split(',') if args.exclude else []

    imports = find_imports(
        args.path,
        depth=args.depth,
        extra=extra,
        exclude=exclude,
    )

    print('digraph {')
    if args.clusters:
        for cluster, nodes in locate_clusters(imports):
            if len(nodes) < 2:
                continue
            print('    subgraph cluster_%s {' % cluster)
            for node in nodes:
                print('        "%s";' % node)
            print('    }')
    for src_module, target_module in sorted(imports):
        print('    "%s" -> "%s";' % (src_module, target_module))
    print('}')

if __name__ == '__main__':
    main()
