# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge


@cocotb.test()
async def test_cordic_direct_mode(dut):
    dut._log.info("Starting CORDIC Direct Mode test")

    # 10 MHz clock (100 ns period)
    clock = Clock(dut.clk, 100, unit="ns")
    cocotb.start_soon(clock.start())

    # Initialize inputs
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    # Reset DUT for 10 clock cycles
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # Test 1: Theta = 0 deg
    # In Direct Mode (uio_in[7] = 0):
    # ui_in = 0 -> theta = 0
    # Expected output:
    # Cosine = ~16384 (0x4000) -> High byte ~0x40, Low byte ~0x00
    # Sine   = 0       (0x0000) -> High byte ~0x00, Low byte ~0x00
    dut.ui_in.value = 0
    dut.uio_in.value = 0  # Mode=0, sel=00 (Cosine High byte)

    # Wait 15 cycles for 13-stage pipeline to propagate
    await ClockCycles(dut.clk, 15)

    # Check pipeline valid bit (uio_out[0])
    assert (int(dut.uio_out.value) & 1) == 1, "Pipeline valid bit should be set"

    # Read Cosine High Byte (sel = 2'b00 -> uio_in = 0b0000_0000)
    dut.uio_in.value = 0b0000_0000
    await ClockCycles(dut.clk, 1)
    cos_hi = int(dut.uo_out.value)
    dut._log.info(f"Theta=0: Cosine High Byte = 0x{cos_hi:02x}")
    # Full scale 16384 is 0x4000. Accept small CORDIC approximation variance (0x3F or 0x40)
    assert cos_hi in [0x3F, 0x40], f"Expected Cosine High Byte ~0x40, got 0x{cos_hi:02x}"

    # Read Sine High Byte (sel = 2'b10 -> uio_in = 0b0000_0100)
    dut.uio_in.value = 0b0000_0100
    await ClockCycles(dut.clk, 1)
    sin_hi = int(dut.uo_out.value)
    dut._log.info(f"Theta=0: Sine High Byte = 0x{sin_hi:02x}")
    assert sin_hi in [0x00, 0xFF], f"Expected Sine High Byte ~0x00, got 0x{sin_hi:02x}"

    dut._log.info("CORDIC direct mode test passed!")

