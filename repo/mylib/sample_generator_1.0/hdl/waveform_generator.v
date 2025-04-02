/*
    This module is intended to generate waveform
*/

/*
    Programming Model
    --- addr    : address port
    --- dout    : out data port
*/

module waveform_generator #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 8,
    parameter INIT_FILE_NAME = "signal.mem"
) (
    input clk,
    input rest_n,
    input enable,
    input [ADDR_WIDTH-1:0] addr,
    output [DATA_WIDTH-1:0] dout
);

    localparam integer MEMORY_SIZE = (1 << ADDR_WIDTH) * DATA_WIDTH;

    xpm_memory_sprom #(
      .ADDR_WIDTH_A(ADDR_WIDTH),
      .AUTO_SLEEP_TIME(0),
      .CASCADE_HEIGHT(0),
      .ECC_MODE("no_ecc"),
      .MEMORY_INIT_FILE(INIT_FILE_NAME),
      .MEMORY_OPTIMIZATION("true"),
      .MEMORY_PRIMITIVE("auto"),
      .MEMORY_SIZE(MEMORY_SIZE),
      .MESSAGE_CONTROL(0),
      .READ_DATA_WIDTH_A(32),
      .READ_LATENCY_A(1),
      .READ_RESET_VALUE_A("0"),
      .RST_MODE_A("SYNC"),
      .SIM_ASSERT_CHK(1),
      .USE_MEM_INIT(1),
      .WAKEUP_TIME("disable_sleep")
   )
   xpm_memory_sprom_inst (
      .dbiterra(),
      .douta(dout),
      .sbiterra(),
      .addra(addr),
      .clka(clk),
      .ena(enable),
      .injectdbiterra(),
      .injectsbiterra(),
      .regcea(regcea),
      .rsta(~rest_n),
      .sleep()
   );

endmodule

