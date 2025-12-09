`timescale 1ns / 1ps

module pixel_gen(
    input clk,
    input video_on,
    input [9:0] pixel_x,
    input [9:0] pixel_y,
    input up, down, left, right,        // Player 1 (JA)
    input up2, down2, left2, right2,    // Player 2
    input btn_p1_fire,  // Player 1 fire button
    input btn_p2_fire,  // Player 2 fire button
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
    
    // ==================== MODULE INSTANTIATIONS ====================
    
    // Jet controller
    wire [9:0] jet1_x, jet1_y, jet2_x, jet2_y;
    wire jet1_on, jet2_on;
    jet_controller jet_ctrl(
        .clk(clk),
        .frame_tick(frame_tick),
        .joy1_up(joy1_up),
        .joy1_down(joy1_down),
        .joy1_left(joy1_left),
        .joy1_right(joy1_right),
        .joy2_up(joy2_up),
        .joy2_down(joy2_down),
        .joy2_left(joy2_left),
        .joy2_right(joy2_right),
        .pixel_x_r(pixel_x_r),
        .pixel_y_r(pixel_y_r),
        .jet1_x(jet1_x),
        .jet1_y(jet1_y),
        .jet2_x(jet2_x),
        .jet2_y(jet2_y),
        .jet1_on(jet1_on),
        .jet2_on(jet2_on)
    );
    
    // Timer display
    wire [5:0] timer_sec;
    wire timer_done;
    wire [11:0] timer_rgb;
    wire timer_on;
    timer_display timer_disp(
        .clk(clk),
        .pixel_x_r(pixel_x_r),
        .pixel_y_r(pixel_y_r),
        .timer_sec(timer_sec),
        .timer_done(timer_done),
        .timer_rgb(timer_rgb),
        .timer_on(timer_on)
    );
    
    // Powerup system
    wire [7:0] powerup_health_p1, powerup_health_p2;
    wire shield1_active, shield2_active;
    wire [11:0] powerup_rgb;
    wire powerup_on;
    powerup_system powerup_sys(
        .clk(clk),
        .frame_tick(frame_tick),
        .jet1_x(jet1_x),
        .jet1_y(jet1_y),
        .jet2_x(jet2_x),
        .jet2_y(jet2_y),
        .timer_sec(timer_sec),
        .timer_done(timer_done),
        .pixel_x_r(pixel_x_r),
        .pixel_y_r(pixel_y_r),
        .powerup_health_p1(powerup_health_p1),
        .powerup_health_p2(powerup_health_p2),
        .shield1_active(shield1_active),
        .shield2_active(shield2_active),
        .powerup_rgb(powerup_rgb),
        .powerup_on(powerup_on)
    );
    
    // Bullet system
    wire player1_hit, player2_hit;
    wire bullet_on;
    bullet_system bullet_sys(
        .clk(clk),
        .frame_tick(frame_tick),
        .jet1_x(jet1_x),
        .jet1_y(jet1_y),
        .jet2_x(jet2_x),
        .jet2_y(jet2_y),
        .pixel_x_r(pixel_x_r),
        .pixel_y_r(pixel_y_r),
        .btn_p1_fire(btn_p1_fire),
        .btn_p2_fire(btn_p2_fire),
        .shield1_active(shield1_active),
        .shield2_active(shield2_active),
        .player1_hit(player1_hit),
        .player2_hit(player2_hit),
        .bullet_on(bullet_on)
    );
    
    // Health display
    wire [7:0] player1_health, player2_health;
    wire [11:0] health_rgb;
    wire health_on;
    health_display health_disp(
        .clk(clk),
        .frame_tick(frame_tick),
        .player1_hit(player1_hit),
        .player2_hit(player2_hit),
        .powerup_health_p1(powerup_health_p1),
        .powerup_health_p2(powerup_health_p2),
        .pixel_x_r(pixel_x_r),
        .pixel_y_r(pixel_y_r),
        .player1_health(player1_health),
        .player2_health(player2_health),
        .health_rgb(health_rgb),
        .health_on(health_on)
    );
    
    // Star background
    wire [11:0] star_rgb;
    wire star_on;
    star_background star_bg(
        .pixel_x_r(pixel_x_r),
        .pixel_y_r(pixel_y_r),
        .star_rgb(star_rgb),
        .star_on(star_on)
    );
    
    // Nebula background
    wire [11:0] nebula_rgb;
    nebula_background nebula_bg(
        .pixel_x_r(pixel_x_r),
        .pixel_y_r(pixel_y_r),
        .nebula_rgb(nebula_rgb)
    );
    
    // ==================== FINAL COLOR OUTPUT ====================
    always @(*) begin
        if (!video_on_r)
            {red, green, blue} = 12'h000;
        // Bullets on top (white)
        else if (bullet_on)
            {red, green, blue} = 12'hFFF;
        // Power-Up Display
        else if (powerup_on)
            {red, green, blue} = powerup_rgb;
        // Timer
        else if (timer_on)
            {red, green, blue} = timer_rgb;
        // Health bars and text
        else if (health_on)
            {red, green, blue} = health_rgb;
        // Jets (with shield effect)
        else if (jet1_on)
            {red, green, blue} = shield1_active ? 12'h38F : 12'h0FF;  // Cyan, Blue when shielded
        else if (jet2_on)
            {red, green, blue} = shield2_active ? 12'h38F : 12'hF80;  // Orange, Blue when shielded
        // Stars
        else if (star_on)
            {red, green, blue} = star_rgb;
        // Nebula background
        else
            {red, green, blue} = nebula_rgb;
    end

endmodule
