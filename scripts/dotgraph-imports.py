#!/usr/bin/env python

from __future__ import print_function
from collections import defaultdict
from fnmatch import fnmatch
import argparse
import ast
import logging
import os
import os.path

log = logging.getLogger()


def find_root_module(path):
    path = os.path.abspath(path)
    module_parts = []
    while path != '/':
        def exists(filename):
            return os.path.exists(os.path.join(path, filename))
        if exists('setup.py') or exists('setup.cfg'):
            break
        module_parts.insert(0, os.path.basename(path))
        path = os.path.dirname(path)
    return '.'.join(module_parts)


def find_module_files(root_path, depth, exclude):
    """
    Given a path, find all python files in that path and guess their module
    names. Generates tuples of (module, path).
    """
    def dir_excluded(d):
        return d in exclude or d.startswith('.')

    root_module = find_root_module(root_path)
    log.debug('resolved path %r to root_module %r', root_path, root_module)

    for root, dirs, files in os.walk(root_path):
        # prevents os.walk from recursing excluded directories
        dirs[:] = [d for d in dirs if not dir_excluded(d)]
        for file in files:
            path = os.path.join(root, file)
            relpath = os.path.relpath(path, root_path)
            if file.endswith('.py'):
                module = relpath.replace('.py', '').replace('/', '.')
                module = module.replace('.__init__', '')
                if module == '__init__':
                    if root_module:
                        module = root_module
                    else:
                        log.warning('could not guess module of %r', relpath)
                        continue
                elif root_module:
                    module = '%s.%s' % (root_module, module)
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


def module_matches(module, searches, allow_fnmatch=False):
    for search in searches:
        if module == search or module.startswith(search + '.'):
            return True
        if allow_fnmatch and fnmatch(module, search):
            return True
    return False


def guess_path(module, path, root_module=None):
    if root_module:
        dotdots = ['..'] * (root_module.count('.') + 1)
        path = os.path.join(path, *dotdots)
    module_path = os.path.join(path, module.replace('.', '/'))
    return os.path.isdir(module_path) or os.path.isfile(module_path + '.py')


def find_imports(path, depth=0, extra=None, exclude=None):
    if exclude is None:
        exclude = []

    root_module = find_root_module(path)
    module_files = list(find_module_files(path, depth=depth, exclude=exclude))
    log.info('found %d module files', len(module_files))

    imports_to_search_for = set(
        shorten_module(module, depth) for module, path in module_files
    )
    if extra:
        imports_to_search_for.update(extra)
    log.info('imports_to_search_for: %r', sorted(imports_to_search_for))

    imports = set()
    for module, module_path in module_files:
        module_parts = module.split('.')
        module_path_parts = module_path.split('/')
        if exclude and (
            any(e in module_parts for e in exclude) or
            any(e in module_path_parts for e in exclude)
        ):
            log.debug('module skipped because it is in exclude: %r (%s)',
                module_path, module)
            continue

        module = shorten_module(module, depth)
        module_imports = list(find_imports_in_file(module_path))
        log.debug('found %d imports in %r (module=%r)',
            len(module_imports), module_path, module)

        for module_import in module_imports:
            module_import = shorten_module(module_import, depth)
            if module == module_import:
                log.debug('module is importing itself, skipping')
                continue

            if not module_matches(module_import, imports_to_search_for, allow_fnmatch=True):
                log.debug('module %r is not in imports_to_search_for, skipping',
                    module_import)
                continue

            module_import_path = guess_path(module_import, path, root_module)
            extra_match = module_matches(module_import, extra)
            if module_import_path or extra_match:
                imports.add((module, module_import))
            else:
                log.debug('skipping %r -> %r (module_import_path=%r, extra_match=%r)',
                    module, module_import, module_import_path, extra_match)

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
    parser.add_argument('-vv', '--very-verbose', action='store_true')
    args = parser.parse_args()

    level = logging.WARNING
    if args.very_verbose:
        level = logging.DEBUG
    elif args.verbose:
        level = logging.INFO

    logging.basicConfig(
        format='%(asctime)s [%(levelname)8s] %(message)s',
        level=level,
    )

    extra = args.extra.split(',') if args.extra else []
    exclude = args.exclude.split(',') if args.exclude else []

    imports = find_imports(
        args.path,
        depth=args.depth,
        extra=extra,
        exclude=exclude,
    )
    log.info('found total of %d imports in %r', len(imports), args.path)

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
