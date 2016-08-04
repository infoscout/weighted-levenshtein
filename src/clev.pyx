#!python
#cython: language_level=2, boundscheck=False, wraparound=False

from libc.stdlib cimport malloc, free

from clev cimport DTYPE_t, DTYPE_MAX, ALPHABET_SIZE


# Begin helper functions

# Begin Array2D

# Struct that represents a 2D array
ctypedef struct Array2D:
    DTYPE_t* mem
    Py_ssize_t num_rows
    Py_ssize_t num_cols


cdef inline void Array2D_init(
    Array2D* array2d,
    Py_ssize_t num_rows, 
    Py_ssize_t num_cols) nogil:
    """
    Initializes an Array2D struct with the given number of rows and columns
    """
    array2d.num_rows = num_rows
    array2d.num_cols = num_cols
    array2d.mem = <DTYPE_t*> malloc(num_rows * num_cols * sizeof(DTYPE_t))


cdef inline void Array2D_del(
    Array2D array2d) nogil:
    """
    Destroys an Array2D struct
    """
    free(array2d.mem)


cdef inline DTYPE_t Array2D_at_n1(
    Array2D array2d,
    Py_ssize_t row, 
    Py_ssize_t col) nogil:
    """
    Takes the row and column index of a (-1)-indexed matrix 
    and returns the value at that location
    """
    row += 1
    col += 1
    return array2d.mem[row * array2d.num_cols + col]


cdef inline void Array2D_set_n1(
    Array2D array2d, 
    Py_ssize_t row,   
    Py_ssize_t col, 
    DTYPE_t val) nogil:
    """
    Takes the row and column index of a (-1)-indexed matrix 
    and sets the value at that location
    """
    row += 1
    col += 1
    array2d.mem[row * array2d.num_cols + col] = val


cdef inline DTYPE_t Array2D_at_0(
    Array2D array2d,
    Py_ssize_t row,
    Py_ssize_t col) nogil:
    """
    Takes the row and column index of a 0-indexed matrix 
    and returns the value at that location
    """
    return array2d.mem[row * array2d.num_cols + col]


cdef inline void Array2D_set_0(
    Array2D array2d,
    Py_ssize_t row,
    Py_ssize_t col,
    DTYPE_t val) nogil:
    """
    Takes the row and column index of a 0-indexed matrix 
    and sets the value at that location
    """
    array2d.mem[row * array2d.num_cols + col] = val


cdef inline DTYPE_t col_delete_range_cost(
    Array2D d, 
    Py_ssize_t start,
    Py_ssize_t end) nogil:
    """
    Calculates the cost incurred by deleting
    characters 'start' to 'end' (inclusive) from 'str1',
    assuming that 'str1' is 1-indexed.

    Works since column 0 of 'd' is the cumulative sums 
    of the deletion costs of the characters in str1.

    This function computes the range sum by computing the difference 
    between the cumulative sums at each end of the range.
    """
    return Array2D_at_n1(d, end, 0) - Array2D_at_n1(d, start - 1, 0)


cdef inline DTYPE_t row_insert_range_cost(
    Array2D d, 
    Py_ssize_t start,
    Py_ssize_t end) nogil:
    """
    Calculates the cost incurred by inserting
    characters 'start' to 'end' (inclusive) from 'str2',
    assuming that 'str2' is 1-indexed.

    Works since row 0 of 'd' is the cumulative sums 
    of the insertion costs of the characters in str2.
    
    This function computes the range sum by computing the difference 
    between the cumulative sums at each end of the range.
    """
    return Array2D_at_n1(d, 0, end) - Array2D_at_n1(d, 0, start - 1)

# End Array2D


cdef inline unsigned char get_char_at_1(unsigned char* s, Py_ssize_t i) nogil:
    """
    Takes an index of a 1-indexed string
    and returns that character
    """
    return s[i - 1]

# End helper functions



def damerau_levenshtein(
    unsigned char* str1,
    unsigned char* str2,
    DTYPE_t[::1] insert_weights not None,
    DTYPE_t[::1] delete_weights not None,
    DTYPE_t[:,::1] substitute_weights not None,
    DTYPE_t[:,::1] transpose_weights not None):
    """
    Calculates the Damerau-Levenshtein distance between str1 and str2,
    provided the costs of inserting, deleting, substituting, and transposing characters

    :param str str1: first string
    :param str str2: second string
    :param DTYPE_t[::1] insert_weights: a memoryview of length ALPHABET_SIZE,
        where insert_weights[i] is the cost of inserting ASCII character i
    :param DTYPE_t[::1] delete_weights: a memoryview of length ALPHABET_SIZE,
        where delete_weights[i] is the cost of deleting ASCII character i
    :param DTYPE_t[:,::1] substitute_weights: a 2D memoryview of size (ALPHABET_SIZE, ALPHABET_SIZE),
        where substitute_weights[i, j] is the cost of substituting ASCII character i with 
        ASCII character j
    :param DTYPE_t[:,::1] transpose_weights: a 2D memoryview of size (ALPHABET_SIZE, ALPHABET_SIZE),
        where transpose_weights[i, j] is the cost of transposing ASCII character i with 
        ASCII character j, where character i is followed by character j in the string
    """
    return c_damerau_levenshtein(
        str1, len(str1),
        str2, len(str2),
        insert_weights,
        delete_weights,
        substitute_weights,
        transpose_weights
    )


