module sarray_top(
	input 		  						clk,
	input 		  						rst_n,
	input  [0:0]  						issue_tinst_valid_i,
	output [0:0]						issue_tinst_ready_o,
	input  [`TINST_TYPE_WIDTH-1:0]  	issue_tinst_type_i,
	input  [`ADDR_WIDTH-1:0] 			issue_tinst_addr0_i,
	input  [`ADDR_WIDTH-1:0] 			issue_tinst_addr1_i,
	input  [`TMMA_PRECISION_WIDTH-1:0]  issue_tinst_precision_i,
	input  [0:0]  						issue_tinst_acc_i,
	output [0:0]  						sarray_ar_valid_o,
	input  [0:0]  						sarray_ar_ready_i,
	output [`ADDR_WIDTH-1:0]  			sarray_ar_addr_o,
	input  [0:0]  						sarray_r_valid_i,
	output [0:0]  						sarray_r_ready_o,
	input  [`SARRAY_LOAD_WIDTH-1:0] 	sarray_r_data_i,
	output [0:0] 						sarray_aw_valid_o,
	input  [0:0] 						sarray_aw_ready_i,
	output [`ADDR_WIDTH-1:0] 			sarray_aw_addr_o,
	output [`SARRAY_STORE_WIDTH-1:0] 	sarray_aw_data_o
);

endmodule