# test_maj.py
import cocotb
from cocotb.triggers import Timer, ReadOnly

from sha256_models import maj_model

@cocotb.test()
async def test_maj(dut):
    test_vectors = [
        (0xFFFF_FFFF, 0x5555_5555, 0xAAAA_AAAA),
        (0x0000_0000, 0x5555_5555, 0xAAAA_AAAA),
        (0xFFFF_0000, 0x5555_5555, 0xAAAA_AAAA)
    ]
    
    for a, b, c in test_vectors:
        dut.a.value = a
        dut.b.value = b
        dut.c.value = c
        await ReadOnly()
        expected = maj_model(a, b, c)
        assert dut.maj_val.value.integer == expected, f"Expected {hex(expected)}, got {hex(dut.maj_val.value.integer)}"
        await Timer(1, units="ns")