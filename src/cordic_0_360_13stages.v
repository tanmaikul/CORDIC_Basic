`timescale 1ns / 1ps
`default_nettype none

module cordic_0_360_13stages (
    output wire [15:0] xout,
    output wire [15:0] yout,
    output wire [15:0] thetaout,
    input  wire [15:0] x0,
    input  wire [15:0] y0,
    input  wire [14:0] theta0,
    input  wire        clk,
    input  wire        rst,
    input  wire        enable
);

    // 1st stage
    wire [15:0] x0out, y0out, theta0out;
    wire [15:0] x1, y1, theta1;

    reg16 reg11 (.dout(x0out), .din(x0), .clk(clk), .rst(rst), .en(enable));
    reg16 reg12 (.dout(y0out), .din(y0), .clk(clk), .rst(rst), .en(enable));
    reg16 reg13 (.dout(theta0out), .din({{2{theta0[14]}}, theta0[13:0]}), .clk(clk), .rst(rst), .en(enable));

    add16bit add11 (
        .sum(x1[15:0]),
        .a(x0out), 
        .b(y0out), 
        .sub(~theta0out[15])
    );
    add16bit add12 (
        .sum(y1[15:0]),
        .a(y0out), 
        .b(x0out),
        .sub(theta0out[15])
    );
    add16bit add13 (
        .sum(theta1[15:0]),
        .a(theta0out), 
        .b(16'b0010000000000000), 
        .sub(~theta0out[15])
    );

    // 2nd stage
    wire [15:0] x1out, y1out, theta1out;
    wire [15:0] x2, y2, theta2;

    reg16 reg21 (.dout(x1out), .din(x1), .clk(clk), .rst(rst), .en(enable));
    reg16 reg22 (.dout(y1out), .din(y1), .clk(clk), .rst(rst), .en(enable));
    reg16 reg23 (.dout(theta1out), .din(theta1), .clk(clk), .rst(rst), .en(enable));

    add16bit add21 (
        .sum(x2[15:0]),
        .a(x1out), 
        .b({y1out[15], y1out[15:1]}), 
        .sub(~theta1out[15])
    );
    add16bit add22 (
        .sum(y2[15:0]),
        .a(y1out), 
        .b({x1out[15], x1out[15:1]}), 
        .sub(theta1out[15])
    );
    add16bit add23 (
        .sum(theta2[15:0]),
        .a(theta1out),
        .b(16'b0001001011100100),
        .sub(~theta1out[15])
    );

    // 3rd stage
    wire [15:0] x2out, y2out, theta2out;
    wire [15:0] x3, y3, theta3;

    reg16 reg31 (.dout(x2out), .din(x2), .clk(clk), .rst(rst), .en(enable));
    reg16 reg32 (.dout(y2out), .din(y2), .clk(clk), .rst(rst), .en(enable));
    reg16 reg33 (.dout(theta2out), .din(theta2), .clk(clk), .rst(rst), .en(enable));

    add16bit add31 (
        .sum(x3[15:0]),
        .a(x2out), 
        .b({{2{y2out[15]}}, y2out[15:2]}), 
        .sub(~theta2out[15])
    );
    add16bit add32 (
        .sum(y3[15:0]),
        .a(y2out), 
        .b({{2{x2out[15]}}, x2out[15:2]}), 
        .sub(theta2out[15])
    );
    add16bit add33 (
        .sum(theta3[15:0]),
        .a(theta2out), 
        .b(16'b0000100111111011), 
        .sub(~theta2out[15])
    );

    // 4th stage
    wire [15:0] x3out, y3out, theta3out;
    wire [15:0] x4, y4, theta4;

    reg16 reg41 (.dout(x3out), .din(x3), .clk(clk), .rst(rst), .en(enable));
    reg16 reg42 (.dout(y3out), .din(y3), .clk(clk), .rst(rst), .en(enable));
    reg16 reg43 (.dout(theta3out), .din(theta3), .clk(clk), .rst(rst), .en(enable));

    add16bit add41 (
        .sum(x4[15:0]),
        .a(x3out), 
        .b({{3{y3out[15]}}, y3out[15:3]}), 
        .sub(~theta3out[15])
    );
    add16bit add42 (
        .sum(y4[15:0]),
        .a(y3out), 
        .b({{3{x3out[15]}}, x3out[15:3]}), 
        .sub(theta3out[15])
    );
    add16bit add43 (
        .sum(theta4[15:0]),
        .a(theta3out), 
        .b(16'b0000010100010001), 
        .sub(~theta3out[15])
    );

    // 5th stage
    wire [15:0] x4out, y4out, theta4out;
    wire [15:0] x5, y5, theta5;

    reg16 reg51 (.dout(x4out), .din(x4), .clk(clk), .rst(rst), .en(enable));
    reg16 reg52 (.dout(y4out), .din(y4), .clk(clk), .rst(rst), .en(enable));
    reg16 reg53 (.dout(theta4out), .din(theta4), .clk(clk), .rst(rst), .en(enable));

    add16bit add51 (
        .sum(x5[15:0]),
        .a(x4out), 
        .b({{4{y4out[15]}}, y4out[15:4]}), 
        .sub(~theta4out[15])
    );
    add16bit add52 (
        .sum(y5[15:0]),
        .a(y4out), 
        .b({{4{x4out[15]}}, x4out[15:4]}), 
        .sub(theta4out[15])
    );
    add16bit add53 (
        .sum(theta5[15:0]),
        .a(theta4out), 
        .b(16'b0000001010001011), 
        .sub(~theta4out[15])
    );

    // 6th stage
    wire [15:0] x5out, y5out, theta5out;
    wire [15:0] x6, y6, theta6;

    reg16 reg61 (.dout(x5out), .din(x5), .clk(clk), .rst(rst), .en(enable));
    reg16 reg62 (.dout(y5out), .din(y5), .clk(clk), .rst(rst), .en(enable));
    reg16 reg63 (.dout(theta5out), .din(theta5), .clk(clk), .rst(rst), .en(enable));

    add16bit add61 (
        .sum(x6[15:0]),
        .a(x5out), 
        .b({{5{y5out[15]}}, y5out[15:5]}), 
        .sub(~theta5out[15])
    );
    add16bit add62 (
        .sum(y6[15:0]),
        .a(y5out), 
        .b({{5{x5out[15]}}, x5out[15:5]}), 
        .sub(theta5out[15])
    );
    add16bit add63 (
        .sum(theta6[15:0]),
        .a(theta5out), 
        .b(16'b0000000101000110), 
        .sub(~theta5out[15])
    );

    // 7th stage
    wire [15:0] x6out, y6out, theta6out;
    wire [15:0] x7, y7, theta7;

    reg16 reg71 (.dout(x6out), .din(x6), .clk(clk), .rst(rst), .en(enable));
    reg16 reg72 (.dout(y6out), .din(y6), .clk(clk), .rst(rst), .en(enable));
    reg16 reg73 (.dout(theta6out), .din(theta6), .clk(clk), .rst(rst), .en(enable));

    add16bit add71 (
        .sum(x7[15:0]),
        .a(x6out), 
        .b({{6{y6out[15]}}, y6out[15:6]}), 
        .sub(~theta6out[15])
    );
    add16bit add72 (
        .sum(y7[15:0]),
        .a(y6out), 
        .b({{6{x6out[15]}}, x6out[15:6]}), 
        .sub(theta6out[15])
    );
    add16bit add73 (
        .sum(theta7[15:0]),
        .a(theta6out), 
        .b(16'b0000000010100011), 
        .sub(~theta6out[15])
    );

    // 8th stage
    wire [15:0] x7out, y7out, theta7out;
    wire [15:0] x8, y8, theta8;

    reg16 reg81 (.dout(x7out), .din(x7), .clk(clk), .rst(rst), .en(enable));
    reg16 reg82 (.dout(y7out), .din(y7), .clk(clk), .rst(rst), .en(enable));
    reg16 reg83 (.dout(theta7out), .din(theta7), .clk(clk), .rst(rst), .en(enable));

    add16bit add81 (
        .sum(x8[15:0]),
        .a(x7out), 
        .b({{7{y7out[15]}}, y7out[15:7]}), 
        .sub(~theta7out[15])
    );
    add16bit add82 (
        .sum(y8[15:0]),
        .a(y7out), 
        .b({{7{x7out[15]}}, x7out[15:7]}), 
        .sub(theta7out[15])
    );
    add16bit add83 (
        .sum(theta8[15:0]),
        .a(theta7out), 
        .b(16'b0000000001010001), 
        .sub(~theta7out[15])
    );

    // 9th stage
    wire [15:0] x8out, y8out, theta8out;
    wire [15:0] x9, y9, theta9;

    reg16 reg91 (.dout(x8out), .din(x8), .clk(clk), .rst(rst), .en(enable));
    reg16 reg92 (.dout(y8out), .din(y8), .clk(clk), .rst(rst), .en(enable));
    reg16 reg93 (.dout(theta8out), .din(theta8), .clk(clk), .rst(rst), .en(enable));

    add16bit add91 (
        .sum(x9[15:0]),
        .a(x8out), 
        .b({{8{y8out[15]}}, y8out[15:8]}), 
        .sub(~theta8out[15])
    );
    add16bit add92 (
        .sum(y9[15:0]),
        .a(y9out), 
        .b({{8{x8out[15]}}, x8out[15:8]}), 
        .sub(theta8out[15])
    );
    add16bit add93 (
        .sum(theta9[15:0]),
        .a(theta8out), 
        .b(16'b0000000000101001), 
        .sub(~theta8out[15])
    );

    // 10th stage
    wire [15:0] x9out, y9out, theta9out;
    wire [15:0] x10, y10, theta10;

    reg16 reg101 (.dout(x9out), .din(x9), .clk(clk), .rst(rst), .en(enable));
    reg16 reg102 (.dout(y9out), .din(y9), .clk(clk), .rst(rst), .en(enable));
    reg16 reg103 (.dout(theta9out), .din(theta9), .clk(clk), .rst(rst), .en(enable));

    add16bit add101 (
        .sum(x10[15:0]),
        .a(x9out), 
        .b({{9{y9out[15]}}, y9out[15:9]}), 
        .sub(~theta9out[15])
    );
    add16bit add102 (
        .sum(y10[15:0]),
        .a(y9out), 
        .b({{9{x9out[15]}}, x9out[15:9]}), 
        .sub(theta9out[15])
    );
    add16bit add103 (
        .sum(theta10[15:0]),
        .a(theta9out), 
        .b(16'b0000000000010100), 
        .sub(~theta9out[15])
    );

    // 11th stage
    wire [15:0] x10out, y10out, theta10out;
    wire [15:0] x11, y11, theta11;

    reg16 reg111 (.dout(x10out), .din(x10), .clk(clk), .rst(rst), .en(enable));
    reg16 reg112 (.dout(y10out), .din(y10), .clk(clk), .rst(rst), .en(enable));
    reg16 reg113 (.dout(theta10out), .din(theta10), .clk(clk), .rst(rst), .en(enable));

    add16bit add111 (
        .sum(x11[15:0]),
        .a(x10out), 
        .b({{10{y10out[15]}}, y10out[15:10]}), 
        .sub(~theta10out[15])
    );
    add16bit add112 (
        .sum(y11[15:0]),
        .a(y10out), 
        .b({{10{x10out[15]}}, x10out[15:10]}), 
        .sub(theta10out[15])
    );
    add16bit add113 (
        .sum(theta11[15:0]),
        .a(theta10out), 
        .b(16'b0000000000001010), 
        .sub(~theta10out[15])
    );

    // 12th stage
    wire [15:0] x11out, y11out, theta11out;
    wire [15:0] x12, y12, theta12;

    reg16 reg121 (.dout(x11out), .din(x11), .clk(clk), .rst(rst), .en(enable));
    reg16 reg122 (.dout(y11out), .din(y11), .clk(clk), .rst(rst), .en(enable));
    reg16 reg123 (.dout(theta11out), .din(theta11), .clk(clk), .rst(rst), .en(enable));

    add16bit add121 (
        .sum(x12[15:0]),
        .a(x11out), 
        .b({{11{y11out[15]}}, y11out[15:11]}), 
        .sub(~theta11out[15])
    );
    add16bit add122 (
        .sum(y12[15:0]),
        .a(y11out), 
        .b({{11{x11out[15]}}, x11out[15:11]}), 
        .sub(theta11out[15])
    );
    add16bit add123 (
        .sum(theta12[15:0]),
        .a(theta11out), 
        .b(16'b0000000000000101), 
        .sub(~theta11out[15])
    );

    // 13th stage
    wire [15:0] x12out, y12out, theta12out;

    reg16 reg131 (.dout(x12out), .din(x12), .clk(clk), .rst(rst), .en(enable));
    reg16 reg132 (.dout(y12out), .din(y12), .clk(clk), .rst(rst), .en(enable));
    reg16 reg133 (.dout(theta12out), .din(theta12), .clk(clk), .rst(rst), .en(enable));

    add16bit add131 (
        .sum(xout[15:0]),
        .a(x12out), 
        .b({{12{y12out[15]}}, y12out[15:12]}), 
        .sub(~theta12out[15])
    );
    add16bit add132 (
        .sum(yout[15:0]),
        .a(y12out), 
        .b({{12{x12out[15]}}, x12out[15:12]}), 
        .sub(theta12out[15])
    );
    add16bit add133 (
        .sum(thetaout[15:0]),
        .a(theta12out), 
        .b(16'b0000000000000011), 
        .sub(~theta12out[15])
    );

endmodule

