from distutils.core import setup
from Cython.Build import cythonize

setup(
    name='clev',
    ext_modules=cythonize("weighted_levenshtein/src/clev.pyx"),
)
