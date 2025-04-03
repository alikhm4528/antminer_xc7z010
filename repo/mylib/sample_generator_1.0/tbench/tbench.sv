`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2025 03:54:19 PM
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
    logic rest_n;
    logic [9:0] addr;
    wire [31:0] dout;
    
    initial begin
        addr = 0;
        rest_n = 0;
        #25;
        rest_n = 1;
        #32;
        addr = 10;
    end
    
    initial clk = 0;
    always @(clk)
        clk <= #10 ~clk;
        
    // waveform_generator #(
    //     .ADDR_WIDTH(10)
    // ) dut(
    //     .clk(clk),
    //     .rest_n(rest_n),
    //     .enable(1'b1),
    //     .addr(addr),
    //     .dout(dout)
    // );

    logic [7:0] NUMBER_OF_OUTPUT_WORDS = 8'h08;
    logic tready = 1;
    wire  M_AXIS_TVALID;
    wire [31:0] M_AXIS_TDATA;
    wire [3:0] M_AXIS_TSTRB;
    wire  M_AXIS_TLAST;

    sample_generator_v1_0_M_AXIS dut1(
        .NUMBER_OF_OUTPUT_WORDS(NUMBER_OF_OUTPUT_WORDS),
        .M_AXIS_ACLK(clk),
        .M_AXIS_ARESETN(rest_n),
        .M_AXIS_TVALID(M_AXIS_TVALID),
        .M_AXIS_TDATA(M_AXIS_TDATA),
        .M_AXIS_TSTRB(M_AXIS_TSTRB),
        .M_AXIS_TLAST(M_AXIS_TLAST),
        .M_AXIS_TREADY(tready)
    );

endmodule
