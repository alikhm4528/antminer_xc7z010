`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/02/2025 08:37:53 PM
// Design Name: 
// Module Name: led
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module led #(
    parameter CLK_FREQ = 50_000_000
) (
    input clk,
    input rst_n,
    output [3:0] led_o
);

    logic [3:0] reg_led;    
    logic [31:0] counter;
    logic [31:0] nxt_counter;
    logic reload;
     
    assign reload = (counter >= CLK_FREQ);
    assign nxt_counter = reload ? {32{1'b0}} : (counter + 32'd1);
    
    always_ff @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            counter <= {32{1'b0}};
        else   
            counter <= nxt_counter;
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            reg_led <= {4{1'b0}};
        else
            if(reload)
                reg_led <= reg_led + 4'd1;
    end
    
    assign led_o = reg_led;
    
endmodule