cdef DTYPE_t c_damerau_levenshtein(
    unsigned char* str1, Py_ssize_t len1,
    unsigned char* str2, Py_ssize_t len2,
    DTYPE_t[::1] insert_weights,
    DTYPE_t[::1] delete_weights,
    DTYPE_t[:,::1] substitute_weights,
    DTYPE_t[:,::1] transpose_weights) nogil:
    """
    https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance#Distance_with_adjacent_transpositions
    """
    cdef:
        Py_ssize_t[ALPHABET_SIZE] da

        Py_ssize_t i, j
        unsigned char char_i, char_j
        DTYPE_t weight, cost, ret_val
        Py_ssize_t db, k, l

        Array2D d

    Array2D_init(&d, len1 + 2, len2 + 2)

    # initialize 'da' to all 0
    for i in range(ALPHABET_SIZE):
        da[i] = 0

    # fill row (-1) and column (-1) with 'DTYPE_MAX'
    Array2D_set_n1(d, -1, -1, DTYPE_MAX)
    for i in range(0, len1 + 1):
        Array2D_set_n1(d, i, -1, DTYPE_MAX)
    for j in range(0, len2 + 1):
        Array2D_set_n1(d, -1, j, DTYPE_MAX)

    # fill row 0 and column 0 with insertion and deletion costs
    Array2D_set_n1(d, 0, 0, 0)
    for i in range(1, len1 + 1):
        char_i = get_char_at_1(str1, i)
        weight = delete_weights[char_i]
        Array2D_set_n1(d, i, 0, Array2D_at_n1(d, i - 1, 0) + weight)
    for j in range(1, len2 + 1):
        char_j = get_char_at_1(str2, j)
        weight = insert_weights[char_j]
        Array2D_set_n1(d, 0, j, Array2D_at_n1(d, 0, j - 1) + weight)

    # fill DP array
    for i in range(1, len1 + 1):
        char_i = get_char_at_1(str1, i)

        db = 0
        for j in range(1, len2 + 1):
            char_j = get_char_at_1(str2, j)

            k = da[char_j]
            l = db
            if char_i == char_j:
                cost = 0
                db = j
            else:
                cost = substitute_weights[char_i, char_j]

            Array2D_set_n1(
                d, i, j, 
                min(
                    Array2D_at_n1(d, i - 1, j - 1) + cost,                  # equal/substitute
                    Array2D_at_n1(d, i, j - 1) + insert_weights[char_j],    # insert
                    Array2D_at_n1(d, i - 1, j) + delete_weights[char_i],    # delete
                    Array2D_at_n1(d, k - 1, l - 1) +                        # transpose
                        col_delete_range_cost(d, k + 1, i - 1) +                              # delete chars in between
                        transpose_weights[get_char_at_1(str1, k), get_char_at_1(str1, i)] +   # transpose chars
                        row_insert_range_cost(d, l + 1, j - 1)                                # insert chars in between
                )
            )

        da[char_i] = i

    ret_val = Array2D_at_n1(d, len1, len2)
    Array2D_del(d)
    return ret_val


def optimal_string_alignment(
    unsigned char* str1,
    unsigned char* str2,
    DTYPE_t[::1] insert_weights not None,
    DTYPE_t[::1] delete_weights not None,
    DTYPE_t[:,::1] substitute_weights not None,
    DTYPE_t[:,::1] transpose_weights not None):
    """
    Calculates the Optimal String Alignment distance between str1 and str2,
    provided the costs of inserting, deleting, and substituting characters

    :param str str1: first string
    :param str str2: second string
    :param DTYPE_t[::1] insert_weights: a memoryview of length ALPHABET_SIZE,
        where insert_weights[i] is the cost of inserting ASCII character i
    :param DTYPE_t[::1] delete_weights: a memoryview of length ALPHABET_SIZE,
        where delete_weights[i] is the cost of deleting ASCII character i
    :param DTYPE_t[:,::1] substitute_weights: a 2D memoryview of size (ALPHABET_SIZE, ALPHABET_SIZE),
        where substitute_weights[i, j] is the cost of substituting ASCII character i with 
        ASCII character j
    """
    return c_optimal_string_alignment(
        str1, len(str1),
        str2, len(str2),
        insert_weights,
        delete_weights,
        substitute_weights,
        transpose_weights
    )


