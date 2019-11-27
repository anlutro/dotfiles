#!/usr/bin/env python3

import argparse
import logging
import os
import sys

import github3



LABELS = {
    # github defaults
    'bug': (
        'd73a4a', # red
        "Something isn't working",
    ),
    'duplicate': (
        'cfd3d7', # grey
        "This issue or pull request already exists",
    ),
    'enhancement': (
        'a2eeef', # light blue
        "New feature or request",
    ),
    'good first issue': (
        '7057ff', # blue/purple-ish
        "Good for newcomers",
    ),
    'help wanted': (
        '008672', # teal
        "Extra attention is needed",
    ),
    'invalid': (
        'e4e669', # yellow
        "This doesn't seem right",
    ),
    'question': (
        'd876e3', # purple
        "Further information is requested"
    ),
    'wontfix': (
        'ffffff', # white
        "This will not be worked on",
    ),

    # custom
    'wip': (
        'fbca04', # yellow
        "Work in progress",
    ),
    'discussion': (
        'd876e3', # light purple
        "Needs to be discussed"
    ),
    'documentation': (
        'bfdadc', # light teal
        "Problem with or suggestion for documentation"
    ),
}


def normalize_whitelist(whitelist, user):
    if not whitelist:
        return []

    for item in whitelist:
        if '/' not in item:
            yield '%s/%s' % (user.login, item)
            continue

        if item.startswith('https://github.com/'):
            item = item[19:]
        yield item


def get_repos(github, whitelist=None):
    user = github.me()
    repo_dict = {}
    whitelist = set(normalize_whitelist(whitelist, user))

    def add_repo(repo):
        if repo.archived or not repo.has_issues:
            return
        if whitelist and repo.full_name not in whitelist:
            return
        repo_dict[repo.full_name] = repo

    def add_repos(repos):
        for repo in repos:
            add_repo(repo)

    add_repos(github.repositories_by(user.login))
    for org in user.organizations():
        add_repos(github.repositories_by(org.login))

    return repo_dict


def parse_args(args=None):
    parser = argparse.ArgumentParser()
    parser.add_argument('-t', '--token', default=os.getenv('GITHUB_TOKEN'))
    parser.add_argument('--fix-colors', action='store_true')
    parser.add_argument('--fix-description', action='store_true')
    parser.add_argument('--fix-name', action='store_true')
    parser.add_argument('--fix-missing', action='store_true')
    parser.add_argument('--delete-extra', action='store_true')
    parser.add_argument('-v', '--verbose', action='store_true')
    parser.add_argument('repo', nargs='*')
    return parser.parse_args(args)


def main():
    args = parse_args()
    logging.basicConfig(
        format='%(asctime)s [%(levelname)8s] [%(name)s] %(message)s',
        level=logging.DEBUG if args.verbose else logging.WARNING
    )

    github = github3.login(token=args.token)
    if not github:
        print('-t / --token / GITHUB_TOKEN missing')
        sys.exit(1)
    repos = get_repos(github, args.repo)
    print('Checking repos:', ', '.join(repos))

    for repo in repos.values():
        repo_labels = set()
        for label in repo.labels():
            label_edit_kwargs = {}
            lname = label.name.lower().strip()
            repo_labels.add(lname)

            if lname not in LABELS:
                continue

            if lname != label.name:
                print('updating %r name to %r in %r' % (label, lname, repo))
                if args.fix_name:
                    label_edit_kwargs['name'] = lname

            lcolor, ldescription = LABELS[lname]

            if label.color.lower() != lcolor:
                print('updating %r color from #%s to #%s in %r' % (
                    label, label.color, lcolor, repo
                ))
                if args.fix_colors:
                    label_edit_kwargs['color'] = lcolor

            if label.description is not None and label.description != ldescription:
                print('updating %r description from %r to %r in %r' % (
                    label, label.description, ldescription, repo
                ))
                if args.fix_description:
                    label_edit_kwargs['description'] = ldescription

            if label_edit_kwargs:
                label_edit_kwargs.setdefault('name', lname)
                label_edit_kwargs.setdefault('color', lcolor)
                label_edit_kwargs.setdefault('description', ldescription)
                label.edit(**label_edit_kwargs)

        missing_labels = set(LABELS) - repo_labels
        for label_name in missing_labels:
            print('adding missing label %r to %r' % (label_name, repo))
            if args.fix_missing:
                repo.create_label(label_name, *LABELS[label_name])

        extra_labels = repo_labels - set(LABELS)
        for label_name in extra_labels:
            print('deleting extra label %r to %r' % (label_name, repo))
            if args.delete_extra:
                repo.delete_label(label_name, *LABELS[label_name])


if __name__ == '__main__':
    main()
