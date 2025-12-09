`timescale 1ns / 1ps
module top_level_vga(
    input clk,
    input up,      // ADD THESE 4 LINES
    input down,
    input left,
    input right,
    input up2, 
    input down2, 
    input left2, 
    input right2,
//    input btn_p1_fire,
//    input btn_p2_fire,
    output h_sync,
    output v_sync,
    output [3:0]red,
    output [3:0]green,
    output [3:0]blue
    );
   
    wire clk_d, video_on, trig_v;
    wire [9:0] h_count;
    wire [9:0] v_count;
    wire [9:0] x_loc;
    wire [9:0] y_loc;
   
    clk_div x1(.clk(clk), .clk_d(clk_d));
    h_counter x2(clk_d, trig_v, h_count);
    v_counter x5(clk_d, trig_v, v_count);
    vga_sync x3(h_count,v_count, h_sync, v_sync, video_on, x_loc, y_loc);
    pixel_gen x4(clk_d, video_on, x_loc, y_loc, up, down, left, right, up2, down2, left2, right2, red, green, blue);  // ADD the 4 joystick signals here
    
endmodule