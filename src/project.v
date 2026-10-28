/*
 * Copyright (c) 2024 tanmaikul
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_tanmaikul_cordic (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output reg  [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, else 0
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire rst = ~rst_n;

    // Registers for user-programmable inputs (Mode 1)
    reg [15:0] reg_x0;
    reg [15:0] reg_y0;
    reg [14:0] reg_theta0;
    reg [13:0] valid_pipe;

    // Pin mappings
    wire       mode_reg = uio_in[7];    // 0 = Direct Sin/Cos mode, 1 = Full Register mode
    wire       we       = uio_in[6];    // Register write enable (in Register mode)
    wire [2:0] addr     = uio_in[5:3];  // Register address (in Register mode)
    wire [1:0] sel      = uio_in[2:1];  // Output component select (in Direct mode)

    // Scaling 8-bit signed angle to 15-bit signed angle:
    // Sign-extend ui_in[7] and shift left by 5 bits
    wire [14:0] direct_theta0 = {{2{ui_in[7]}}, ui_in, 5'b0};

    // Mode 0 uses hardwired CORDIC gain K * 2^14 = 9949 (16'h26DD)
    wire [15:0] cordic_x0     = mode_reg ? reg_x0 : 16'd9949;
    wire [15:0] cordic_y0     = mode_reg ? reg_y0 : 16'd0;
    wire [14:0] cordic_theta0 = mode_reg ? reg_theta0 : direct_theta0;

    // Register write logic & pipeline valid tracker
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_x0      <= 16'd9949;
            reg_y0      <= 16'd0;
            reg_theta0  <= 15'd0;
            valid_pipe  <= 14'd0;
        end else if (ena) begin
            valid_pipe <= {valid_pipe[12:0], 1'b1};

            if (mode_reg && we) begin
                case (addr)
                    3'd0: reg_x0[7:0]      <= ui_in;
                    3'd1: reg_x0[15:8]     <= ui_in;
                    3'd2: reg_y0[7:0]      <= ui_in;
                    3'd3: reg_y0[15:8]     <= ui_in;
                    3'd4: reg_theta0[7:0]  <= ui_in;
                    3'd5: reg_theta0[14:8] <= ui_in[6:0];
                    default: ;
                endcase
            end
        end
    end

    // 13-stage CORDIC engine instance
    wire [15:0] xout;
    wire [15:0] yout;
    wire [15:0] thetaout;

    cordic_0_360_13stages cordic_inst (
        .xout(xout),
        .yout(yout),
        .thetaout(thetaout),
        .x0(cordic_x0),
        .y0(cordic_y0),
        .theta0(cordic_theta0),
        .clk(clk),
        .rst(rst),
        .enable(ena)
    );

    // Output selection logic
    always @(*) begin
        if (!mode_reg) begin
            // Direct mode output component select:
            // 2'b00: Cosine High Byte (xout[15:8])
            // 2'b01: Cosine Low Byte  (xout[7:0])
            // 2'b10: Sine High Byte   (yout[15:8])
            // 2'b11: Sine Low Byte    (yout[7:0])
            case (sel)
                2'b00: uo_out = xout[15:8];
                2'b01: uo_out = xout[7:0];
                2'b10: uo_out = yout[15:8];
                2'b11: uo_out = yout[7:0];
            endcase
        end else begin
            // Register mode output read:
            case (addr)
                3'd0: uo_out = xout[7:0];
                3'd1: uo_out = xout[15:8];
                3'd2: uo_out = yout[7:0];
                3'd3: uo_out = yout[15:8];
                3'd4: uo_out = thetaout[7:0];
                3'd5: uo_out = thetaout[15:8];
                3'd6: uo_out = {7'b0, valid_pipe[13]};
                default: uo_out = 8'h00;
            endcase
        end
    end

    // Bidirectional IO configuration:
    // uio[0] is output: valid_pipe[13] (high when 13 stages have flushed)
    // uio[7:1] are inputs
    assign uio_oe  = 8'b0000_0001;
    assign uio_out = {7'b0, valid_pipe[13]};

    // Prevent unused warnings for unused inputs
    wire _unused = &{uio_in[0], 1'b0};

endmodule
