from setuptools import setup, find_packages
from setuptools.extension import Extension

try:
    from Cython.Build import cythonize
except ImportError:
    extensions = [Extension("weighted_levenshtein.clev", ['weighted_levenshtein/clev.c'])]
else:
    extensions = cythonize([Extension("weighted_levenshtein.clev", ['weighted_levenshtein/clev.pyx'])])


with open('README.rst') as readme:
    long_description = readme.read()


setup(
    name='weighted_levenshtein',

    version='0.1',

    description='Library providing functions to calculate Levenshtein distance, Optimal String Alignment distance, '
                'and Damerau-Levenshtein distance, where the cost of each operation can be weighted by letter.',
    long_description=long_description,

    url='https://github.com/infoscout/weighted-levenshtein',

    author='David Su (InfoScout)',
    author_email='david.su@infoscoutinc.com',

    license='MIT',

    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: MIT License',
        'Operating System :: POSIX :: Linux',
        'Programming Language :: Cython',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Topic :: Text Processing :: Linguistic',
    ],

    keywords='Levenshtein Damerau weight weighted distance',

    packages=find_packages(exclude=('test', 'docs')),
    # packages=['weighted_levenshtein'],

    package_data={
        'weighted_levenshtein': ['clev.pxd', 'clev.pyx']
    },

    # download_url='https://github.com/peterldowns/mypackage/tarball/0.1', # I'll explain this in a second

    ext_modules=extensions,
)
