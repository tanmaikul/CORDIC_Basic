<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a **13-stage pipelined CORDIC (Coordinate Rotation Digital Computer)** engine in Verilog targeting SkyWater 130nm ASIC fabrication via Tiny Tapeout.

### Algorithm Principles
The CORDIC algorithm iteratively computes trigonometric vector rotation through successive shift-and-add stages:
$$x_{i+1} = x_i - d_i \cdot (y_i \gg i)$$
$$y_{i+1} = y_i + d_i \cdot (x_i \gg i)$$
$$z_{i+1} = z_i - d_i \cdot \alpha_i$$

where $d_i = \text{sign}(z_i)$ and $\alpha_i = \arctan(2^{-i})$.

After 13 pipelined stages, the engine produces rotated outputs $(x_{\text{out}}, y_{\text{out}}, \theta_{\text{out}})$ with 16-bit internal precision and a pipeline throughput of 1 result per clock cycle (with an initial latency of 13 clock cycles).

### Operating Modes

1. **Direct Mode (`uio_in[7] = 0`) — Plug-and-Play Sin/Cos Generation:**
   - Designed for easy testing using TT demo board DIP switches and LEDs.
   - Initial coordinate $x_0$ is automatically tied to the scaled CORDIC gain constant $K \approx 0.60725 \times 2^{14} = 9949$ (`16'h26DD`), and $y_0 = 0$.
   - The user inputs an 8-bit signed angle on `ui_in[7:0]` (scaled internally to 15-bit).
   - `uio_in[2:1]` selects the output component displayed on `uo_out[7:0]`:
     - `2'b00`: Cosine High Byte (`xout[15:8]`)
     - `2'b01`: Cosine Low Byte (`xout[7:0]`)
     - `2'b10`: Sine High Byte (`yout[15:8]`)
     - `2'b11`: Sine Low Byte (`yout[7:0]`)

2. **Register Mode (`uio_in[7] = 1`) — Full 16-bit Precision Vector Rotation:**
   - Allows setting arbitrary 16-bit $x_0$, $y_0$, and 15-bit $\theta_0$ via an address-indexed byte write.
   - `uio_in[6]` (`we`): Pulsed high to write the byte present on `ui_in[7:0]` into register `addr` (`uio_in[5:3]`).
   - `uio_in[5:3]` (`addr`):
     - `0`: `x0[7:0]` / read `xout[7:0]`
     - `1`: `x0[15:8]` / read `xout[15:8]`
     - `2`: `y0[7:0]` / read `yout[7:0]`
     - `3`: `y0[15:8]` / read `yout[15:8]`
     - `4`: `theta0[7:0]` / read `thetaout[7:0]`
     - `5`: `theta0[14:8]` / read `thetaout[15:8]`
     - `6`: Read status (`{7'b0, valid_pipe}`)

## How to test

1. Apply active-low reset: set `rst_n = 0` for at least 2 clock cycles, then release `rst_n = 1`.
2. Ensure `ena = 1`.
3. In Direct Mode (`uio_in[7] = 0`):
   - Set `ui_in = 8'h00` (Angle = $0^\circ$).
   - Wait 15 clock cycles. Pin `uio[0]` (`valid_out`) will go high.
   - Set `uio_in[2:1] = 2'b00` -> `uo_out` displays $\approx \text{0x40}$ ($\cos(0) = 1.0$).
   - Set `uio_in[2:1] = 2'b10` -> `uo_out` displays $\approx \text{0x00}$ ($\sin(0) = 0.0$).
4. Run automated tests with Cocotb:
   ```bash
   cd test
   make
   ```

## External hardware

- Tiny Tapeout standard demo board with 8 input switches (`ui_in`), 8 output LEDs (`uo_out`), and bidirectional headers (`uio`).
- Alternatively, connect an RP2040, Arduino, or FPGA to feed serial bytes in Register Mode.

