import cocotb
from cocotb.triggers import Timer, ReadOnly

from sha256_models import w_new_model

def sb_fn(actual_value, expected_value):
    assert actual_value == expected_value, f"Mismatch: Expected {hex(expected_value)}, got {hex(actual_value)}"

@cocotb.test
async def test_w_new(dut):
    """Test w_new calculation"""
    test_vectors = [
        (0xFFFF_FFFF, 0x5555_5555, 0xAAAA_AAAA, 0x3333_3333),
        (0x0000_0000, 0x5555_5555, 0xAAAA_AAAA, 0x3333_3333),
        (0xFFFF_0000, 0x5555_5555, 0xAAAA_AAAA, 0x3333_3333)
    ]
    
    for w_14, w_1, w_0, w_9 in test_vectors:
        dut.w_14.value = w_14
        dut.w_1.value = w_1
        dut.w_0.value = w_0
        dut.w_9.value = w_9
        await ReadOnly()
        expected_value = w_new_model(w_14, w_1, w_0, w_9)
        sb_fn(dut.w_new.value.integer, expected_value)
        await Timer(1, units="ns")