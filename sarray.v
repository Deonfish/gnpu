module sarray(
	input								clk,
	input								rst_n,
	input  [0:0] 						post_storec_valid_i,
	input  [0:0] 						left_in_valid_i,
	input  [0:0] 						left_in_a_tag_i,
	input  [0:0] 						left_in_c_tag_i,
	input  [`TMMA_CNT_WIDTH-1:0] 		left_in_cnt_i,
	input  [`SARRAY_LOAD_WIDTH-1:0] 	left_in_data_i,
	input  [0:0] 						top_in_valid_i,
	input  [0:0] 						top_in_acc_i,
	input  [`TMMA_PRECISION_WIDTH-1:0] 	top_in_precision_i,
	input  [`TMMA_CNT_WIDTH-1:0] 		top_in_cnt_i,
	input  [`SARRAY_LOAD_WIDTH-1:0] 	top_in_data_i,
	output [0:0] 						bot_o_valid_o,
	output [`TMMA_CNT_WIDTH-1:0] 		bot_o_cnt_o,
	output [`SARRAY_STORE_WIDTH-1:0] 	bot_o_data_o
);

endmodule