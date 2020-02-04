from libc.float cimport DBL_MAX as DTYPE_MAX

ctypedef double DTYPE_t

cdef enum:
    ALPHABET_SIZE = 512


cdef DTYPE_t c_damerau_levenshtein(
	int[:] str_a,
	int[:] str_b,
	DTYPE_t[::1] insert_costs,
	DTYPE_t[::1] delete_costs,
	DTYPE_t[:,::1] substitute_costs,
	DTYPE_t[:,::1] transpose_costs) nogil


cdef DTYPE_t c_optimal_string_alignment(
	int[:] word_m,
	int[:] word_n,
	DTYPE_t[::1] insert_costs,
	DTYPE_t[::1] delete_costs,
	DTYPE_t[:,::1] substitute_costs,
	DTYPE_t[:,::1] transpose_costs) nogil


cdef DTYPE_t c_levenshtein(
	int[:] word_m,
	int[:] word_n,
	DTYPE_t[::1] insert_costs,
	DTYPE_t[::1] delete_costs,
	DTYPE_t[:,::1] substitute_costs) nogil

