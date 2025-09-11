module pe(
	input 								clk,
	input 								rst_n,
	
	input [0:0] 						top_data_valid_i,
	input [`TMMA_CNT_WIDTH-1:0] 		top_data_cnt_i,
	input [`PE_INPUT_DATA_WIDTH-1:0] 	top_data_i,
	input [0:0]							top_storec_valid_i,

	input [0:0] 						left_data_valid_i,
	input [`TMMA_CNT_WIDTH-1:0] 		left_data_cnt_i,
	input [0:0]							left_data_type_i,
	input [`PE_INPUT_DATA_WIDTH-1:0] 	left_data_i,

	output [0:0] 						bot_data_valid_o,
	output [`PE_INPUT_DATA_WIDTH-1:0] 	bot_data_cnt_o,
	output [`PE_INPUT_DATA_WIDTH-1:0] 	bot_data_o,

	output [0:0] 						right_data_valid_o,
	output [`TMMA_CNT_WIDTH-1:0] 		right_data_cnt_o,
	output [`PE_INPUT_DATA_WIDTH-1:0] 	right_data_o
);


endmodule