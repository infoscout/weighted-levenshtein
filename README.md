# weighted-levenshtein

## Installation
`pip install weighted-levenshtein`

## Usage Example
```python
import numpy as np
from weighted_levenshtein import lev, osa, dam_lev

insert_costs = np.ones(128)  # make an array of all 1's
insert_costs[ord('D')] = 1.5  # make inserting the character 'D' have cost 1.5 (instead of 1)

print lev('BANANAS', 'BANDANAS', insert_costs=insert_costs)  # prints '1.5'
```

`lev`, `osa`, and `dam_lev` are aliases for `levenshtein`, `optimal_string_alignment`, and `damerau_levenshtein`, respectively.


## Detailed Documentation
TODO: ReadTheDocs link here

## Wikipedia links
Levenshtein distance: https://en.wikipedia.org/wiki/Levenshtein_distance and https://en.wikipedia.org/wiki/Wagner%E2%80%93Fischer_algorithm

Optimal String Alignment: https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance#Optimal_string_alignment_distance

Damerau-Levenshtein distance: https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance#Distance_with_adjacent_transpositions



## Compiling from Cython
First, clone this repo. Then, run the following commands:
```bash
cd weighted-levenshtein/weighted_levenshtein
./setup.sh
```
This will compile Cython code into a .so file that can be imported into Python.

## Distribution

Since not every machine has Cython installed, we distribute the C code that was compiled from Cython.
To compile to C, run `setup.sh` like above. Not only will it generate a .so file, it will also generate
the .c file that can be distributed, and compiled on any machine with a C compiler. 
Consequently, the distribution on PyPI contains only the .c file.
