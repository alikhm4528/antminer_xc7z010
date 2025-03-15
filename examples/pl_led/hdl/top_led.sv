`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/02/2025 08:59:44 PM
// Design Name: 
// Module Name: top
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


module top_led #(
    parameter CLK_FREQ = 50_000_000
) (
    input sys_clk,
    input rst_n,
    output [3:0] led_o
    );
    
    wire [3:0] tmp_led;
    assign led_o = ~tmp_led;
    
    led #(
       .CLK_FREQ(CLK_FREQ) 
    ) u_led(
        .clk(sys_clk),
        .rst_n(rst_n),
        .led_o(tmp_led)
    );
endmodule
