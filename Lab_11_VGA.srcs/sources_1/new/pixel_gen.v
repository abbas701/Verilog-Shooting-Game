`timescale 1ns / 1ps
module pixel_gen(
    input clk,
    input video_on,
    input [9:0] pixel_x,
    input [9:0] pixel_y,
    input up, down, left, right,        // Player 1 (JA)
    input up2, down2, left2, right2,    // Player 2
    // input btn_p1_fire,  // Player 1 fire button
    // input btn_p2_fire,  // Player 2 fire button
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue
);

    // ==================== PIPELINE (25 MHz domain) ====================
    reg video_on_r;
    reg [9:0] pixel_x_r, pixel_y_r;
    always @(posedge clk) begin
        video_on_r <= video_on;
        pixel_x_r  <= pixel_x;
        pixel_y_r  <= pixel_y;
    end

    // ==================== JOYSTICK SYNC (2-stage + invert) ====================
    reg up_r, up_r2, down_r, down_r2, left_r, left_r2, right_r, right_r2;
    reg up2_r, up2_r2, down2_r, down2_r2, left2_r, left2_r2, right2_r, right2_r2;
    always @(posedge clk) begin
        up_r <= up;      up_r2 <= up_r;
        down_r <= down; down_r2 <= down_r;
        left_r <= left; left_r2 <= left_r;
        right_r <= right; right_r2 <= right_r;

        up2_r <= up2;      up2_r2 <= up2_r;
        down2_r <= down2; down2_r2 <= down2_r;
        left2_r <= left2; left2_r2 <= left2_r;
        right2_r <= right2; right2_r2 <= right2_r;
    end

    wire joy1_up    = ~up_r2;
    wire joy1_down  = ~down_r2;
    wire joy1_left  = ~left_r2;
    wire joy1_right = ~right_r2;
    wire joy2_up    = ~up2_r2;
    wire joy2_down  = ~down2_r2;
    wire joy2_left  = ~left2_r2;
    wire joy2_right = ~right2_r2;

    // ==================== 60 FPS TICK ====================
    reg [18:0] frame_cnt = 0;
    reg frame_tick = 0;
    always @(posedge clk) begin
        if (frame_cnt == 19'd416665) begin
            frame_cnt <= 0;
            frame_tick <= 1;
        end else begin
            frame_cnt <= frame_cnt + 1;
            frame_tick <= 0;
        end
    end

    // ==================== JETS (TWO PLAYERS) ====================
    localparam JET_W = 50;
    localparam JET_H = 35;

    reg [9:0] jet1_x = 10'd120;  // Player 1
    reg [9:0] jet1_y = 10'd240;
    reg [9:0] jet2_x = 10'd520;  // Player 2
    reg [9:0] jet2_y = 10'd240;

    // Movement + Center Wall (x=320)
    // ==================== JETS MOVEMENT - MIRROR ARENA (NOSE STOPS AT x=320) ====================
    always @(posedge clk) if (frame_tick) begin
        // Player 1 (Cyan) - facing right ? RIGHT edge (nose) stops at x=320
        if (joy1_left  && jet1_x > 10)                                 jet1_x <= jet1_x - 5;
        if (joy1_right && (jet1_x + JET_W) < 320)                      jet1_x <= jet1_x + 5;  // Nose stops at 320
        if (joy1_up    && jet1_y > 50)                                 jet1_y <= jet1_y - 5;
        if (joy1_down  && jet1_y < (480 - JET_H))                      jet1_y <= jet1_y + 5;

        // Player 2 (Orange) - facing left ? LEFT edge (nose) stops at x=320
        if (joy2_left  && jet2_x > 320)                                jet2_x <= jet2_x - 5;  // Nose stops at 320
        if (joy2_right && (jet2_x + JET_W) < (640 - 10))               jet2_x <= jet2_x + 5;
        if (joy2_up    && jet2_y > 50)                                 jet2_y <= jet2_y - 5;
        if (joy2_down  && jet2_y < (480 - JET_H))                      jet2_y <= jet2_y + 5;
    end

    wire jet1_on = (pixel_x_r >= jet1_x && pixel_x_r < jet1_x + JET_W &&
                     pixel_y_r >= jet1_y && pixel_y_r < jet1_y + JET_H);
    wire jet2_on = (pixel_x_r >= jet2_x && pixel_x_r < jet2_x + JET_W &&
                     pixel_y_r >= jet2_y && pixel_y_r < jet2_y + JET_H);


    // ==================== ALL STARS (fully pipelined - glitch-free) ====================
    // ... (All star logic remains unchanged, omitted for brevity)
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

    wire large_star = star1 || star2 || star3 || star4 || star5 || star29 || star30 || star31;
    wire xlarge_star = star32 || star33;
    wire medium_star = star6 || star7 || star8 || star9 || star10 || star11 || star12 || star34 || star35 || star36 || star41;
    wire small_star = star13 || star14 || star15 || star16 || star17 || star18 || star19 || star20 || star21 || star22 || star23 || star24 || star25 || star26 || star27 || star28 || star37 || star38 || star39 || star40 || star42 || star43;
    wire star_bright_center = star1_center || star2_center || star3_center || star4_center || star5_center || star29_center || star30_center || star31_center || star32_center || star33_center;


    // ==================== HEALTH BARS + TEXT ====================
    localparam HEALTH_BAR_WIDTH = 120, HEALTH_BAR_HEIGHT = 20, HEALTH_BORDER = 2;
    localparam MARGIN_FROM_EDGE = 20, HEALTH_Y = 20;
    localparam P1_HEALTH_X = MARGIN_FROM_EDGE;
    localparam P2_HEALTH_X = 640 - MARGIN_FROM_EDGE - HEALTH_BAR_WIDTH;

    reg [7:0] player1_health = 100;
    reg [7:0] player2_health = 100;

    // ... (Health bar display logic, omitted for brevity)
    wire [9:0] p1_fill_width = (player1_health * HEALTH_BAR_WIDTH) / 100;
    wire [9:0] p2_fill_width = (player2_health * HEALTH_BAR_WIDTH) / 100;

    wire p1_border = (pixel_x_r >= P1_HEALTH_X && pixel_x_r < P1_HEALTH_X + HEALTH_BAR_WIDTH && pixel_y_r >= HEALTH_Y && pixel_y_r < HEALTH_Y + HEALTH_BAR_HEIGHT);
    wire p1_inner  = (pixel_x_r >= P1_HEALTH_X + HEALTH_BORDER && pixel_x_r < P1_HEALTH_X + HEALTH_BAR_WIDTH - HEALTH_BORDER && pixel_y_r >= HEALTH_Y + HEALTH_BORDER && pixel_y_r < HEALTH_Y + HEALTH_BAR_HEIGHT - HEALTH_BORDER);
    wire p1_fill   = (pixel_x_r >= P1_HEALTH_X + HEALTH_BORDER && pixel_x_r < P1_HEALTH_X + HEALTH_BORDER + p1_fill_width && pixel_y_r >= HEALTH_Y + HEALTH_BORDER && pixel_y_r < HEALTH_Y + HEALTH_BAR_HEIGHT - HEALTH_BORDER);

    wire p2_border = (pixel_x_r >= P2_HEALTH_X && pixel_x_r < P2_HEALTH_X + HEALTH_BAR_WIDTH && pixel_y_r >= HEALTH_Y && pixel_y_r < HEALTH_Y + HEALTH_BAR_HEIGHT);
    wire p2_inner  = (pixel_x_r >= P2_HEALTH_X + HEALTH_BORDER && pixel_x_r < P2_HEALTH_X + HEALTH_BAR_WIDTH - HEALTH_BORDER && pixel_y_r >= HEALTH_Y + HEALTH_BORDER && pixel_y_r < HEALTH_Y + HEALTH_BAR_HEIGHT - HEALTH_BORDER);
    wire p2_fill   = (pixel_x_r >= P2_HEALTH_X + HEALTH_BAR_WIDTH - HEALTH_BORDER - p2_fill_width && pixel_x_r < P2_HEALTH_X + HEALTH_BAR_WIDTH - HEALTH_BORDER && pixel_y_r >= HEALTH_Y + HEALTH_BORDER && pixel_y_r < HEALTH_Y + HEALTH_BAR_HEIGHT - HEALTH_BORDER);

    wire p1_high = player1_health >= 60;
    wire p1_mid  = player1_health >= 30 && player1_health < 60;
    wire p1_low  = player1_health < 30;
    wire p2_high = player2_health >= 60;
    wire p2_mid  = player2_health >= 30 && player2_health < 60;
    wire p2_low  = player2_health < 30;

    localparam P1_TEXT_X = P1_HEALTH_X + HEALTH_BAR_WIDTH + 8;
    localparam P2_TEXT_X = P2_HEALTH_X - 28;
    localparam TEXT_Y = HEALTH_Y + 6;

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

    wire [3:0] p1_tens = player1_health / 10;
    wire [3:0] p1_ones = player1_health % 10;
    wire [3:0] p2_tens = player2_health / 10;
    wire [3:0] p2_ones = player2_health % 10;

    wire p1_in_text = (pixel_x_r >= P1_TEXT_X && pixel_x_r < P1_TEXT_X + 18 && pixel_y_r >= TEXT_Y && pixel_y_r < TEXT_Y + 7);
    wire [4:0] p1_tx = pixel_x_r - P1_TEXT_X;
    wire [2:0] p1_ty = pixel_y_r - TEXT_Y;
    wire p1_d1 = (p1_tx >= 0 && p1_tx <= 4) && digit_pixel(p1_tens, p1_tx[2:0], p1_ty);
    wire p1_d2 = (p1_tx >= 9 && p1_tx <= 13) && digit_pixel(p1_ones, p1_tx - 9, p1_ty);
    wire p1_text_on = p1_in_text && (p1_d1 || p1_d2);

    wire p2_in_text = (pixel_x_r >= P2_TEXT_X && pixel_x_r < P2_TEXT_X + 18 && pixel_y_r >= TEXT_Y && pixel_y_r < TEXT_Y + 7);
    wire [4:0] p2_tx = pixel_x_r - P2_TEXT_X;
    wire [2:0] p2_ty = pixel_y_r - TEXT_Y;
    wire p2_d1 = (p2_tx >= 0 && p2_tx <= 4) && digit_pixel(p2_tens, p2_tx[2:0], p2_ty);
    wire p2_d2 = (p2_tx >= 9 && p2_tx <= 13) && digit_pixel(p2_ones, p2_tx - 9, p2_ty);
    wire p2_text_on = p2_in_text && (p2_d1 || p2_d2);

    // ==================== TIMER (30 seconds) ====================
    reg [26:0] timer_cnt = 0;
    reg [5:0] timer_sec = 30;
    reg timer_done = 0;
    always @(posedge clk) begin
        if (timer_cnt == 27'd99_999_999) begin
            timer_cnt <= 0;
            if (timer_sec != 0) timer_sec <= timer_sec - 1;
            if (timer_sec == 1) timer_done <= 1;
        end else timer_cnt <= timer_cnt + 1;
    end

    localparam signed [10:0] TIMER_X = 297, TIMER_Y = 15;
    wire signed [10:0] tx = $signed({1'b0,pixel_x_r}) - TIMER_X;
    wire signed [10:0] ty = $signed({1'b0,pixel_y_r}) - TIMER_Y;
    wire [3:0] tens_digit = timer_sec / 10;
    wire [3:0] ones_digit = timer_sec % 10;

    reg [6:0] seg_tens, seg_ones;
    always @(*) begin
        case(tens_digit) 0:seg_tens=7'b1111110; 1:seg_tens=7'b0110000; 2:seg_tens=7'b1101101; 3:seg_tens=7'b1111001;
                             4:seg_tens=7'b0110011; 5:seg_tens=7'b1011011; 6:seg_tens=7'b1011111; 7:seg_tens=7'b1110000;
                             8:seg_tens=7'b1111111; 9:seg_tens=7'b1111011; default:seg_tens=7'b0000000; endcase
        case(ones_digit) 0:seg_ones=7'b1111110; 1:seg_ones=7'b0110000; 2:seg_ones=7'b1101101; 3:seg_ones=7'b1111001;
                             4:seg_ones=7'b0110011; 5:seg_ones=7'b1011011; 6:seg_ones=7'b1011111; 7:seg_ones=7'b1110000;
                             8:seg_ones=7'b1111111; 9:seg_ones=7'b1111011; default:seg_ones=7'b0000000; endcase
    end

    wire draw_tens = (tx >= 0 && tx < 20) && (ty >= 0 && ty < 40) && (
        (seg_tens[6] && ty>= 2 && ty<= 5 && tx>= 4 && tx<16) ||
        (seg_tens[5] && tx>=15 && tx<=18 && ty>= 6 && ty<20) ||
        (seg_tens[4] && tx>=15 && tx<=18 && ty>=21 && ty<35) ||
        (seg_tens[3] && ty>=35 && ty<=38 && tx>= 4 && tx<16) ||
        (seg_tens[2] && tx>= 1 && tx<= 4 && ty>=21 && ty<35) ||
        (seg_tens[1] && tx>= 1 && tx<= 4 && ty>= 6 && ty<20) ||
        (seg_tens[0] && ty>=19 && ty<=21 && tx>= 4 && tx<16));

    wire signed [10:0] tx_ones = tx - 26;
    wire draw_ones = (tx >= 26 && tx < 46) && (ty >= 0 && ty < 40) && (
        (seg_ones[6] && ty>= 2 && ty<= 5 && tx_ones>= 4 && tx_ones<16) ||
        (seg_ones[5] && tx_ones>=15 && tx_ones<=18 && ty>= 6 && ty<20) ||
        (seg_ones[4] && tx_ones>=15 && tx_ones<=18 && ty>=21 && ty<35) ||
        (seg_ones[3] && ty>=35 && ty<=38 && tx_ones>= 4 && tx_ones<16) ||
        (seg_ones[2] && tx_ones>= 1 && tx_ones<= 4 && ty>=21 && ty<35) ||
        (seg_ones[1] && tx_ones>= 1 && tx_ones<= 4 && ty>= 6 && ty<20) ||
        (seg_ones[0] && ty>=19 && ty<=21 && tx_ones>= 4 && tx_ones<16));

    wire timer_on = draw_tens || draw_ones;

    // ==================== SHIELD LOGIC ====================
    reg shield1_active = 0;
    reg shield2_active = 0;
    reg [8:0] shield1_frames_left = 0;
    reg [8:0] shield2_frames_left = 0;
    localparam SHIELD_DURATION = 300; // 5 seconds * 60 fps = 300 frames

    always @(posedge clk) begin
        if (frame_tick) begin
            // Player 1 Shield Countdown
            if (shield1_active && shield1_frames_left != 0) begin
                shield1_frames_left <= shield1_frames_left - 1;
                if (shield1_frames_left == 1) shield1_active <= 0;
            end
            // Player 2 Shield Countdown
            if (shield2_active && shield2_frames_left != 0) begin
                shield2_frames_left <= shield2_frames_left - 1;
                if (shield2_frames_left == 1) shield2_active <= 0;
            end
        end
        // Reset on game over
        if (timer_done) begin
             shield1_active <= 0;
             shield2_active <= 0;
        end
    end


    // ==================== LFSR FOR RANDOMNESS ====================
    reg [15:0] lfsr = 16'hACE1;
    always @(posedge clk) if (frame_tick)
        lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};

    // ==================== MYSTERY POWER-UP SYSTEM ====================
    localparam PU_SIZE = 30;
    localparam TOTAL_POWERUPS = 10;
    localparam PLUS = 2'd0;
    localparam MINUS = 2'd1;
    localparam SHIELD = 2'd2;

    reg powerup_active = 0;
    reg powerup_collected = 0;
    reg [9:0] powerup_x = 10'd100;
    reg [9:0] powerup_y = 10'd240;
    reg [8:0] pu_frames_left = 0;      // 5 seconds visible if not collected (300 frames)
    reg [8:0] reveal_frames = 0;       // Show icon for 1 second after collection (60 frames)
    reg [5:0] last_trigger_sec = 31;
    reg [1:0] powerup_type;            // 0 = +, 1 = -, 2 = shield
    reg collected_by_p1 = 0;           // Tracks which player collected the powerup
    reg [3:0] p1_powerup_count = 0;    // Total power-ups collected by P1
    reg [3:0] p2_powerup_count = 0;    // Total power-ups collected by P2

    // --- NEW: Initial guaranteed power-up tracking (0=None, 1=+, 2=-, 3=Shield)
    reg [2:0] p1_pu_init_mask = 3'b111; // Bit 0: +, Bit 1: -, Bit 2: Shield
    reg [2:0] p2_pu_init_mask = 3'b111;

    // --- Object-level collision detection wires ---
    wire jet1_pu_collision = (jet1_x < powerup_x + PU_SIZE && jet1_x + JET_W > powerup_x &&
                              jet1_y < powerup_y + PU_SIZE && jet1_y + JET_H > powerup_y);
    wire jet2_pu_collision = (jet2_x < powerup_x + PU_SIZE && jet2_x + JET_W > powerup_x &&
                              jet2_y < powerup_y + PU_SIZE && jet2_y + JET_H > powerup_y);

    // Determines the *next* power-up type for a player who is still in the initial guaranteed phase.
    function [1:0] get_guaranteed_pu;
        input [2:0] mask; // The player's current mask (1 = still needed)
        input [15:0] rand; // Random seed (LFSR)
        reg [1:0] pu_type;
        begin
            pu_type = PLUS; // Default to plus
            // Cycle through random options until we find one that is still needed (mask is high)
            if (mask != 3'b000) begin
                if (mask[0] && mask[1] && mask[2]) begin // All 3 needed (random among the 3)
                    pu_type = rand[1:0] % 3;
                end else if (mask[0] && mask[1]) begin // Only + and - needed
                    pu_type = rand[0] ? PLUS : MINUS;
                end else if (mask[0] && mask[2]) begin // Only + and Shield needed
                    pu_type = rand[0] ? PLUS : SHIELD;
                end else if (mask[1] && mask[2]) begin // Only - and Shield needed
                    pu_type = rand[0] ? MINUS : SHIELD;
                end else if (mask[0]) begin
                    pu_type = PLUS;
                end else if (mask[1]) begin
                    pu_type = MINUS;
                end else if (mask[2]) begin
                    pu_type = SHIELD;
                end else begin
                    // Should be covered by mask!=0, but as a safe fallback: pure random
                    pu_type = rand[1:0] % 3;
                end
            end else begin
                // All guaranteed collected, return pure random
                pu_type = rand[1:0] % 3;
            end
            get_guaranteed_pu = pu_type;
        end
    endfunction


    always @(posedge clk) begin
        if (frame_tick) begin
            // Spawn every 3 seconds (excluding the last second) AND ensure balanced collection
            if (timer_sec < last_trigger_sec && (timer_sec % 3 == 0) && timer_sec != 0) begin
                if (!powerup_active && (p1_powerup_count + p2_powerup_count < TOTAL_POWERUPS)) begin

                    // --- 1. Determine Spawn Location (Balance collected counts) ---
                    if (p1_powerup_count < p2_powerup_count) begin
                        // Bias spawn to Player 1's side (left)
                        powerup_x <= 40 + (lfsr[9:0] % 200);   // X: 40~239
                    end else if (p2_powerup_count < p1_powerup_count) begin
                        // Bias spawn to Player 2's side (right)
                        powerup_x <= 400 + (lfsr[9:0] % 200);  // X: 400~599
                    end else begin
                        // Equal balance, choose random side
                        powerup_x <= (lfsr[0] == 1'b1) ? (40 + (lfsr[9:0] % 200)) : (400 + (lfsr[9:0] % 200));
                    end
                    powerup_y <= 80 + (lfsr[15:8] % 320);   // Y: 80~399 (random vertical)

                    // --- 2. Determine Power-Up Type (Initial guaranteed or random) ---
                    // Since spawn is biased to the player with the *lower* count, we check the lower count's mask
                    if (p1_powerup_count < p2_powerup_count && p1_pu_init_mask != 3'b000) begin
                        // P1 is lagging AND P1 needs guaranteed PU
                        powerup_type <= get_guaranteed_pu(p1_pu_init_mask, lfsr);
                    end else if (p2_powerup_count < p1_powerup_count && p2_pu_init_mask != 3'b000) begin
                        // P2 is lagging AND P2 needs guaranteed PU
                        powerup_type <= get_guaranteed_pu(p2_pu_init_mask, lfsr);
                    end else if (p1_pu_init_mask != 3'b000 || p2_pu_init_mask != 3'b000) begin
                        // Counts are equal, but one/both still needs guaranteed PU (randomly pick a needed type)
                        if (lfsr[1]) powerup_type <= get_guaranteed_pu(p1_pu_init_mask, lfsr);
                        else powerup_type <= get_guaranteed_pu(p2_pu_init_mask, lfsr);
                    end else begin
                        // Both players have collected all guaranteed powerups, revert to pure random
                        powerup_type <= lfsr[1:0] % 3;
                    end

                    // --- 3. Activate Power-up ---
                    powerup_active <= 1;
                    powerup_collected <= 0;
                    pu_frames_left <= 300;                  // 5 sec lifespan
                    last_trigger_sec <= timer_sec;
                    reveal_frames <= 0;
                    collected_by_p1 <= 0; // Reset collected player
                end
            end

            // Countdown uncollected power-up
            if (powerup_active && !powerup_collected && pu_frames_left != 0) begin
                pu_frames_left <= pu_frames_left - 1;
                if (pu_frames_left == 1) powerup_active <= 0;
            end

            // Countdown reveal animation
            if (reveal_frames != 0) begin
                reveal_frames <= reveal_frames - 1;
                if (reveal_frames == 1) powerup_active <= 0;
            end

            // === COLLECTION LOGIC ===
            if (powerup_active && !powerup_collected) begin
                // Check for Player 1 collection
                if (jet1_pu_collision) begin
                    powerup_collected <= 1;
                    reveal_frames <= 60;
                    collected_by_p1 <= 1;
                    p1_powerup_count <= p1_powerup_count + 1;

                    // Update P1's initial mask if they collected a guaranteed type
                    case (powerup_type)
                        PLUS:   p1_pu_init_mask[0] <= 0; // Turn off '+' bit
                        MINUS:  p1_pu_init_mask[1] <= 0; // Turn off '-' bit
                        SHIELD: p1_pu_init_mask[2] <= 0; // Turn off 'Shield' bit
                    endcase

                    case(powerup_type)
                        PLUS: begin // P1: +20 health to self (Green Plus)
                            player1_health <= (player1_health <= 80) ? player1_health + 20 : 100;
                        end
                        MINUS: begin // P1: -20 opponent (P2) health (Red Minus)
                            player2_health <= (player2_health >= 20) ? player2_health - 20 : 0;
                        end
                        SHIELD: begin // P1: 5-second shield (Blue Circle)
                            shield1_active <= 1;
                            shield1_frames_left <= SHIELD_DURATION;
                        end
                    endcase
                end

                // Check for Player 2 collection
                else if (jet2_pu_collision) begin
                    powerup_collected <= 1;
                    reveal_frames <= 60;
                    collected_by_p1 <= 0; // Collected by P2
                    p2_powerup_count <= p2_powerup_count + 1;

                    // Update P2's initial mask if they collected a guaranteed type
                    case (powerup_type)
                        PLUS:   p2_pu_init_mask[0] <= 0; // Turn off '+' bit
                        MINUS:  p2_pu_init_mask[1] <= 0; // Turn off '-' bit
                        SHIELD: p2_pu_init_mask[2] <= 0; // Turn off 'Shield' bit
                    endcase

                    case(powerup_type)
                        PLUS: begin // P2: +20 health to self (Green Plus)
                            player2_health <= (player2_health <= 80) ? player2_health + 20 : 100;
                        end
                        MINUS: begin // P2: -20 opponent (P1) health (Red Minus)
                            player1_health <= (player1_health >= 20) ? player1_health - 20 : 0;
                        end
                        SHIELD: begin // P2: 5-second shield (Blue Circle)
                            shield2_active <= 1;
                            shield2_frames_left <= SHIELD_DURATION;
                        end
                    endcase
                end
            end
        end

        // Reset on game over
        if (timer_done) begin
            powerup_active <= 0;
            p1_powerup_count <= 0;
            p2_powerup_count <= 0;
            p1_pu_init_mask <= 3'b111; // Reset guarantee
            p2_pu_init_mask <= 3'b111; // Reset guarantee
        end
    end

    // Power-up pixel detection (for drawing)
    wire pu_on = powerup_active &&
                 (pixel_x_r >= powerup_x && pixel_x_r < powerup_x + PU_SIZE &&
                  pixel_y_r >= powerup_y && pixel_y_r < powerup_y + PU_SIZE);

    // === Question Mark (before collection) ===
    wire q_top     = pu_on && !powerup_collected &&
                      (pixel_y_r >= powerup_y + 4  && pixel_y_r <= powerup_y + 8) &&
                      (pixel_x_r >= powerup_x + 6  && pixel_x_r <= powerup_x + 23);
    wire q_curve1  = pu_on && !powerup_collected &&
                      (pixel_y_r >= powerup_y + 9  && pixel_y_r <= powerup_y + 12) &&
                      (pixel_x_r >= powerup_x + 18 && pixel_x_r <= powerup_x + 23);
    wire q_curve2  = pu_on && !powerup_collected &&
                      (pixel_y_r >= powerup_y + 13 && pixel_y_r <= powerup_y + 16) &&
                      (pixel_x_r >= powerup_x + 18 && pixel_x_r <= powerup_x + 23);
    wire q_mid     = pu_on && !powerup_collected &&
                      (pixel_y_r >= powerup_y + 17 && pixel_y_r <= powerup_y + 20) &&
                      (pixel_x_r >= powerup_x + 13 && pixel_x_r <= powerup_x + 18);
    wire q_dot     = pu_on && !powerup_collected &&
                      (pixel_y_r >= powerup_y + 23 && pixel_y_r <= powerup_y + 27) &&
                      (pixel_x_r >= powerup_x + 13 && pixel_x_r <= powerup_x + 17);
    wire question_mark = q_top || q_curve1 || q_curve2 || q_mid || q_dot;

    // === Revealed Icons (after collection) ===
    // Type 0: +Health (Green Plus)
    wire plus_vert = pu_on && powerup_collected && (powerup_type == PLUS) &&
                      (pixel_x_r >= powerup_x + 12 && pixel_x_r <= powerup_x + 17) &&
                      (pixel_y_r >= powerup_y + 5  && pixel_y_r <= powerup_y + 24);
    wire plus_horz = pu_on && powerup_collected && (powerup_type == PLUS) &&
                      (pixel_x_r >= powerup_x + 5  && pixel_x_r <= powerup_x + 24) &&
                      (pixel_y_r >= powerup_y + 12 && pixel_y_r <= powerup_y + 17);
    wire plus_sign = plus_vert || plus_horz;

    // Type 1: -Opponent (Red Minus)
    wire minus_sign = pu_on && powerup_collected && (powerup_type == MINUS) &&
                      (pixel_x_r >= powerup_x + 5  && pixel_x_r <= powerup_x + 24) &&
                      (pixel_y_r >= powerup_y + 12 && pixel_y_r <= powerup_y + 17);

    // Type 2: Shield (Blue Circle)
    wire signed [10:0] pu_dx = pixel_x_r - (powerup_x + 15);
    wire signed [10:0] pu_dy = pixel_y_r - (powerup_y + 15);
    wire [20:0] pu_dist_sq = pu_dx*pu_dx + pu_dy*pu_dy;
    wire shield_circle = pu_on && powerup_collected && (powerup_type == SHIELD) &&
                         (pu_dist_sq >= 64 && pu_dist_sq <= 100);


    // ==================== REALISTIC DEEP-SPACE NEBULA (Indigo ? Midnight Blue ? Violet) ====================
    localparam CENTER_X = 320;
    localparam CENTER_Y = 240;
    wire signed [10:0] dx = pixel_x_r - CENTER_X;
    wire signed [10:0] dy = pixel_y_r - CENTER_Y;
    wire [20:0] dist_sq = dx*dx + dy*dy;

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

    // ==================== FINAL COLOR OUTPUT - 100% GLITCH-FREE (COMBINATIONAL + BLOCKING) ====================
    always @(*) begin
        if (!video_on_r) {red,green,blue} = 12'h000;
        //else if (bullet1_on || bullet2_on) {red,green,blue} = 12'hFFF;  // WHITE ON TOP

        // Power-Up Display (Draw over jets and stars)
        else if (question_mark)     {red,green,blue} = 12'hA0F;  // Bright purple Question Mark
        else if (plus_sign)         {red,green,blue} = 12'h0F0;  // Green +
        else if (minus_sign)        {red,green,blue} = 12'hF00;  // Red -
        else if (shield_circle)     {red,green,blue} = 12'h0BF;  // Blue O
        else if (pu_on && powerup_collected)
            // Background color for revealed icon
            {red,green,blue} = (powerup_type==PLUS) ? 12'h050 :
                               (powerup_type==MINUS) ? 12'h500 : 12'h015;
        else if (pu_on && !powerup_collected) {red,green,blue} = 12'h606; // Dark box for uncollected PU

        else if (timer_on) {red,green,blue} = timer_done ? 12'hF00 : 12'hFFF;
        else if (p1_text_on || p2_text_on) {red,green,blue} = 12'hFFE;
        else if (p1_border && !p1_inner)    {red,green,blue} = 12'h8EF;
        else if (p1_fill) begin
            if (p1_high)  {red,green,blue} = 12'h3CF;
            else if (p1_mid) {red,green,blue} = 12'hFD4;
            else            {red,green,blue} = 12'hF33;
        end
        else if (p1_inner) {red,green,blue} = 12'h223;
        else if (p2_border && !p2_inner)    {red,green,blue} = 12'hF8F;
        else if (p2_fill) begin
            if (p2_high)  {red,green,blue} = 12'hD4F;
            else if (p2_mid) {red,green,blue} = 12'hFD4;
            else            {red,green,blue} = 12'hF33;
        end
        else if (p2_inner) {red,green,blue} = 12'h223;
        else if (jet1_on)                {red,green,blue} = shield1_active ? 12'h38F : 12'h0FF;  // Cyan, Blue when shielded
        else if (jet2_on)                {red,green,blue} = shield2_active ? 12'h38F : 12'hF80;  // Orange, Blue when shielded
        else if (star_bright_center)    {red,green,blue} = 12'hFFF;
        else if (xlarge_star)           {red,green,blue} = 12'hFFE;
        else if (large_star)            {red,green,blue} = 12'hEED;
        else if (medium_star)           {red,green,blue} = 12'hDDE;
        else if (small_star)            {red,green,blue} = 12'hAAB;
        else if (star3_center)          {red,green,blue} = 12'h8CF;
        else if (star3)                 {red,green,blue} = 12'h6AD;
        else if (star8) {red,green,blue} = 12'hF83;
        else if (star10) {red,green,blue} = 12'hF7B;
        else if (star15) {red,green,blue} = 12'hB5E;
        else if (star18) {red,green,blue} = 12'h7BF;
        else if (star21) {red,green,blue} = 12'hF94;
        else if (star25) {red,green,blue} = 12'hE6A;
        else if (star27) {red,green,blue} = 12'hA4D;
        // Nebula
        else if (n00)  {red,green,blue} = 12'h40F;
        else if (n01)  {red,green,blue} = 12'h40F;
        else if (n02)  {red,green,blue} = 12'h40E;
        else if (n03)  {red,green,blue} = 12'h40E;
        else if (n04)  {red,green,blue} = 12'h30E;
        else if (n05)  {red,green,blue} = 12'h30D;
        else if (n06)  {red,green,blue} = 12'h30D;
        else if (n07)  {red,green,blue} = 12'h30C;
        else if (n08)  {red,green,blue} = 12'h30C;
        else if (n09)  {red,green,blue} = 12'h20C;
        else if (n10)  {red,green,blue} = 12'h20B;
        else if (n11)  {red,green,blue} = 12'h20B;
        else if (n12)  {red,green,blue} = 12'h20A;
        else if (n13)  {red,green,blue} = 12'h20A;
        else if (n14)  {red,green,blue} = 12'h209;
        else if (n15)  {red,green,blue} = 12'h109;
        else if (n16)  {red,green,blue} = 12'h108;
        else if (n17)  {red,green,blue} = 12'h108;
        else if (n18)  {red,green,blue} = 12'h107;
        else if (n19)  {red,green,blue} = 12'h107;
        else if (n20)  {red,green,blue} = 12'h106;
        else if (n21)  {red,green,blue} = 12'h106;
        else if (n22)  {red,green,blue} = 12'h105;
        else if (n23)  {red,green,blue} = 12'h005;
        else if (n24)  {red,green,blue} = 12'h004;
        else if (n25)  {red,green,blue} = 12'h004;
        else if (n26)  {red,green,blue} = 12'h003;
        else if (n27)  {red,green,blue} = 12'h003;
        else if (n28)  {red,green,blue} = 12'h002;
        else if (n29)  {red,green,blue} = 12'h002;
        else if (n30)  {red,green,blue} = 12'h001;
        else            {red,green,blue} = 12'h000;
    end
endmodule