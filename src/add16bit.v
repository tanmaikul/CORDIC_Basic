`timescale 1ns / 1ps
`default_nettype none

module add16bit (
    output wire [15:0] sum,
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire        sub
);

    assign sum = sub ? (a - b) : (a + b);

endmodule

