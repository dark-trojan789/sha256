def ror(n, rotations, width):
    return ((n >> rotations) | (n << (width - rotations))) & (2**width - 1)

def small_sigma0_model(num):
    return ror(num, 7, 32) ^ ror(num, 18, 32) ^ (num >> 3)

def small_sigma1_model(num):
    return ror(num, 17, 32) ^ ror(num, 19, 32) ^ (num >> 10)

def big_sigma0_model(num):
    return ror(num, 2, 32) ^ ror(num, 13, 32) ^ ror(num, 22, 32)

def big_sigma1_model(num):
    return ror(num, 6, 32) ^ ror(num, 11, 32) ^ ror(num, 25, 32)

def ch_model(e, f, g):
    return (e & f) ^ (~e & g)

def maj_model(a, b, c):
    return (a & b) ^ (a & c) ^ (b & c)

def w_new_model(w_14, w_1, w_0, w_9):
    s0 = small_sigma0_model(w_1)
    s1 = small_sigma1_model(w_14)
    return (w_0 + s0 + w_9 + s1) & 0xFFFFFFFF