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

def sha256(preprocessed_chunks, num_chunks):
    """Implement the SHA-256 algorithm and print every step."""

    # Initial hash values (first 32 bits of the fractional parts of the square roots of the first 8 primes)
    h = [
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
        0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
    ]

    # Round constants (first 32 bits of the fractional parts of the cube roots of the first 64 primes)
    k = [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    ]

    for chunk_idx in range(num_chunks):
        chunk = preprocessed_chunks[chunk_idx]

        # Create the message schedule array w[0..63]
        w = [0] * 64
        for i in range(16):
            w[i] = int.from_bytes(chunk[i * 4:(i + 1) * 4], 'big')
        
        for i in range(16, 64):
            s0 = ror(w[i - 15], 7) ^ ror(w[i - 15], 18) ^ (w[i - 15] >> 3)
            s1 = ror(w[i - 2], 17) ^ ror(w[i - 2], 19) ^ (w[i - 2] >> 10)
            w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xFFFFFFFF

        print(f"Chunk {chunk_idx + 1}/{num_chunks}: Message schedule array w:")
        for i in range(64):
            print(f"w[{i:02}] = {w[i]:08x}")

        # Initialize working variables to the current hash value
        a, b, c, d, e, f, g, h_temp = h

        # Compression function main loop
        for i in range(64):
            S1 = ror(e, 6) ^ ror(e, 11) ^ ror(e, 25)
            ch = (e & f) ^ ((~e) & g)
            temp1 = (h_temp + S1 + ch + k[i] + w[i]) & 0xFFFFFFFF
            S0 = ror(a, 2) ^ ror(a, 13) ^ ror(a, 22)
            maj = (a & b) ^ (a & c) ^ (b & c)
            temp2 = (S0 + maj) & 0xFFFFFFFF

            h_temp = g
            g = f
            f = e
            e = (d + temp1) & 0xFFFFFFFF
            d = c
            c = b
            b = a
            a = (temp1 + temp2) & 0xFFFFFFFF

            print(f"Round {i:02}: a={a:08x}, b={b:08x}, c={c:08x}, d={d:08x}, e={e:08x}, f={f:08x}, g={g:08x}, h={h_temp:08x}")

        # Add the compressed chunk to the current hash value
        h[0] = (h[0] + a) & 0xFFFFFFFF
        h[1] = (h[1] + b) & 0xFFFFFFFF
        h[2] = (h[2] + c) & 0xFFFFFFFF
        h[3] = (h[3] + d) & 0xFFFFFFFF
        h[4] = (h[4] + e) & 0xFFFFFFFF
        h[5] = (h[5] + f) & 0xFFFFFFFF
        h[6] = (h[6] + g) & 0xFFFFFFFF
        h[7] = (h[7] + h_temp) & 0xFFFFFFFF

        print(f"Intermediate hash values after chunk {chunk_idx + 1}:")
        for i in range(8):
            print(f"h[{i}] = {h[i]:08x}")

    # Produce the final hash value (big-endian)
    digest = b''.join(h_i.to_bytes(4, 'big') for h_i in h)
    print(f"Final hash: {digest.hex()}")
    return digest