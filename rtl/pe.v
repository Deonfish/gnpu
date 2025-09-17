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
	input [`TMMA_PRECISION_WIDTH-1:0] 	left_precision_i,
	input [`PE_INPUT_DATA_WIDTH-1:0] 	left_data_i,

	output [0:0] 						bot_data_valid_o,
	output [`PE_INPUT_DATA_WIDTH-1:0] 	bot_data_cnt_o,
	output [`PE_INPUT_DATA_WIDTH-1:0] 	bot_data_o,

	output [0:0] 						right_data_valid_o,
	output [`TMMA_CNT_WIDTH-1:0] 		right_data_cnt_o,
	output [0:0]						right_data_type_o,
	output [`TMMA_PRECISION_WIDTH-1:0]	right_precision_o,
	output [`PE_INPUT_DATA_WIDTH-1:0] 	right_data_o
);

	wire [0:0] input_ab_valid;
	wire [0:0] input_c_valid;
	wire [0:0] input_c_hit;

	wire [0:0] 							c_valid;
	wire [`PE_INPUT_DATA_WIDTH-1:0] 	c_data;
	wire [0:0] 							cal_valid;
	wire [`TMMA_PRECISION_WIDTH-1:0] 	cal_precision;
	wire [`PE_INPUT_DATA_WIDTH-1:0] 	a_data;
	wire [`PE_INPUT_DATA_WIDTH-1:0] 	b_data;
	wire [`PE_INPUT_DATA_WIDTH-1:0] 	d_data;

	wire [0:0] 							i_bot_buf_data_vlid;
	wire [`TMMA_CNT_WIDTH-1:0] 			i_bot_buf_data_cnt;
	wire [0:0] 							i_bot_buf_data_type;
	wire [`TMMA_PRECISION_WIDTH-1:0] 	i_bot_buf_precision;
	wire [`PE_INPUT_DATA_WIDTH-1:0] 	i_bot_buf_data;
	wire [0:0] 							o_bot_buf_data_valid;
	wire [`TMMA_CNT_WIDTH-1:0] 			o_bot_buf_data_cnt;
	wire [0:0] 							o_bot_buf_data_type;
	wire [`TMMA_PRECISION_WIDTH-1:0] 	o_bot_buf_precision;
	wire [`PE_INPUT_DATA_WIDTH-1:0] 	o_bot_buf_data;

	wire [0:0] 							i_right_buf_data_vlid;
	wire [`TMMA_CNT_WIDTH-1:0] 			i_right_buf_data_cnt;
	wire [0:0] 							i_right_buf_data_type;
	wire [`TMMA_PRECISION_WIDTH-1:0] 	i_right_buf_precision;
	wire [`PE_INPUT_DATA_WIDTH-1:0] 	i_right_buf_data;
	wire [0:0] 							o_right_buf_data_valid;
	wire [`TMMA_CNT_WIDTH-1:0] 			o_right_buf_data_cnt;
	wire [0:0] 							o_right_buf_data_type;
	wire [`TMMA_PRECISION_WIDTH-1:0] 	o_right_buf_precision;
	wire [`PE_INPUT_DATA_WIDTH-1:0] 	o_right_buf_data;

	assign input_ab_valid = top_data_valid_i && left_data_valid_i && left_data_type_i==`PE_DATA_TYPE_A;
	assign input_c_valid = left_data_valid_i && left_data_type_i==`PE_DATA_TYPE_C;
	assign input_c_hit = input_c_valid && left_data_cnt_i==(`SARRAY_W-x);

	assign c_valid = input_c_hit;
	assign c_data = top_data_i;
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

	assign i_bot_buf_data_vlid = input_ab_valid;
	assign i_bot_buf_data_cnt = top_data_cnt_i;
	assign i_bot_buf_data_type = 'b0;
	assign i_bot_buf_precision = 'b0;
	assign i_bot_buf_data = top_data_i;

	pe_buf u_bot_pe_buf(
		.clk			(clk),
		.rst_n			(rst_n),
		.data_vlid_i	(i_bot_buf_data_vlid),
		.data_cnt_i		(i_bot_buf_data_cnt),
		.data_type_i	(i_bot_buf_data_type),
		.precision_i	(i_bot_buf_precision),
		.data_i			(i_bot_buf_data),
		.data_valid_o	(o_bot_buf_data_valid),
		.data_cnt_o		(o_bot_buf_data_cnt),
		.data_type_o	(o_bot_buf_data_type),
		.precision_o	(o_bot_buf_precision),
		.data_o			(o_bot_buf_data)
	);

	assign i_right_buf_data_vlid = input_ab_valid | input_c_valid & ~input_c_hit;
	assign i_right_buf_data_cnt  = left_data_cnt_i;
	assign i_right_buf_data_type = left_data_type_i;
	assign i_right_buf_precision = left_precision_i;
	assign i_right_buf_data 	 = left_data_i;

	pe_buf u_right_pe_buf(
		.clk			(clk),
		.rst_n			(rst_n),
		.data_vlid_i	(i_right_buf_data_vlid),
		.data_cnt_i		(i_right_buf_data_cnt),
		.data_type_i	(i_right_buf_data_type),
		.precision_i	(i_right_buf_precision),
		.data_i			(i_right_buf_data),
		.data_valid_o	(o_right_buf_data_valid),
		.data_cnt_o		(o_right_buf_data_cnt),
		.data_type_o	(o_right_buf_data_type),
		.precision_o	(o_right_buf_precision),
		.data_o			(o_right_buf_data)
	);

	assign bot_data_valid_o = o_bot_buf_data_valid;
	assign bot_data_cnt_o   = o_bot_buf_data_cnt;
	assign bot_data_o 		= o_bot_buf_data;

	assign right_data_valid_o = o_right_buf_data_valid;
	assign right_data_cnt_o   = o_right_buf_data_cnt;
	assign right_data_type_o  = o_right_buf_data_type;
	assign right_precision_o  = o_right_buf_precision;
	assign right_data_o 	  = o_right_buf_data;

endmodule