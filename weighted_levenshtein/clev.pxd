from libc.float cimport DBL_MAX as DTYPE_MAX

ctypedef double DTYPE_t

cdef enum:
    ALPHABET_SIZE = 512


cdef DTYPE_t c_damerau_levenshtein_unicode(
	unsigned int* word_m,
	Py_ssize_t len1,
	unsigned int* word_n,
	Py_ssize_t len2,
	DTYPE_t[::1] insert_costs,
	DTYPE_t[::1] delete_costs,
	DTYPE_t[:,::1] substitute_costs,
	DTYPE_t[:,::1] transpose_costs) nogil


cdef DTYPE_t c_optimal_string_alignment_unicode(
	unsigned int* word_m,
	Py_ssize_t len1,
	unsigned int* word_n,
	Py_ssize_t len2,
	DTYPE_t[::1] insert_costs,
	DTYPE_t[::1] delete_costs,
	DTYPE_t[:,::1] substitute_costs,
	DTYPE_t[:,::1] transpose_costs) nogil


cdef DTYPE_t c_levenshtein_unicode(
	unsigned int* word_m,
	Py_ssize_t len1,
	unsigned int* word_n,
	Py_ssize_t len2,
	DTYPE_t[::1] insert_costs,
	DTYPE_t[::1] delete_costs,
	DTYPE_t[:,::1] substitute_costs) nogil


cdef DTYPE_t c_damerau_levenshtein(
	unsigned char* str_a,
	Py_ssize_t len_a,
	unsigned char* str_b,
	Py_ssize_t len_b,
	DTYPE_t[::1] insert_costs,
	DTYPE_t[::1] delete_costs,
	DTYPE_t[:,::1] substitute_costs,
	DTYPE_t[:,::1] transpose_costs) nogil


cdef DTYPE_t c_optimal_string_alignment(
	unsigned char* word_m,
	Py_ssize_t m,
	unsigned char* word_n,
	Py_ssize_t n,
	DTYPE_t[::1] insert_costs,
	DTYPE_t[::1] delete_costs,
	DTYPE_t[:,::1] substitute_costs,
	DTYPE_t[:,::1] transpose_costs) nogil


cdef DTYPE_t c_levenshtein(
	unsigned char* word_m,
	Py_ssize_t m,
	unsigned char* word_n,
	Py_ssize_t n,
	DTYPE_t[::1] insert_costs,
	DTYPE_t[::1] delete_costs,
	DTYPE_t[:,::1] substitute_costs) nogil
