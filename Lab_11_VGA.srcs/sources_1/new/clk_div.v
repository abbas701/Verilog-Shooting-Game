`timescale 1ns / 1ps
module clk_div(
    input clk,        // 100 MHz
    output clk_d      // 25 MHz clean
);
    reg [1:0] div = 0;
    always @(posedge clk) div <= div + 1;
    assign clk_d = div[1];   // Perfect 50% duty, no glitch, zero timing issues
endmodule