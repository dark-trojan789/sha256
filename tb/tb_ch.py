# test_ch.py
import cocotb
from cocotb.triggers import Timer, ReadOnly

from sha256_models import ch_model

@cocotb.test()
async def test_ch(dut):
    test_vectors = [
        (0xFFFF_FFFF, 0x5555_5555, 0xAAAA_AAAA),
        (0x0000_0000, 0x5555_5555, 0xAAAA_AAAA),
        (0xFFFF_0000, 0x5555_5555, 0xAAAA_AAAA)
    ]
    
    for e, f, g in test_vectors:
        dut.e.value = e
        dut.f.value = f
        dut.g.value = g
        await ReadOnly()
        expected = ch_model(e, f, g)
        assert dut.ch_val.value.integer == expected, f"Expected {hex(expected)}, got {hex(dut.ch_val.value.integer)}"
        await Timer(1, units="ns")