cdef DTYPE_t c_optimal_string_alignment(
    unsigned char* str1, Py_ssize_t len1,
    unsigned char* str2, Py_ssize_t len2,
    DTYPE_t[::1] insert_weights,
    DTYPE_t[::1] delete_weights,
    DTYPE_t[:,::1] substitute_weights,
    DTYPE_t[:,::1] transpose_weights) nogil:
    """
    https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance#Optimal_string_alignment_distance
    """
    cdef:
        Py_ssize_t i, j
        unsigned char char_i, char_j, prev_char_i, prev_char_j
        DTYPE_t ret_val
        Array2D d

    Array2D_init(&d, len1 + 1, len2 + 1)

    # fill row 0 and column 0 with insertion and deletion costs
    Array2D_set_0(d, 0, 0, 0)
    for i in range(1, len1 + 1):
        char_i = get_char_at_1(str1, i)
        Array2D_set_0(d, i, 0, 
            Array2D_at_0(d, i - 1, 0) + delete_weights[char_i]
        )
    for j in range(1, len2 + 1):
        char_j = get_char_at_1(str2, j) 
        Array2D_set_0(d, 0, j,
            Array2D_at_0(d, 0, j - 1) + insert_weights[char_j]
        )

    # fill DP array
    for j in range(1, len2 + 1):
        char_j = get_char_at_1(str2, j)
        for i in range(1, len1 + 1):
            char_i = get_char_at_1(str1, i)
            if char_i == char_j:  # match
                Array2D_set_0(d, i, j,
                    Array2D_at_0(d, i - 1, j - 1)
                )
            else:
                Array2D_set_0(d, i, j,
                    min(
                        Array2D_at_0(d, i - 1, j) + delete_weights[char_i],  # deletion
                        Array2D_at_0(d, i, j - 1) + insert_weights[char_j],  # insertion
                        Array2D_at_0(d, i - 1, j - 1) + substitute_weights[char_i, char_j]  # substitution
                    )
                )

            if i > 1 and j > 1:
                prev_char_i = get_char_at_1(str1, i - 1)
                prev_char_j = get_char_at_1(str2, j - 1)
                if char_i == prev_char_j and prev_char_i == char_j:  # transpose
                    Array2D_set_0(d, i, j,
                        min(
                            Array2D_at_0(d, i, j),
                            Array2D_at_0(d, i - 2, j - 2) + transpose_weights[prev_char_i, char_i]
                        )
                    )

    ret_val = Array2D_at_0(d, len1, len2)
    Array2D_del(d)
    return ret_val






def levenshtein(
        unsigned char* str1,
        unsigned char* str2,
        DTYPE_t[::1] insert_weights not None,
        DTYPE_t[::1] delete_weights not None,
        DTYPE_t[:,::1] substitute_weights not None):

    return c_levenshtein(
        str1,
        len(str1),
        str2,
        len(str2),
        insert_weights,
        delete_weights,
        substitute_weights
    )


cdef DTYPE_t c_levenshtein(
        unsigned char* str1,
        Py_ssize_t len1,
        unsigned char* str2,
        Py_ssize_t len2,
        DTYPE_t[::1] insert_weights,
        DTYPE_t[::1] delete_weights,
        DTYPE_t[:,::1] substitute_weights) nogil:
    """
    https://en.wikipedia.org/wiki/Wagner%E2%80%93Fischer_algorithm
    """

    cdef Array2D d
    Array2D_init(&d, len1 + 1, len2 + 1)

    cdef Py_ssize_t i
    cdef Py_ssize_t j
    cdef unsigned char char_i
    cdef unsigned char char_j

    cdef DTYPE_t ret_val


    Array2D_set_0(d, 0, 0, 0)
    for i in range(1, len1 + 1):
        char_i = get_char_at_1(str1, i)
        Array2D_set_0(d, i, 0,
            Array2D_at_0(d, i - 1, 0) + delete_weights[char_i]
        )
    for j in range(1, len2 + 1):
        char_j = get_char_at_1(str2, j)
        Array2D_set_0(d, 0, j, 
            Array2D_at_0(d, 0, j - 1) + insert_weights[char_j]
        )


    for j in range(1, len2 + 1):
        char_j = get_char_at_1(str2, j)
        for i in range(1, len1 + 1):
            char_i = get_char_at_1(str1, i)
            if char_i == char_j:  # match
                Array2D_set_0(d, i, j,
                    Array2D_at_0(d, i - 1, j - 1)
                )
            else:
                Array2D_set_0(d, i, j, 
                    min(
                        Array2D_at_0(d, i - 1, j) + delete_weights[char_i],
                        Array2D_at_0(d, i, j - 1) + insert_weights[char_j],
                        Array2D_at_0(d, i - 1, j - 1) + substitute_weights[char_i, char_j]
                    )
                )

    ret_val = Array2D_at_0(d, len1, len2)
    Array2D_del(d)
    return ret_val

