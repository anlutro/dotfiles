#!/usr/bin/env python

from distutils.core import setup
from setuptools import find_packages
import os
from os.path import abspath, dirname

# allow setup.py to be ran from anywhere
os.chdir(dirname(abspath(__file__)))

setup(
	name='example',
	version='1.0',
	license='MIT',
	description='TODO',
	long_description='TODO',
	author='Andreas Lutro',
	author_email='anlutro@gmail.com',
	url='https://github.com/anlutro/TODO',
	packages=find_packages(include=('example', 'example.*')),
	classifiers=[
		'Development Status :: 4 - Beta',
		'Intended Audience :: Developers',
		'Operating System :: POSIX',
		'Programming Language :: Python',
		'Programming Language :: Python :: 3.4',
		'Programming Language :: Python :: 3.5',
		'Programming Language :: Python :: 3.6',
		'Programming Language :: Python :: 3.7',
	],
	keywords=[],
)
