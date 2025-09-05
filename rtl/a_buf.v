module a_buf(
	input  							clk,
	input  							rst_n,
	input  [0:0] 					wr_a_buf_valid_i,
	input  [0:0] 					wr_a_buf_id_i,
	input  [``TMMA_CNT_WIDTH-1:0]	wr_a_buf_addr_i,
	input  [0:0] 					wr_a_buf_data_i,
	input  [0:0] 					rd_a_buf_valid_i,
	input  [0:0] 					rd_a_buf_id_i,
	input  [``TMMA_CNT_WIDTH-1:0]	rd_a_buf_addr_i,
	output [0:0] 					rd_a_buf_ret_valid_o,
	output [`SARRAY_LOAD_WIDTH-1:0] rd_a_buf_ret_data_o
);

endmodule