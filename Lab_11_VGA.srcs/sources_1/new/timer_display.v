`timescale 1ns / 1ps

module timer_display(
    input clk,
    input [9:0] pixel_x_r,
    input [9:0] pixel_y_r,
    output reg [5:0] timer_sec,
    output reg timer_done,
    output wire [11:0] timer_rgb,
    output wire timer_on
);
    // Timer counter (1 second = 100 MHz clock cycles)
    reg [26:0] timer_cnt = 0;
    
    initial begin
        timer_sec = 30;
        timer_done = 0;
    end
    
    // Timer countdown logic
    always @(posedge clk) begin
        if (timer_cnt == 27'd99_999_999) begin
            timer_cnt <= 0;
            if (timer_sec != 0) timer_sec <= timer_sec - 1;
            if (timer_sec == 1) timer_done <= 1;
        end else begin
            timer_cnt <= timer_cnt + 1;
        end
    end
    
    // Timer display position
    localparam signed [10:0] TIMER_X = 297;
    localparam signed [10:0] TIMER_Y = 15;
    
    wire signed [10:0] tx = $signed({1'b0, pixel_x_r}) - TIMER_X;
    wire signed [10:0] ty = $signed({1'b0, pixel_y_r}) - TIMER_Y;
    
    // Calculate digits
    wire [3:0] tens_digit = timer_sec / 10;
    wire [3:0] ones_digit = timer_sec % 10;
    
    // Seven-segment encoding
    reg [6:0] seg_tens, seg_ones;
    always @(*) begin
        case(tens_digit)
            0: seg_tens = 7'b1111110;
            1: seg_tens = 7'b0110000;
            2: seg_tens = 7'b1101101;
            3: seg_tens = 7'b1111001;
            4: seg_tens = 7'b0110011;
            5: seg_tens = 7'b1011011;
            6: seg_tens = 7'b1011111;
            7: seg_tens = 7'b1110000;
            8: seg_tens = 7'b1111111;
            9: seg_tens = 7'b1111011;
            default: seg_tens = 7'b0000000;
        endcase
        
        case(ones_digit)
            0: seg_ones = 7'b1111110;
            1: seg_ones = 7'b0110000;
            2: seg_ones = 7'b1101101;
            3: seg_ones = 7'b1111001;
            4: seg_ones = 7'b0110011;
            5: seg_ones = 7'b1011011;
            6: seg_ones = 7'b1011111;
            7: seg_ones = 7'b1110000;
            8: seg_ones = 7'b1111111;
            9: seg_ones = 7'b1111011;
            default: seg_ones = 7'b0000000;
        endcase
    end
    
    // Draw tens digit
    wire draw_tens = (tx >= 0 && tx < 20) && (ty >= 0 && ty < 40) && (
        (seg_tens[6] && ty >= 2 && ty <= 5 && tx >= 4 && tx < 16) ||
        (seg_tens[5] && tx >= 15 && tx <= 18 && ty >= 6 && ty < 20) ||
        (seg_tens[4] && tx >= 15 && tx <= 18 && ty >= 21 && ty < 35) ||
        (seg_tens[3] && ty >= 35 && ty <= 38 && tx >= 4 && tx < 16) ||
        (seg_tens[2] && tx >= 1 && tx <= 4 && ty >= 21 && ty < 35) ||
        (seg_tens[1] && tx >= 1 && tx <= 4 && ty >= 6 && ty < 20) ||
        (seg_tens[0] && ty >= 19 && ty <= 21 && tx >= 4 && tx < 16));
    
    // Draw ones digit
    wire signed [10:0] tx_ones = tx - 26;
    wire draw_ones = (tx >= 26 && tx < 46) && (ty >= 0 && ty < 40) && (
        (seg_ones[6] && ty >= 2 && ty <= 5 && tx_ones >= 4 && tx_ones < 16) ||
        (seg_ones[5] && tx_ones >= 15 && tx_ones <= 18 && ty >= 6 && ty < 20) ||
        (seg_ones[4] && tx_ones >= 15 && tx_ones <= 18 && ty >= 21 && ty < 35) ||
        (seg_ones[3] && ty >= 35 && ty <= 38 && tx_ones >= 4 && tx_ones < 16) ||
        (seg_ones[2] && tx_ones >= 1 && tx_ones <= 4 && ty >= 21 && ty < 35) ||
        (seg_ones[1] && tx_ones >= 1 && tx_ones <= 4 && ty >= 6 && ty < 20) ||
        (seg_ones[0] && ty >= 19 && ty <= 21 && tx_ones >= 4 && tx_ones < 16));
    
    assign timer_on = draw_tens || draw_ones;
    assign timer_rgb = timer_done ? 12'hF00 : 12'hFFF;
    
endmodule
