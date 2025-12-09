`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 02:49:05 PM
// Design Name: 
// Module Name: h_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module h_counter(
    input clk,
    output  reg trig_v,
    output  reg [9:0] h_count

    );
    
    initial begin
        h_count = 0;
        trig_v = 0;
    end 
    
    always @(posedge clk) begin
        if (h_count == 799) begin
            h_count <= 0;
            trig_v  <= 1;               // ? THIS IS THE MISSING LINE
        end else begin
            h_count <= h_count + 1;
            trig_v  <= 0;
        end
    end
    
    
endmodule
