`timescale 1ns / 1ps

module star_background(
    input [9:0] pixel_x_r,
    input [9:0] pixel_y_r,
    output wire [11:0] star_rgb,
    output wire star_on
);
    // All star definitions (position-based detection)
    wire star1_center = (pixel_x_r == 100 && pixel_y_r == 50);
    wire star1 = (pixel_x_r >= 99 && pixel_x_r <= 101 && pixel_y_r >= 49 && pixel_y_r <= 51);
    wire star2_center = (pixel_x_r == 450 && pixel_y_r == 120);
    wire star2 = (pixel_x_r >= 449 && pixel_x_r <= 451 && pixel_y_r >= 119 && pixel_y_r <= 121);
    wire star3_center = (pixel_x_r == 280 && pixel_y_r == 200);
    wire star3 = (pixel_x_r >= 279 && pixel_x_r <= 281 && pixel_y_r >= 199 && pixel_y_r <= 201);
    wire star4_center = (pixel_x_r == 550 && pixel_y_r == 350);
    wire star4 = (pixel_x_r >= 549 && pixel_x_r <= 551 && pixel_y_r >= 349 && pixel_y_r <= 351);
    wire star5_center = (pixel_x_r == 150 && pixel_y_r == 380);
    wire star5 = (pixel_x_r >= 149 && pixel_x_r <= 151 && pixel_y_r >= 379 && pixel_y_r <= 381);
    wire star29_center = (pixel_x_r == 400 && pixel_y_r == 440);
    wire star29 = (pixel_x_r >= 399 && pixel_x_r <= 401 && pixel_y_r >= 439 && pixel_y_r <= 441);
    wire star30_center = (pixel_x_r == 70 && pixel_y_r == 240);
    wire star30 = (pixel_x_r >= 69 && pixel_x_r <= 71 && pixel_y_r >= 239 && pixel_y_r <= 241);
    wire star31_center = (pixel_x_r == 570 && pixel_y_r == 90);
    wire star31 = (pixel_x_r >= 569 && pixel_x_r <= 571 && pixel_y_r >= 89 && pixel_y_r <= 91);
    wire star32_center = (pixel_x_r == 200 && pixel_y_r == 400);
    wire star32 = (pixel_x_r >= 198 && pixel_x_r <= 202 && pixel_y_r >= 398 && pixel_y_r <= 402);
    wire star33_center = (pixel_x_r == 500 && pixel_y_r == 60);
    wire star33 = (pixel_x_r >= 498 && pixel_x_r <= 502 && pixel_y_r >= 58 && pixel_y_r <= 62);
    wire star6 = (pixel_x_r >= 200 && pixel_x_r <= 201 && pixel_y_r >= 80 && pixel_y_r <= 81);
    wire star7 = (pixel_x_r >= 380 && pixel_x_r <= 381 && pixel_y_r >= 250 && pixel_y_r <= 251);
    wire star8 = (pixel_x_r >= 90 && pixel_x_r <= 91 && pixel_y_r >= 300 && pixel_y_r <= 301);
    wire star9 = (pixel_x_r >= 500 && pixel_x_r <= 501 && pixel_y_r >= 180 && pixel_y_r <= 181);
    wire star10 = (pixel_x_r >= 320 && pixel_x_r <= 321 && pixel_y_r >= 420 && pixel_y_r <= 421);
    wire star11 = (pixel_x_r >= 180 && pixel_x_r <= 181 && pixel_y_r >= 150 && pixel_y_r <= 151);
    wire star12 = (pixel_x_r >= 420 && pixel_x_r <= 421 && pixel_y_r >= 400 && pixel_y_r <= 401);
    wire star34 = (pixel_x_r >= 130 && pixel_x_r <= 131 && pixel_y_r >= 100 && pixel_y_r <= 101);
    wire star35 = (pixel_x_r >= 340 && pixel_x_r <= 341 && pixel_y_r >= 380 && pixel_y_r <= 381);
    wire star36 = (pixel_x_r >= 480 && pixel_x_r <= 481 && pixel_y_r >= 300 && pixel_y_r <= 301);
    wire star41 = (pixel_x_r >= 290 && pixel_x_r <= 291 && pixel_y_r >= 110 && pixel_y_r <= 111);
    wire star13 = (pixel_x_r == 350 && pixel_y_r == 60);
    wire star14 = (pixel_x_r == 480 && pixel_y_r == 90);
    wire star15 = (pixel_x_r == 120 && pixel_y_r == 180);
    wire star16 = (pixel_x_r == 520 && pixel_y_r == 220);
    wire star17 = (pixel_x_r == 240 && pixel_y_r == 310);
    wire star18 = (pixel_x_r == 410 && pixel_y_r == 70);
    wire star19 = (pixel_x_r == 60 && pixel_y_r == 130);
    wire star20 = (pixel_x_r == 580 && pixel_y_r == 280);
    wire star21 = (pixel_x_r == 310 && pixel_y_r == 340);
    wire star22 = (pixel_x_r == 160 && pixel_y_r == 440);
    wire star23 = (pixel_x_r == 440 && pixel_y_r == 320);
    wire star24 = (pixel_x_r == 80 && pixel_y_r == 420);
    wire star25 = (pixel_x_r == 560 && pixel_y_r == 450);
    wire star26 = (pixel_x_r == 220 && pixel_y_r == 390);
    wire star27 = (pixel_x_r == 370 && pixel_y_r == 160);
    wire star28 = (pixel_x_r == 270 && pixel_y_r == 270);
    wire star37 = (pixel_x_r == 250 && pixel_y_r == 50);
    wire star38 = (pixel_x_r == 390 && pixel_y_r == 430);
    wire star39 = (pixel_x_r == 600 && pixel_y_r == 200);
    wire star40 = (pixel_x_r == 40 && pixel_y_r == 350);
    wire star42 = (pixel_x_r == 540 && pixel_y_r == 420);
    wire star43 = (pixel_x_r == 110 && pixel_y_r == 280);
    
    // Group stars by size
    wire large_star = star1 || star2 || star3 || star4 || star5 || star29 || star30 || star31;
    wire xlarge_star = star32 || star33;
    wire medium_star = star6 || star7 || star8 || star9 || star10 || star11 || star12 || star34 || star35 || star36 || star41;
    wire small_star = star13 || star14 || star15 || star16 || star17 || star18 || star19 || star20 || star21 || star22 || star23 || star24 || star25 || star26 || star27 || star28 || star37 || star38 || star39 || star40 || star42 || star43;
    wire star_bright_center = star1_center || star2_center || star3_center || star4_center || star5_center || star29_center || star30_center || star31_center || star32_center || star33_center;
    
    // Star detection
    assign star_on = star_bright_center || xlarge_star || large_star || medium_star || small_star || star3_center || star3 || star8 || star10 || star15 || star18 || star21 || star25 || star27;
    
    // Star coloring
    reg [11:0] star_rgb_r;
    always @(*) begin
        if (star_bright_center)         star_rgb_r = 12'hFFF;
        else if (xlarge_star)           star_rgb_r = 12'hFFE;
        else if (large_star)            star_rgb_r = 12'hEED;
        else if (medium_star)           star_rgb_r = 12'hDDE;
        else if (small_star)            star_rgb_r = 12'hAAB;
        else if (star3_center)          star_rgb_r = 12'h8CF;
        else if (star3)                 star_rgb_r = 12'h6AD;
        else if (star8)                 star_rgb_r = 12'hF83;
        else if (star10)                star_rgb_r = 12'hF7B;
        else if (star15)                star_rgb_r = 12'hB5E;
        else if (star18)                star_rgb_r = 12'h7BF;
        else if (star21)                star_rgb_r = 12'hF94;
        else if (star25)                star_rgb_r = 12'hE6A;
        else if (star27)                star_rgb_r = 12'hA4D;
        else                            star_rgb_r = 12'h000;
    end
    
    assign star_rgb = star_rgb_r;
    
endmodule
