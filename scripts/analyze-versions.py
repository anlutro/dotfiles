#!/usr/bin/env python

from __future__ import print_function
from collections import defaultdict
from distutils.version import StrictVersion, LooseVersion
from pip.req import parse_requirements
from pkg_resources import Requirement
import argparse
import logging
import os
import os.path
import re
import sys

log = logging.getLogger()


def find_requirements_files(project_dir):
    """ Find requirements files inside a directory. """
    files = []
    req_file = os.path.join(project_dir, "requirements.txt")
    if os.path.exists(req_file):
        files.append(req_file)
    req_dir = os.path.join(project_dir, "requirements")
    if os.path.exists(req_dir) and os.path.isdir(req_dir):
        isfile = lambda *p: os.path.isfile(os.path.join(req_dir, *p))
        req_dir_files = [f for f in os.listdir(req_dir) if isfile(f)]
        for req_file in req_dir_files:
            if req_file.startswith(("dev", "test")):
                continue
            files.append(os.path.join(req_dir, req_file))
    log.debug("found requirement files in %r: %r", project_dir, files)
    return files


def parse_project_requirements(project_dir):
    """
    Parse requirements files inside a directory and return a list of parsed
    requirements. The returned list will consist of tuples (package, version).
    """
    requirements = []
    req_files = find_requirements_files(project_dir)
    for req_file in req_files:
        parsed_requirements = parse_requirements(req_file, session="uglyhack")
        for ir in parsed_requirements:
            if ir.editable:
                match = re.search(r"git\+.*@([\w\d._-]+)#egg=([\w\d_-]+)", str(ir.link))
                if match:
                    requirements.append((match.group(2), "==%s" % match.group(1)))
            else:
                match = re.search(r"([\d\w_-]+)([=><].*)", str(ir.req))
                if match:
                    requirements.append((match.group(1), match.group(2)))
    log.debug("parsed requirements from %r: %r", project_dir, requirements)
    return requirements


def find_version_in_specs(specs, cls=StrictVersion):
    """ Try to extract an exact version number from a list of specs. """
    try:
        for operator, version in specs:
            if operator == "==":
                return cls(version)
        for operator, version in specs:
            if operator in (">", ">="):
                return cls(version)
        raise RuntimeError("could not construct version from specs: %r" % specs)
    except ValueError as e:
        log.warning("could not construct %s for specs %r: %s", cls, specs, e)
        return find_version_in_specs(specs, cls=LooseVersion)


def get_diverging_packages(project_dirs, min_diverging=2):
    """ From a sequence of projects, find packages with diverging versions. """
    packages = defaultdict(lambda: set())

    for project_dir in project_dirs:
        log.debug("checking project dir: %s", project_dir)
        os.chdir(project_dir)
        try:
            requirements = parse_project_requirements(project_dir)
        except Exception as e:
            log.warning("could not parse %s, skipping: %r", project_dir, e)
            continue
        for package, requirement in requirements:
            packages[package].add(requirement)

    # filter out packages with less diverging versions than asked for
    packages = {k: v for k, v in packages.items() if len(v) >= min_diverging}

    return packages


def sort_requirement_specs(reqs):
    """ Given a sequence of requirements, sort them based on version number. """
    parsed_reqs = [Requirement.parse("x%s" % r) for r in reqs]
    return sorted(
        [r.specs for r in parsed_reqs if r.specs],
        key=lambda s: find_version_in_specs(s),
    )


def sort_packages(packages):
    """
    Take a dict of {package: requirements} and first sort the requirements
    based on version number (see sort_requirement_specs), then sort the dict
    items based on how many *different* versions there are.
    """
    # we don't just call packages[pkg].sort(key=...) because the values of the
    # dict are sets, not lists, which don't implement the .sort method
    # map(packages.values(), lambda r: r.sort(key=lambda s: find_version_in_specs(s)))
    packages = {
        package: sort_requirement_specs(reqs) for package, reqs in packages.items()
    }
    return sorted(packages.items(), key=lambda item: len(item[1]))


def find_project_dirs(path=None):
    """ Find directories that contain requirements. """
    if path is None:
        path = os.getcwd()

    python_dirs = []
    for path_dir in os.listdir(path):
        # resolve symlinks
        path_dir = os.path.realpath(path_dir)

        if not os.path.isdir(path_dir):
            continue
        exists = lambda *p: os.path.exists(os.path.join(path_dir, *p))
        if not any(map(exists, ("requirements", "requirements.txt", "setup.py"))):
            continue
        python_dirs.append(path_dir)
    return python_dirs


def main():
    parser = argparse.ArgumentParser(
        description="Assuming a set of python "
        "project directories are in PWD, find their requirements files and "
        "print packages that have many different versions required."
    )
    parser.add_argument("-v", "--verbose", action="store_true")
    parser.add_argument("-m", "--min-diverging", type=int, default=2)
    args = parser.parse_args()

    logging.basicConfig(
        format="%(asctime)s [%(levelname)8s] %(message)s",
        level=logging.DEBUG if args.verbose else logging.INFO,
    )

    project_dirs = find_project_dirs()
    if not project_dirs:
        log.warning("no project directories found!")
        return

    packages = get_diverging_packages(project_dirs, min_diverging=args.min_diverging)
    if not packages:
        log.warning("no diverging packages found!")
        return

    packages = sort_packages(packages)

    for package, requirements in packages:
        flat_reqs = []
        for requirement in requirements:
            flat_reqs.append(",".join("".join(spec) for spec in requirement))
        print("%s: %s" % (package, ", ".join(flat_reqs)))


if __name__ == "__main__":
    main()
