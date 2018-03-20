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


def get_repos(user):
	repo_dict = {}
	def add_repos(repos, prefix):
		for repo in repos:
			if not repo.has_issues:
				continue
			if repo.archived:
				continue
			key = '%s/%s' % (prefix, repo.name)
			repo_dict[key] = repo
	add_repos(user.get_repos(), user.login)
	for org in user.get_orgs():
		add_repos(org.get_repos(), org.login)
	return repo_dict


def parse_args(args=None):
	parser = argparse.ArgumentParser()
	parser.add_argument('-t', '--token', default=os.getenv('GITHUB_TOKEN'))
	parser.add_argument('--fix-colors', action='store_true')
	parser.add_argument('--fix-missing', action='store_true')
	parser.add_argument('-v', '--verbose', action='store_true')
	return parser.parse_args(args)


def main():
	args = parse_args()
	setup_logging(log_level=logging.DEBUG if args.verbose else logging.WARNING)

	github = Github(args.token)
	user = github.get_user()
	repos = get_repos(user)
	print('Checking repos:', ', '.join(repos))

	for repo in repos.values():
		repo_labels = set()
		for label in repo.get_labels():
			if label.name not in LABEL_COLORS:
				continue
			if label.color.lower() != LABEL_COLORS[label.name]:
				print('Updating %r %r from #%s to #%s' % (
					repo, label, label.color, LABEL_COLORS[label.name]
				))
				if args.fix_colors:
					label.edit(
						name=label.name,
						color=LABEL_COLORS[label.name],
					)
			repo_labels.add(label.name)
		missing_labels = repo_labels - set(LABEL_COLORS.keys())
		for label_name in missing_labels:
			print('%r missing %r, adding it' % (repo, label_name))
			if args.fix_missing:
				repo.create_label(label_name, LABEL_COLORS[label_name])


if __name__ == '__main__':
	main()
