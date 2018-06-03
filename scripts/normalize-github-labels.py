#!/usr/bin/env python3

import argparse
import os
import logging

from allib.logging import setup_logging
from github import Github

LABEL_COLORS = {
	# github defaults
	'bug': 'fc2929', # red
	'duplicate': 'cccccc', # grey
	'enhancement': '84b6eb', # light blue
	'invalid': 'e6e6e6', # grey
	'question': 'cc317c', # pink
	'wontfix': 'ffffff', # white

	# semi-official
	'help wanted': '0e8a16', # dark green
	'good first issue': 'c2e0c6', # light green

	# custom
	'wip': 'fbca04', # yellow
	'discussion': 'd4c5f9', # light purple
	'documentation': 'bfdadc', # light teal
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


def get_repos(user, whitelist=None):
	repo_dict = {}
	whitelist = set(normalize_whitelist(whitelist, user))

	def add_repo(repo, prefix):
		if repo.archived or not repo.has_issues:
			return
		key = '%s/%s' % (prefix, repo.name)
		if whitelist and key not in whitelist:
			return
		repo_dict[key] = repo

	def add_repos(repos, prefix):
		for repo in repos:
			add_repo(repo, prefix)

	add_repos(user.get_repos(), user.login)
	for org in user.get_orgs():
		add_repos(org.get_repos(), org.login)

	return repo_dict


def parse_args(args=None):
	parser = argparse.ArgumentParser()
	parser.add_argument('-t', '--token', default=os.getenv('GITHUB_TOKEN'))
	parser.add_argument('--fix-colors', action='store_true')
	parser.add_argument('--fix-missing', action='store_true')
	parser.add_argument('--delete-extra', action='store_true')
	parser.add_argument('-v', '--verbose', action='store_true')
	parser.add_argument('repo', nargs='*')
	return parser.parse_args(args)


def main():
	args = parse_args()
	setup_logging(log_level=logging.DEBUG if args.verbose else logging.WARNING)

	github = Github(args.token)
	user = github.get_user()
	repos = get_repos(user, args.repo)
	print('Checking repos:', ', '.join(repos))

	for repo in repos.values():
		repo_labels = set()
		for label in repo.get_labels():
			if label.name not in LABEL_COLORS:
				continue
			if label.color.lower() != LABEL_COLORS[label.name]:
				print('updating %r from #%s to #%s in %r' % (
					label, label.color, LABEL_COLORS[label.name], repo
				))
				if args.fix_colors:
					label.edit(
						name=label.name,
						color=LABEL_COLORS[label.name],
					)
			repo_labels.add(label.name)

		missing_labels = set(LABEL_COLORS) - repo_labels
		for label_name in missing_labels:
			print('adding missing label %r to %r' % (label_name, repo))
			if args.fix_missing:
				repo.create_label(label_name, LABEL_COLORS[label_name])

		extra_labels = repo_labels - set(LABEL_COLORS)
		for label_name in extra_labels:
			print('deleting extra label %r to %r' % (label_name, repo))
			if args.delete_extra:
				repo.delete_label(label_name, LABEL_COLORS[label_name])


if __name__ == '__main__':
	main()
