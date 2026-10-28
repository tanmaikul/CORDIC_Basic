`timescale 1ns / 1ps
`default_nettype none

module reg16 (
    output reg  [15:0] dout,
    input  wire [15:0] din,
    input  wire        clk,
    input  wire        rst,
    input  wire        en
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dout <= 16'h0000;
        end else if (en) begin
            dout <= din;
        end
    end

endmodule

