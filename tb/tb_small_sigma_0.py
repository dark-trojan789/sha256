import cocotb
from cocotb.triggers import Timer, ReadOnly

from sha256_models import small_sigma0_model

def sb_fn(actual_value):
    global expected_value
    assert actual_value == expected_value, f"Not same value, Expected {bin(expected_value)}, got {bin(actual_value)}"

@cocotb.test
async def small_sigma_test(dut):
    global expected_value
    ip = 0x0F0F_FFFF
    X = dut.w
    X.value = ip
    await Timer(1, units="ns")
    await ReadOnly()
    actual_value = dut.s0_val.value.integer
    #print(output.integer)
    expected_value = small_sigma0_model(ip)
    sb_fn(actual_value)

@cocotb.test()
async def test_s1(dut):
    test_values = [0x0F0F_FFFF, 0xFFFF_0F0F, 0x0000_FFFF, 0xFFFF_0000]
    for value in test_values:
        dut.w.value = value
        await ReadOnly()
        expected = small_sigma0_model(value)
        assert dut.s0_val.value.integer == expected, f"Expected {hex(expected)}, got {hex(dut.s0_val.value.integer)}"
        await Timer(1, units="ns")
