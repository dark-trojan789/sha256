import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ReadOnly

def sb_fn(actual_value, expected_value):
    assert actual_value == expected_value, f"Mismatch: Expected {hex(expected_value)}, got {hex(actual_value)}"

@cocotb.test
async def sha256_test(dut):
     print(dir(dut))
     tc1 = 0x61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018
     expected_res1 = 0xBA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD

     dut.message.value = tc1
     dut.block = 1
    
     dut.rst.value = 1
     await Timer(5, 'ns')
     dut.rst.value = 0
     #await Timer(, 'ns') 

     await RisingEdge(dut.hash_valid)

     await ReadOnly()
     actual_val = dut.hash.value.integer
     #cocotb.log.info(f" {actual_val} ")
     await Timer(20, 'ns')
     sb_fn(actual_val, expected_res1)

@cocotb.test
async def sha256_test_2_blocks(dut):
    tc1 = 0x61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018
    #res1 = 0xBA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD;

    tc2 = 0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001C0
    res = 0x248D6A61D20638B8E5C026930C3E6039A33CE45964FF2167F6ECEDD419DB06C1

    dut.message.value = tc1
    dut.block.value = 2

    dut.rst.value = 1
    await Timer(5, 'ns')
    dut.rst.value = 0
    #await Timer(, 'ns') 

    await RisingEdge(dut.next_block_read_rdy)
    dut.message.value = tc2

    await RisingEdge(dut.hash_valid)

    await ReadOnly()
    actual_val = dut.hash.value.integer
    #cocotb.log.info(f" {actual_val} ")
    await Timer(20, 'ns')
    sb_fn(actual_val, res)
    #cocotb.log.info(f" {actual_val} ")
