`timescale 1ns / 1ps

module jet_controller(
    input clk,
    input frame_tick,
    input joy1_up,
    input joy1_down,
    input joy1_left,
    input joy1_right,
    input joy2_up,
    input joy2_down,
    input joy2_left,
    input joy2_right,
    input [9:0] pixel_x_r,
    input [9:0] pixel_y_r,
    output reg [9:0] jet1_x,
    output reg [9:0] jet1_y,
    output reg [9:0] jet2_x,
    output reg [9:0] jet2_y,
    output wire jet1_on,
    output wire jet2_on
);
    // Jet parameters
    localparam JET_W = 50;
    localparam JET_H = 35;
    
    // Initial positions
    initial begin
        jet1_x = 10'd120;  // Player 1
        jet1_y = 10'd240;
        jet2_x = 10'd520;  // Player 2
        jet2_y = 10'd240;
    end
    
    // Jet movement logic
    always @(posedge clk) begin
        if (frame_tick) begin
            // Player 1 (Cyan) - facing right, nose stops at x=320
            if (joy1_left  && jet1_x > 10)                      jet1_x <= jet1_x - 5;
            if (joy1_right && (jet1_x + JET_W) < 320)           jet1_x <= jet1_x + 5;
            if (joy1_up    && jet1_y > 50)                      jet1_y <= jet1_y - 5;
            if (joy1_down  && jet1_y < (480 - JET_H))           jet1_y <= jet1_y + 5;
            
            // Player 2 (Orange) - facing left, nose stops at x=320
            if (joy2_left  && jet2_x > 320)                     jet2_x <= jet2_x - 5;
            if (joy2_right && (jet2_x + JET_W) < (640 - 10))    jet2_x <= jet2_x + 5;
            if (joy2_up    && jet2_y > 50)                      jet2_y <= jet2_y - 5;
            if (joy2_down  && jet2_y < (480 - JET_H))           jet2_y <= jet2_y + 5;
        end
    end
    
    // Jet rendering
    assign jet1_on = (pixel_x_r >= jet1_x && pixel_x_r < jet1_x + JET_W &&
                      pixel_y_r >= jet1_y && pixel_y_r < jet1_y + JET_H);
    assign jet2_on = (pixel_x_r >= jet2_x && pixel_x_r < jet2_x + JET_W &&
                      pixel_y_r >= jet2_y && pixel_y_r < jet2_y + JET_H);
    
endmodule
