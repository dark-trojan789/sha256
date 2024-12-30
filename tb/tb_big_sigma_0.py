# test_S0.py
import cocotb
from cocotb.triggers import Timer, ReadOnly

from sha256_models import big_sigma0_model

@cocotb.test()
async def test_S0(dut):
    test_values = [0x0F0F_FFFF, 0xFFFF_0F0F, 0x0000_FFFF, 0xFFFF_0000]
    for value in test_values:
        dut.a.value = value
        await ReadOnly()
        expected = big_sigma0_model(value)
        assert dut.S0_val.value.integer == expected, f"Expected {hex(expected)}, got {hex(dut.S0_val.value.integer)}"
        await Timer(1, units="ns")