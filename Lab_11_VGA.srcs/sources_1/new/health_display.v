`timescale 1ns / 1ps

module health_display(
    input clk,
    input frame_tick,
    input player1_hit,
    input player2_hit,
    input [7:0] powerup_health_p1,
    input [7:0] powerup_health_p2,
    input [9:0] pixel_x_r,
    input [9:0] pixel_y_r,
    output reg [7:0] player1_health,
    output reg [7:0] player2_health,
    output wire [11:0] health_rgb,
    output wire health_on
);
    // Health bar parameters
    localparam HEALTH_BAR_WIDTH = 120;
    localparam HEALTH_BAR_HEIGHT = 20;
    localparam HEALTH_BORDER = 2;
    localparam MARGIN_FROM_EDGE = 20;
    localparam HEALTH_Y = 20;
    localparam P1_HEALTH_X = MARGIN_FROM_EDGE;
    localparam P2_HEALTH_X = 640 - MARGIN_FROM_EDGE - HEALTH_BAR_WIDTH;
    
    // Initialize health
    initial begin
        player1_health = 100;
        player2_health = 100;
    end
    
    // Health modification logic
    always @(posedge clk) begin
        if (frame_tick) begin
            // Player 1 health changes
            if (player1_hit && player1_health > 0) begin
                player1_health <= player1_health - 1;
            end else if (powerup_health_p1 == 20) begin  // +20 health
                player1_health <= (player1_health <= 80) ? player1_health + 20 : 100;
            end else if (powerup_health_p1 == 8'd236) begin  // -20 health (236 = -20 in unsigned)
                player1_health <= (player1_health >= 20) ? player1_health - 20 : 0;
            end
            
            // Player 2 health changes
            if (player2_hit && player2_health > 0) begin
                player2_health <= player2_health - 1;
            end else if (powerup_health_p2 == 20) begin  // +20 health
                player2_health <= (player2_health <= 80) ? player2_health + 20 : 100;
            end else if (powerup_health_p2 == 8'd236) begin  // -20 health (236 = -20 in unsigned)
                player2_health <= (player2_health >= 20) ? player2_health - 20 : 0;
            end
        end
    end
    
    // Health bar calculations
    wire [9:0] p1_fill_width = (player1_health * HEALTH_BAR_WIDTH) / 100;
    wire [9:0] p2_fill_width = (player2_health * HEALTH_BAR_WIDTH) / 100;
    
    // Player 1 health bar detection
    wire p1_border = (pixel_x_r >= P1_HEALTH_X && pixel_x_r < P1_HEALTH_X + HEALTH_BAR_WIDTH &&
                      pixel_y_r >= HEALTH_Y && pixel_y_r < HEALTH_Y + HEALTH_BAR_HEIGHT);
    wire p1_inner  = (pixel_x_r >= P1_HEALTH_X + HEALTH_BORDER &&
                      pixel_x_r < P1_HEALTH_X + HEALTH_BAR_WIDTH - HEALTH_BORDER &&
                      pixel_y_r >= HEALTH_Y + HEALTH_BORDER &&
                      pixel_y_r < HEALTH_Y + HEALTH_BAR_HEIGHT - HEALTH_BORDER);
    wire p1_fill   = (pixel_x_r >= P1_HEALTH_X + HEALTH_BORDER &&
                      pixel_x_r < P1_HEALTH_X + HEALTH_BORDER + p1_fill_width &&
                      pixel_y_r >= HEALTH_Y + HEALTH_BORDER &&
                      pixel_y_r < HEALTH_Y + HEALTH_BAR_HEIGHT - HEALTH_BORDER);
    
    // Player 2 health bar detection
    wire p2_border = (pixel_x_r >= P2_HEALTH_X && pixel_x_r < P2_HEALTH_X + HEALTH_BAR_WIDTH &&
                      pixel_y_r >= HEALTH_Y && pixel_y_r < HEALTH_Y + HEALTH_BAR_HEIGHT);
    wire p2_inner  = (pixel_x_r >= P2_HEALTH_X + HEALTH_BORDER &&
                      pixel_x_r < P2_HEALTH_X + HEALTH_BAR_WIDTH - HEALTH_BORDER &&
                      pixel_y_r >= HEALTH_Y + HEALTH_BORDER &&
                      pixel_y_r < HEALTH_Y + HEALTH_BAR_HEIGHT - HEALTH_BORDER);
    wire p2_fill   = (pixel_x_r >= P2_HEALTH_X + HEALTH_BAR_WIDTH - HEALTH_BORDER - p2_fill_width &&
                      pixel_x_r < P2_HEALTH_X + HEALTH_BAR_WIDTH - HEALTH_BORDER &&
                      pixel_y_r >= HEALTH_Y + HEALTH_BORDER &&
                      pixel_y_r < HEALTH_Y + HEALTH_BAR_HEIGHT - HEALTH_BORDER);
    
    // Health level indicators
    wire p1_high = player1_health >= 60;
    wire p1_mid  = player1_health >= 30 && player1_health < 60;
    wire p1_low  = player1_health < 30;
    wire p2_high = player2_health >= 60;
    wire p2_mid  = player2_health >= 30 && player2_health < 60;
    wire p2_low  = player2_health < 30;
    
    // Text display parameters
    localparam P1_TEXT_X = P1_HEALTH_X + HEALTH_BAR_WIDTH + 8;
    localparam P2_TEXT_X = P2_HEALTH_X - 28;
    localparam TEXT_Y = HEALTH_Y + 6;
    
    // Digit rendering function
    function digit_pixel;
        input [3:0] digit;
        input [2:0] x, y;
        begin
            case(digit)
                4'd0: digit_pixel = ((y==0 || y==6) && x<=4) || ((x==0 || x==4) && y>=1 && y<=5);
                4'd1: digit_pixel = (x==2) || (y==6 && x<=4);
                4'd2: digit_pixel = (y==0 && x<=4) || (y==3 && x<=4) || (y==6 && x<=4) || (y==1 && x==4) || (y==2 && x==4) || (y==4 && x==0) || (y==5 && x==0);
                4'd3: digit_pixel = (y==0 && x<=4) || (y==3 && x<=4) || (y==6 && x<=4) || (x==4 && y>=1 && y<=5);
                4'd4: digit_pixel = (y==3 && x<=4) || (x==0 && y<=3) || (x==4 && y>=1);
                4'd5: digit_pixel = (y==0 && x<=4) || (y==3 && x<=4) || (y==6 && x<=4) || (y==1 && x==0) || (y==2 && x==0) || (y==4 && x==4) || (y==5 && x==4);
                4'd6: digit_pixel = (y==0 && x<=4) || (y==3 && x<=4) || (y==6 && x<=4) || (x==0 && y>=1) || (y==4 && x==4) || (y==5 && x==4);
                4'd7: digit_pixel = (y==0 && x<=4) || (x==4 && y>=1);
                4'd8: digit_pixel = (y==0 && x<=4) || (y==3 && x<=4) || (y==6 && x<=4) || (x==0 && y>=1 && y<=5) || (x==4 && y>=1 && y<=5);
                4'd9: digit_pixel = (y==0 && x<=4) || (y==3 && x<=4) || (x==4 && y>=1) || (x==0 && y==1) || (x==0 && y==2);
                default: digit_pixel = 0;
            endcase
        end
    endfunction
    
    // Calculate digits
    wire [3:0] p1_tens = player1_health / 10;
    wire [3:0] p1_ones = player1_health % 10;
    wire [3:0] p2_tens = player2_health / 10;
    wire [3:0] p2_ones = player2_health % 10;
    
    // Player 1 text rendering
    wire p1_in_text = (pixel_x_r >= P1_TEXT_X && pixel_x_r < P1_TEXT_X + 18 &&
                       pixel_y_r >= TEXT_Y && pixel_y_r < TEXT_Y + 7);
    wire [4:0] p1_tx = pixel_x_r - P1_TEXT_X;
    wire [2:0] p1_ty = pixel_y_r - TEXT_Y;
    wire p1_d1 = (p1_tx >= 0 && p1_tx <= 4) && digit_pixel(p1_tens, p1_tx[2:0], p1_ty);
    wire p1_d2 = (p1_tx >= 9 && p1_tx <= 13) && digit_pixel(p1_ones, p1_tx - 9, p1_ty);
    wire p1_text_on = p1_in_text && (p1_d1 || p1_d2);
    
    // Player 2 text rendering
    wire p2_in_text = (pixel_x_r >= P2_TEXT_X && pixel_x_r < P2_TEXT_X + 18 &&
                       pixel_y_r >= TEXT_Y && pixel_y_r < TEXT_Y + 7);
    wire [4:0] p2_tx = pixel_x_r - P2_TEXT_X;
    wire [2:0] p2_ty = pixel_y_r - TEXT_Y;
    wire p2_d1 = (p2_tx >= 0 && p2_tx <= 4) && digit_pixel(p2_tens, p2_tx[2:0], p2_ty);
    wire p2_d2 = (p2_tx >= 9 && p2_tx <= 13) && digit_pixel(p2_ones, p2_tx - 9, p2_ty);
    wire p2_text_on = p2_in_text && (p2_d1 || p2_d2);
    
    // Output signals
    assign health_on = p1_border || p1_inner || p1_fill || p2_border || p2_inner || p2_fill || p1_text_on || p2_text_on;
    
    // RGB output based on health bars and text
    reg [11:0] health_rgb_r;
    always @(*) begin
        if (p1_text_on || p2_text_on)
            health_rgb_r = 12'hFFE;
        else if (p1_border && !p1_inner)
            health_rgb_r = 12'h8EF;
        else if (p1_fill) begin
            if (p1_high)       health_rgb_r = 12'h3CF;
            else if (p1_mid)   health_rgb_r = 12'hFD4;
            else               health_rgb_r = 12'hF33;
        end
        else if (p1_inner)
            health_rgb_r = 12'h223;
        else if (p2_border && !p2_inner)
            health_rgb_r = 12'hF8F;
        else if (p2_fill) begin
            if (p2_high)       health_rgb_r = 12'hD4F;
            else if (p2_mid)   health_rgb_r = 12'hFD4;
            else               health_rgb_r = 12'hF33;
        end
        else if (p2_inner)
            health_rgb_r = 12'h223;
        else
            health_rgb_r = 12'h000;
    end
    
    assign health_rgb = health_rgb_r;
    
endmodule
