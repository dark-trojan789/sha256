import cocotb
from cocotb.triggers import Timer, ReadOnly, NextTimeStep, RisingEdge

from sha256_models import w_new_model

def sb_fn(actual_value, expected_value):
    assert actual_value == expected_value, f"Mismatch: Expected {hex(expected_value)}, got {hex(actual_value)}"

@cocotb.test
async def test_w_generator(dut):
    """Test w generator"""
    # Reset
    dut.rst.value = 1
    await Timer(1, 'ns')
    dut.rst.value = 0
    await Timer(1, 'ns')  
    
    # Test message
    test_message = 0xFFFF_FFFF_5555_5555_AAAA_AAAA_3333_3333_FFFF_0000_5555_AAAA_FFFF_FFFF_0000_0000_FFFF_FFFF_5555_5555_AAAA_AAAA_3333_3333_FFFF_0000_5555_AAAA_FFFF_FFFF_4444_4444
    dut.message.value = test_message

    dut.start.value = 1
    await Timer(1, 'ns')  
    # dut.start.value = 0
    # await Timer(1, 'ns')  

    # Run for 64 cycles and check values
    w = [(test_message >> (480 - i*32)) & 0xFFFFFFFF for i in range(16)]
    
    for i in range(64):
        if i >= 16:
            w_t2 = w[i-2]
            w_t15 = w[i-15]
            w_t16 = w[i-16]
            w_t7 = w[i-7]
            new_w = w_new_model(w_t2, w_t15, w_t16, w_t7)
            w.append(new_w)        
            
        await ReadOnly()
        expected_value = w[i]
        cocotb.log.info(f"step {i} {hex(dut.w_i.value.integer)} {hex(w[i])}")
        sb_fn(dut.w_i.value.integer, expected_value)
        await RisingEdge(dut.clk)
        await NextTimeStep()