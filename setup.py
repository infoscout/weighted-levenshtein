from setuptools import setup, find_packages
from setuptools.extension import Extension

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
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.5',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Topic :: Text Processing :: Linguistic',
    ],

    keywords='Levenshtein Damerau weight weighted distance',

    packages=find_packages(exclude=('test', 'docs')),

    package_data={
        'weighted_levenshtein': ['clev.pxd', 'clev.pyx']
    },
    
    setup_requires=[
        # Setuptools 18.0 properly handles Cython extensions.
        'setuptools>=18.0',
        'cython',
    ],    

    compiler_directives={
        'c_string_type': 'str',
        'c_string_encoding': 'utf8'    
    },

    ext_modules=[Extension("weighted_levenshtein.clev", ['weighted_levenshtein/clev.pyx'])],
)
