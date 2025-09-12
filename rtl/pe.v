module pe #(
	parameter x,
	parameter y
) (
	input 								clk,
	input 								rst_n,

	input [0:0] 						top_data_valid_i,
	input [`TMMA_CNT_WIDTH-1:0] 		top_data_cnt_i,
	input [`PE_INPUT_DATA_WIDTH-1:0] 	top_data_i,
	input [0:0]							top_storec_valid_i,

	input [0:0] 						left_data_valid_i,
	input [`TMMA_CNT_WIDTH-1:0] 		left_data_cnt_i,
	input [0:0]							left_data_type_i,
	input  [`TMMA_PRECISION_WIDTH-1:0] 	left_precision_i,
	input [`PE_INPUT_DATA_WIDTH-1:0] 	left_data_i,

	output [0:0] 						bot_data_valid_o,
	output [`PE_INPUT_DATA_WIDTH-1:0] 	bot_data_cnt_o,
	output [`PE_INPUT_DATA_WIDTH-1:0] 	bot_data_o,

	output [0:0] 						right_data_valid_o,
	output [`TMMA_CNT_WIDTH-1:0] 		right_data_cnt_o,
	output [`PE_INPUT_DATA_WIDTH-1:0] 	right_data_o
);

	wire [0:0] input_ab_valid;

	wire [0:0] 							c_valid;
	wire [`PE_INPUT_DATA_WIDTH-1:0] 	c_data;
	wire [0:0] 							cal_valid;
	wire [`TMMA_PRECISION_WIDTH-1:0] 	cal_precision;
	wire [`PE_INPUT_DATA_WIDTH-1:0] 	a_data;
	wire [`PE_INPUT_DATA_WIDTH-1:0] 	b_data;
	wire [`PE_INPUT_DATA_WIDTH-1:0] 	d_data;

	assign input_ab_valid = top_data_valid_i && left_data_valid_i && left_data_type_i==`PE_DATA_TYPE_A;

	assign bot_data_valid_o = input_ab_valid;
	assign bot_data_cnt_o = top_data_cnt_i;
	assign bot_data_o = top_data_i;

	assign right_data_valid_o = input_ab_valid;
	assign right_data_cnt_o = left_data_cnt_i;
	assign right_data_o = left_data_i;

	assign c_valid = 0;
	assign c_data = 0;
	assign cal_valid = input_ab_valid;
	assign cal_precision = left_precision_i;
	assign a_data = left_data_i;
	assign b_data = top_data_i;

mac u_mac(
	.clk			(clk),
	.rst_n			(rst_n),
	.c_valid_i		(c_valid),
	.c_data_i		(c_data),
	.cal_valid_i	(cal_valid),
	.cal_precision_i(cal_precision),
	.a_data_i		(a_data),
	.b_data_i		(b_data),
	.d_data_o		(d_data)
);


endmodule