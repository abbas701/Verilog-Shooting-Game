`timescale 1ns / 1ps

module bullet_system(
    input clk,
    input frame_tick,
    input [9:0] jet1_x,
    input [9:0] jet1_y,
    input [9:0] jet2_x,
    input [9:0] jet2_y,
    input [9:0] pixel_x_r,
    input [9:0] pixel_y_r,
    input btn_p1_fire,
    input btn_p2_fire,
    input shield1_active,
    input shield2_active,
    output reg player1_hit,
    output reg player2_hit,
    output wire bullet_on
);
    // Bullet parameters
    localparam BULLET_W = 10;
    localparam BULLET_H = 5;
    localparam BULLET_SPEED = 5;
    localparam JET_W = 50;
    localparam JET_H = 35;
    
    // Bullet states
    reg bullet1_active = 0;
    reg bullet2_active = 0;
    reg [9:0] bullet1_x = 0;
    reg [9:0] bullet1_y = 0;
    reg [9:0] bullet2_x = 0;
    reg [9:0] bullet2_y = 0;
    
    // Fire button edge detection
    reg btn_p1_fire_r = 0;
    reg btn_p2_fire_r = 0;
    wire p1_fire_edge = btn_p1_fire && !btn_p1_fire_r;
    wire p2_fire_edge = btn_p2_fire && !btn_p2_fire_r;
    
    always @(posedge clk) begin
        btn_p1_fire_r <= btn_p1_fire;
        btn_p2_fire_r <= btn_p2_fire;
    end
    
    // Bullet logic
    always @(posedge clk) begin
        if (frame_tick) begin
            player1_hit <= 0;
            player2_hit <= 0;
            
            // Player 1 bullet firing (fires right from nose)
            if (p1_fire_edge && !bullet1_active) begin
                bullet1_active <= 1;
                bullet1_x <= jet1_x + JET_W; // Start at jet nose (right edge)
                bullet1_y <= jet1_y + JET_H/2 - BULLET_H/2; // Center vertically
            end
            
            // Player 2 bullet firing (fires left from nose)
            if (p2_fire_edge && !bullet2_active) begin
                bullet2_active <= 1;
                bullet2_x <= jet2_x - BULLET_W; // Start at jet nose (left edge)
                bullet2_y <= jet2_y + JET_H/2 - BULLET_H/2; // Center vertically
            end
            
            // Player 1 bullet movement (moves right)
            if (bullet1_active) begin
                bullet1_x <= bullet1_x + BULLET_SPEED;
                
                // Check if bullet hits right boundary
                if (bullet1_x >= 640 - BULLET_W) begin
                    bullet1_active <= 0;
                end
                // Check collision with Player 2 jet (if not shielded)
                else if (!shield2_active &&
                         bullet1_x < jet2_x + JET_W &&
                         bullet1_x + BULLET_W > jet2_x &&
                         bullet1_y < jet2_y + JET_H &&
                         bullet1_y + BULLET_H > jet2_y) begin
                    bullet1_active <= 0;
                    player2_hit <= 1;
                end
            end
            
            // Player 2 bullet movement (moves left)
            if (bullet2_active) begin
                bullet2_x <= bullet2_x - BULLET_SPEED;
                
                // Check if bullet hits left boundary
                if (bullet2_x <= BULLET_SPEED) begin
                    bullet2_active <= 0;
                end
                // Check collision with Player 1 jet (if not shielded)
                else if (!shield1_active &&
                         bullet2_x < jet1_x + JET_W &&
                         bullet2_x + BULLET_W > jet1_x &&
                         bullet2_y < jet1_y + JET_H &&
                         bullet2_y + BULLET_H > jet1_y) begin
                    bullet2_active <= 0;
                    player1_hit <= 1;
                end
            end
        end
    end
    
    // Bullet rendering
    wire bullet1_on = bullet1_active &&
                      (pixel_x_r >= bullet1_x && pixel_x_r < bullet1_x + BULLET_W &&
                       pixel_y_r >= bullet1_y && pixel_y_r < bullet1_y + BULLET_H);
    
    wire bullet2_on = bullet2_active &&
                      (pixel_x_r >= bullet2_x && pixel_x_r < bullet2_x + BULLET_W &&
                       pixel_y_r >= bullet2_y && pixel_y_r < bullet2_y + BULLET_H);
    
    assign bullet_on = bullet1_on || bullet2_on;
    
endmodule
