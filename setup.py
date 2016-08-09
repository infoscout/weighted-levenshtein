from distutils.core import run_setup
import os

run_setup('weighted_levenshtein/setup.py', ['build_ext', '--inplace'])

