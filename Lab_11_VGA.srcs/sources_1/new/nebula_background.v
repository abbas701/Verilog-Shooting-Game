`timescale 1ns / 1ps

module nebula_background(
    input [9:0] pixel_x_r,
    input [9:0] pixel_y_r,
    output wire [11:0] nebula_rgb
);
    // Nebula center
    localparam CENTER_X = 320;
    localparam CENTER_Y = 240;
    
    // Calculate distance from center
    wire signed [10:0] dx = pixel_x_r - CENTER_X;
    wire signed [10:0] dy = pixel_y_r - CENTER_Y;
    wire [20:0] dist_sq = dx*dx + dy*dy;
    
    // Distance rings
    wire n00 = dist_sq <    225; wire n01 = dist_sq <    625; wire n02 = dist_sq <  1225;
    wire n03 = dist_sq <  2025; wire n04 = dist_sq <  3025; wire n05 = dist_sq <  4225;
    wire n06 = dist_sq <  5625; wire n07 = dist_sq <  7225; wire n08 = dist_sq <  9025;
    wire n09 = dist_sq < 11025; wire n10 = dist_sq < 13225; wire n11 = dist_sq < 15625;
    wire n12 = dist_sq < 18225; wire n13 = dist_sq < 21025; wire n14 = dist_sq < 24025;
    wire n15 = dist_sq < 27225; wire n16 = dist_sq < 30625; wire n17 = dist_sq < 34225;
    wire n18 = dist_sq < 38025; wire n19 = dist_sq < 42025; wire n20 = dist_sq < 46225;
    wire n21 = dist_sq < 50625; wire n22 = dist_sq < 55225; wire n23 = dist_sq < 60025;
    wire n24 = dist_sq < 65025; wire n25 = dist_sq < 70225; wire n26 = dist_sq < 75625;
    wire n27 = dist_sq < 81225; wire n28 = dist_sq < 87025; wire n29 = dist_sq < 93025;
    wire n30 = dist_sq < 99225;
    
    // Nebula color output
    reg [11:0] nebula_rgb_r;
    always @(*) begin
        if (n00)       nebula_rgb_r = 12'h40F;
        else if (n01)  nebula_rgb_r = 12'h40F;
        else if (n02)  nebula_rgb_r = 12'h40E;
        else if (n03)  nebula_rgb_r = 12'h40E;
        else if (n04)  nebula_rgb_r = 12'h30E;
        else if (n05)  nebula_rgb_r = 12'h30D;
        else if (n06)  nebula_rgb_r = 12'h30D;
        else if (n07)  nebula_rgb_r = 12'h30C;
        else if (n08)  nebula_rgb_r = 12'h30C;
        else if (n09)  nebula_rgb_r = 12'h20C;
        else if (n10)  nebula_rgb_r = 12'h20B;
        else if (n11)  nebula_rgb_r = 12'h20B;
        else if (n12)  nebula_rgb_r = 12'h20A;
        else if (n13)  nebula_rgb_r = 12'h20A;
        else if (n14)  nebula_rgb_r = 12'h209;
        else if (n15)  nebula_rgb_r = 12'h109;
        else if (n16)  nebula_rgb_r = 12'h108;
        else if (n17)  nebula_rgb_r = 12'h108;
        else if (n18)  nebula_rgb_r = 12'h107;
        else if (n19)  nebula_rgb_r = 12'h107;
        else if (n20)  nebula_rgb_r = 12'h106;
        else if (n21)  nebula_rgb_r = 12'h106;
        else if (n22)  nebula_rgb_r = 12'h105;
        else if (n23)  nebula_rgb_r = 12'h005;
        else if (n24)  nebula_rgb_r = 12'h004;
        else if (n25)  nebula_rgb_r = 12'h004;
        else if (n26)  nebula_rgb_r = 12'h003;
        else if (n27)  nebula_rgb_r = 12'h003;
        else if (n28)  nebula_rgb_r = 12'h002;
        else if (n29)  nebula_rgb_r = 12'h002;
        else if (n30)  nebula_rgb_r = 12'h001;
        else           nebula_rgb_r = 12'h000;
    end
    
    assign nebula_rgb = nebula_rgb_r;
    
endmodule
