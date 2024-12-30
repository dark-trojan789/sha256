# test_s1.py
import cocotb
from cocotb.triggers import Timer, ReadOnly, NextTimeStep

from sha256_models import small_sigma1_model

@cocotb.test()
async def test_s1(dut):
    test_values = [0x0F0F_FFFF, 0xFFFF_0F0F, 0x0000_FFFF, 0xFFFF_0000]
    for value in test_values:
        dut.w.value = value
        await ReadOnly()
        expected = small_sigma1_model(value)
        assert dut.s1_val.value.integer == expected, f"Expected {hex(expected)}, got {hex(dut.s1_val.value.integer)}"
        await Timer(1, units="ns")