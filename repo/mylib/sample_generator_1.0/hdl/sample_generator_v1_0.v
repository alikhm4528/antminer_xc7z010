
`timescale 1 ns / 1 ps

	module sample_generator_v1_0 #
	(
		// Users to add parameters here
		parameter integer ROM_SIZE = 1024,
		parameter INIT_FILE_NAME = "signal.mem",
		// User parameters ends
		// Do not modify the parameters beyond this line

		// Parameters of Axi Slave Bus Interface S_AXIS
		parameter integer C_S_AXIS_TDATA_WIDTH	= 32,

		// Parameters of Axi Master Bus Interface M_AXIS
		parameter integer C_M_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M_AXIS_START_COUNT	= 32
	)
	(
		// Users to add ports here
		input wire [7:0] frame_size,
		input wire  fuse_sig_gen,
		input wire  enable,
		// User ports ends
		// Do not modify the ports beyond this line

		// Ports of Axi Slave Bus Interface S_AXIS
		input wire  axis_aclk,
		input wire  axis_aresetn,

		output wire  s_axis_tready,
		input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] s_axis_tdata,
		input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] s_axis_tstrb,
		input wire  s_axis_tlast,
		input wire  s_axis_tvalid,

		// Ports of Axi Master Bus Interface M_AXIS
		output wire  m_axis_tvalid,
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] m_axis_tdata,
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] m_axis_tstrb,
		output wire  m_axis_tlast,
		input wire  m_axis_tready
	);

	wire tmp_axis_tvalid;
	wire [C_M_AXIS_TDATA_WIDTH-1 : 0] tmp_axis_tdata;
	wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] tmp_axis_tstrb;
	wire  tmp_axis_tlast;

// Instantiation of Axi Bus Interface M_AXIS
	sample_generator_v1_0_M_AXIS # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M_AXIS_TDATA_WIDTH),
		.ROM_SIZE(ROM_SIZE),
		.INIT_FILE_NAME(INIT_FILE_NAME),
		.C_M_START_COUNT(C_M_AXIS_START_COUNT)
	) sample_generator_v1_0_M_AXIS_inst (
		.NUMBER_OF_OUTPUT_WORDS(frame_size),
		.M_AXIS_ACLK(axis_aclk),
		.M_AXIS_ARESETN(axis_aresetn),
		.M_AXIS_TVALID(tmp_axis_tvalid),
		.M_AXIS_TDATA(tmp_axis_tdata),
		.M_AXIS_TSTRB(tmp_axis_tstrb),
		.M_AXIS_TLAST(tmp_axis_tlast),
		.M_AXIS_TREADY(m_axis_tready)
	);

	// Add user logic here
	// AXI MUX
	assign m_axis_tvalid = (enable) ? ((fuse_sig_gen) ? (s_axis_tvalid) :
		(tmp_axis_tvalid)) : 1'b0;
	assign m_axis_tdata = (enable) ? ((fuse_sig_gen) ? (s_axis_tdata) :
		(tmp_axis_tdata)) : {C_S_AXIS_TDATA_WIDTH{1'b0}};
	assign m_axis_tstrb = (enable) ? ((fuse_sig_gen) ? (s_axis_tstrb) :
		(tmp_axis_tstrb)) : {(C_M_AXIS_TDATA_WIDTH/8){1'b0}};
	assign m_axis_tlast = (enable) ? ((fuse_sig_gen) ? (s_axis_tlast) :
		(tmp_axis_tlast)) : 1'b0;
	assign s_axis_tready = m_axis_tready;
	// User logic ends

	endmodule
