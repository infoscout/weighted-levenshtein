from distutils.core import setup
from Cython.Build import cythonize
import os

setup(
    name='clev',
    ext_modules=cythonize(os.path.join(os.path.dirname(__file__), "clev.pyx")),
)
