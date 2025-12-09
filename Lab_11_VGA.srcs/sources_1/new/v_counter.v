`timescale 1ns / 1ps


module v_counter (
    input clk,
    input enable_v,                  // this is your trig_v from h_counter
    output reg [9:0] v_count
);
    initial begin
        v_count = 0;
    end 
    
    always @(posedge clk) begin
        if (enable_v) begin
            if (v_count == 524)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end
    end
  endmodule 
       