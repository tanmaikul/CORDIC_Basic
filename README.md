# CORDIC_Basic - 13-Stage Pipelined CORDIC for Tiny Tapeout (SKY130)

[![Test](https://github.com/tanmaikul/CORDIC_Basic/actions/workflows/test.yaml/badge.svg)](https://github.com/tanmaikul/CORDIC_Basic/actions/workflows/test.yaml)
[![GDS](https://github.com/tanmaikul/CORDIC_Basic/actions/workflows/gds.yaml/badge.svg)](https://github.com/tanmaikul/CORDIC_Basic/actions/workflows/gds.yaml)

A 13-stage fully pipelined CORDIC (Coordinate Rotation Digital Computer) engine designed for the **Tiny Tapeout SKY130** shuttle.

## Features
- **13-stage pipelined architecture**: Throughput of 1 calculation per clock cycle after an initial 13-cycle latency.
- **16-bit internal coordinate precision**: High-accuracy rotation and vectoring operations.
- **Dual Operating Modes**:
  - **Direct Mode (`uio_in[7] = 0`)**: Plug-and-play sin/cos generation using the Tiny Tapeout demo board switches (`ui_in`) and LEDs (`uo_out`).
  - **Register Mode (`uio_in[7] = 1`)**: Full byte-addressed access to all 16-bit $x_0$, $y_0$, and 15-bit $\theta_0$ registers and corresponding outputs.
- Fully compatible with `ttsky-verilog-template` and the SkyWater 130nm ASIC flow.

## Repository Structure
```
CORDIC_Basic/
├── .github/workflows/
│   ├── test.yaml               # Automated Cocotb test CI
│   └── gds.yaml                # Hardening / OpenLane GDS flow
├── docs/
│   └── info.md                 # Datasheet & technical documentation
├── src/
│   ├── project.v               # Top-level Tiny Tapeout wrapper (tt_um_tanmaikul_cordic)
│   ├── cordic_0_360_13stages.v # 13-stage pipelined CORDIC core
│   ├── reg16.v                 # 16-bit registered pipeline stage
│   └── add16bit.v              # 16-bit add/subtract unit
├── test/
│   ├── Makefile                # Cocotb simulation makefile
│   ├── tb.v                    # Verilog testbench wrapper
│   └── test.py                 # Cocotb Python tests
├── info.yaml                   # Tiny Tapeout project manifest
├── .gitignore
└── README.md
```

## How to Simulate
Prerequisites: Icarus Verilog (`iverilog`) and `cocotb`.

```bash
cd test
make
```

## License
Apache-2.0

