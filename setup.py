from distutils.core import setup
from distutils.extension import Extension

try:
    from Cython.Build import cythonize
except ImportError:
    extensions = [Extension("weighted_levenshtein.clev", ['weighted_levenshtein/clev.c'])]
else:
    extensions = cythonize([Extension("weighted_levenshtein.clev", ['weighted_levenshtein/clev.pyx'])])


setup(
    name='weighted_levenshtein',
    packages=['weighted_levenshtein'],  # this must be the same as the name above
    version='0.5',  # TODO reset this back to 0.1 for official pypi
    description='Library providing functions to calculate Levenshtein distance, Optimal String Alignment distance, '
                'and Damerau-Levenshtein distance, where the cost of each operation can be weighted by letter.',
    # long_description = 'Weighted Levenshtein distance library. The docs can be found at readthedocs.',
    author='David Su (InfoScout)',
    author_email='david.su@infoscoutinc.com',
    url='https://github.com/infoscout/weighted-levenshtein',  # use the URL to the github repo
    # download_url = 'https://github.com/peterldowns/mypackage/tarball/0.1', # I'll explain this in a second
    keywords=['Levenshtein', 'Damerau', 'weight', 'weighted'],  # arbitrary keywords
    classifiers=[],
    ext_modules=extensions,
    package_data={
        'weighted_levenshtein': ['clev.pxd']
    }
)
