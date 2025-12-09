`timescale 1ns / 1ps

module powerup_system(
    input clk,
    input frame_tick,
    input [9:0] jet1_x,
    input [9:0] jet1_y,
    input [9:0] jet2_x,
    input [9:0] jet2_y,
    input [5:0] timer_sec,
    input timer_done,
    input [9:0] pixel_x_r,
    input [9:0] pixel_y_r,
    output reg [7:0] powerup_health_p1,
    output reg [7:0] powerup_health_p2,
    output reg shield1_active,
    output reg shield2_active,
    output wire [11:0] powerup_rgb,
    output wire powerup_on
);
    // Powerup parameters
    localparam PU_SIZE = 30;
    localparam TOTAL_POWERUPS = 10;
    localparam JET_W = 50;
    localparam JET_H = 35;
    localparam PLUS = 2'd0;
    localparam MINUS = 2'd1;
    localparam SHIELD = 2'd2;
    localparam SHIELD_DURATION = 300;
    
    // Powerup state
    reg powerup_active = 0;
    reg powerup_collected = 0;
    reg [9:0] powerup_x = 10'd100;
    reg [9:0] powerup_y = 10'd240;
    reg [8:0] pu_frames_left = 0;
    reg [8:0] reveal_frames = 0;
    reg [5:0] last_trigger_sec = 31;
    reg [1:0] powerup_type;
    reg collected_by_p1 = 0;
    reg [3:0] p1_powerup_count = 0;
    reg [3:0] p2_powerup_count = 0;
    reg [2:0] p1_pu_init_mask = 3'b111;
    reg [2:0] p2_pu_init_mask = 3'b111;
    reg [8:0] shield1_frames_left = 0;
    reg [8:0] shield2_frames_left = 0;
    
    // LFSR for randomness
    reg [15:0] lfsr = 16'hACE1;
    
    initial begin
        powerup_health_p1 = 0;
        powerup_health_p2 = 0;
        shield1_active = 0;
        shield2_active = 0;
    end
    
    always @(posedge clk) begin
        if (frame_tick) begin
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
        end
    end
    
    // Collision detection
    wire jet1_pu_collision = (jet1_x < powerup_x + PU_SIZE && jet1_x + JET_W > powerup_x &&
                              jet1_y < powerup_y + PU_SIZE && jet1_y + JET_H > powerup_y);
    wire jet2_pu_collision = (jet2_x < powerup_x + PU_SIZE && jet2_x + JET_W > powerup_x &&
                              jet2_y < powerup_y + PU_SIZE && jet2_y + JET_H > powerup_y);
    
    // Function to determine guaranteed powerup type
    function [1:0] get_guaranteed_pu;
        input [2:0] mask;
        input [15:0] rand;
        reg [1:0] pu_type;
        begin
            pu_type = PLUS;
            if (mask != 3'b000) begin
                if (mask[0] && mask[1] && mask[2]) begin
                    pu_type = rand[1:0] % 3;
                end else if (mask[0] && mask[1]) begin
                    pu_type = rand[0] ? PLUS : MINUS;
                end else if (mask[0] && mask[2]) begin
                    pu_type = rand[0] ? PLUS : SHIELD;
                end else if (mask[1] && mask[2]) begin
                    pu_type = rand[0] ? MINUS : SHIELD;
                end else if (mask[0]) begin
                    pu_type = PLUS;
                end else if (mask[1]) begin
                    pu_type = MINUS;
                end else if (mask[2]) begin
                    pu_type = SHIELD;
                end else begin
                    pu_type = rand[1:0] % 3;
                end
            end else begin
                pu_type = rand[1:0] % 3;
            end
            get_guaranteed_pu = pu_type;
        end
    endfunction
    
    // Powerup spawning and collection logic
    always @(posedge clk) begin
        if (frame_tick) begin
            powerup_health_p1 <= 0;
            powerup_health_p2 <= 0;
            
            // Shield countdown
            if (shield1_active && shield1_frames_left != 0) begin
                shield1_frames_left <= shield1_frames_left - 1;
                if (shield1_frames_left == 1) shield1_active <= 0;
            end
            if (shield2_active && shield2_frames_left != 0) begin
                shield2_frames_left <= shield2_frames_left - 1;
                if (shield2_frames_left == 1) shield2_active <= 0;
            end
            
            // Spawn powerups
            if (timer_sec < last_trigger_sec && (timer_sec % 3 == 0) && timer_sec != 0) begin
                if (!powerup_active && (p1_powerup_count + p2_powerup_count < TOTAL_POWERUPS)) begin
                    // Determine spawn location
                    if (p1_powerup_count < p2_powerup_count) begin
                        powerup_x <= 40 + (lfsr[9:0] % 200);
                    end else if (p2_powerup_count < p1_powerup_count) begin
                        powerup_x <= 400 + (lfsr[9:0] % 200);
                    end else begin
                        powerup_x <= (lfsr[0] == 1'b1) ? (40 + (lfsr[9:0] % 200)) : (400 + (lfsr[9:0] % 200));
                    end
                    powerup_y <= 80 + (lfsr[15:8] % 320);
                    
                    // Determine powerup type
                    if (p1_powerup_count < p2_powerup_count && p1_pu_init_mask != 3'b000) begin
                        powerup_type <= get_guaranteed_pu(p1_pu_init_mask, lfsr);
                    end else if (p2_powerup_count < p1_powerup_count && p2_pu_init_mask != 3'b000) begin
                        powerup_type <= get_guaranteed_pu(p2_pu_init_mask, lfsr);
                    end else if (p1_pu_init_mask != 3'b000 || p2_pu_init_mask != 3'b000) begin
                        if (lfsr[1]) powerup_type <= get_guaranteed_pu(p1_pu_init_mask, lfsr);
                        else powerup_type <= get_guaranteed_pu(p2_pu_init_mask, lfsr);
                    end else begin
                        powerup_type <= lfsr[1:0] % 3;
                    end
                    
                    powerup_active <= 1;
                    powerup_collected <= 0;
                    pu_frames_left <= 300;
                    last_trigger_sec <= timer_sec;
                    reveal_frames <= 0;
                    collected_by_p1 <= 0;
                end
            end
            
            // Countdown uncollected powerup
            if (powerup_active && !powerup_collected && pu_frames_left != 0) begin
                pu_frames_left <= pu_frames_left - 1;
                if (pu_frames_left == 1) powerup_active <= 0;
            end
            
            // Countdown reveal animation
            if (reveal_frames != 0) begin
                reveal_frames <= reveal_frames - 1;
                if (reveal_frames == 1) powerup_active <= 0;
            end
            
            // Collection logic
            if (powerup_active && !powerup_collected) begin
                if (jet1_pu_collision) begin
                    powerup_collected <= 1;
                    reveal_frames <= 60;
                    collected_by_p1 <= 1;
                    p1_powerup_count <= p1_powerup_count + 1;
                    
                    case (powerup_type)
                        PLUS:   p1_pu_init_mask[0] <= 0;
                        MINUS:  p1_pu_init_mask[1] <= 0;
                        SHIELD: p1_pu_init_mask[2] <= 0;
                    endcase
                    
                    case(powerup_type)
                        PLUS: powerup_health_p1 <= 20;
                        MINUS: powerup_health_p2 <= 8'd236; // -20 (two's complement representation for subtraction signal)
                        SHIELD: begin
                            shield1_active <= 1;
                            shield1_frames_left <= SHIELD_DURATION;
                        end
                    endcase
                end
                else if (jet2_pu_collision) begin
                    powerup_collected <= 1;
                    reveal_frames <= 60;
                    collected_by_p1 <= 0;
                    p2_powerup_count <= p2_powerup_count + 1;
                    
                    case (powerup_type)
                        PLUS:   p2_pu_init_mask[0] <= 0;
                        MINUS:  p2_pu_init_mask[1] <= 0;
                        SHIELD: p2_pu_init_mask[2] <= 0;
                    endcase
                    
                    case(powerup_type)
                        PLUS: powerup_health_p2 <= 20;
                        MINUS: powerup_health_p1 <= 8'd236; // -20 (two's complement representation for subtraction signal)
                        SHIELD: begin
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
            p1_pu_init_mask <= 3'b111;
            p2_pu_init_mask <= 3'b111;
            shield1_active <= 0;
            shield2_active <= 0;
        end
    end
    
    // Powerup rendering
    wire pu_on = powerup_active &&
                 (pixel_x_r >= powerup_x && pixel_x_r < powerup_x + PU_SIZE &&
                  pixel_y_r >= powerup_y && pixel_y_r < powerup_y + PU_SIZE);
    
    // Question mark (before collection)
    wire q_top = pu_on && !powerup_collected &&
                 (pixel_y_r >= powerup_y + 4 && pixel_y_r <= powerup_y + 8) &&
                 (pixel_x_r >= powerup_x + 6 && pixel_x_r <= powerup_x + 23);
    wire q_curve1 = pu_on && !powerup_collected &&
                    (pixel_y_r >= powerup_y + 9 && pixel_y_r <= powerup_y + 12) &&
                    (pixel_x_r >= powerup_x + 18 && pixel_x_r <= powerup_x + 23);
    wire q_curve2 = pu_on && !powerup_collected &&
                    (pixel_y_r >= powerup_y + 13 && pixel_y_r <= powerup_y + 16) &&
                    (pixel_x_r >= powerup_x + 18 && pixel_x_r <= powerup_x + 23);
    wire q_mid = pu_on && !powerup_collected &&
                 (pixel_y_r >= powerup_y + 17 && pixel_y_r <= powerup_y + 20) &&
                 (pixel_x_r >= powerup_x + 13 && pixel_x_r <= powerup_x + 18);
    wire q_dot = pu_on && !powerup_collected &&
                 (pixel_y_r >= powerup_y + 23 && pixel_y_r <= powerup_y + 27) &&
                 (pixel_x_r >= powerup_x + 13 && pixel_x_r <= powerup_x + 17);
    wire question_mark = q_top || q_curve1 || q_curve2 || q_mid || q_dot;
    
    // Revealed icons
    wire plus_vert = pu_on && powerup_collected && (powerup_type == PLUS) &&
                     (pixel_x_r >= powerup_x + 12 && pixel_x_r <= powerup_x + 17) &&
                     (pixel_y_r >= powerup_y + 5 && pixel_y_r <= powerup_y + 24);
    wire plus_horz = pu_on && powerup_collected && (powerup_type == PLUS) &&
                     (pixel_x_r >= powerup_x + 5 && pixel_x_r <= powerup_x + 24) &&
                     (pixel_y_r >= powerup_y + 12 && pixel_y_r <= powerup_y + 17);
    wire plus_sign = plus_vert || plus_horz;
    
    wire minus_sign = pu_on && powerup_collected && (powerup_type == MINUS) &&
                      (pixel_x_r >= powerup_x + 5 && pixel_x_r <= powerup_x + 24) &&
                      (pixel_y_r >= powerup_y + 12 && pixel_y_r <= powerup_y + 17);
    
    wire signed [10:0] pu_dx = pixel_x_r - (powerup_x + 15);
    wire signed [10:0] pu_dy = pixel_y_r - (powerup_y + 15);
    wire [20:0] pu_dist_sq = pu_dx*pu_dx + pu_dy*pu_dy;
    wire shield_circle = pu_on && powerup_collected && (powerup_type == SHIELD) &&
                         (pu_dist_sq >= 64 && pu_dist_sq <= 100);
    
    assign powerup_on = question_mark || plus_sign || minus_sign || shield_circle || (pu_on && powerup_collected) || (pu_on && !powerup_collected);
    
    // RGB output
    reg [11:0] powerup_rgb_r;
    always @(*) begin
        if (question_mark)
            powerup_rgb_r = 12'hA0F;
        else if (plus_sign)
            powerup_rgb_r = 12'h0F0;
        else if (minus_sign)
            powerup_rgb_r = 12'hF00;
        else if (shield_circle)
            powerup_rgb_r = 12'h0BF;
        else if (pu_on && powerup_collected)
            powerup_rgb_r = (powerup_type == PLUS) ? 12'h050 :
                           (powerup_type == MINUS) ? 12'h500 : 12'h015;
        else if (pu_on && !powerup_collected)
            powerup_rgb_r = 12'h606;
        else
            powerup_rgb_r = 12'h000;
    end
    
    assign powerup_rgb = powerup_rgb_r;
    
endmodule
