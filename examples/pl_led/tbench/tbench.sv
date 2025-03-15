`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/02/2025 09:00:01 PM
// Design Name: 
// Module Name: tbench
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


module tbench;

    logic clk;
    logic rst_n;
    logic [3:0] led;
    
    initial clk = 0;
    always @(clk)
        clk <= #10 ~clk;
        
    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
    end
        
    top_led #(
        .CLK_FREQ(1000)
    ) u_top(
        .sys_clk(clk),
        .rst_n(rst_n),
        .led_o(led)
    );
endmodule
