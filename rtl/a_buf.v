module a_buf(
	input  							clk,
	input  							rst_n,
	input  [0:0] 					wr_a_buf_valid_i,
	input  [0:0] 					wr_a_buf_id_i,
	input  [`TMMA_CNT_WIDTH-1:0]	wr_a_buf_addr_i,
	input  [`SARRAY_LOAD_WIDTH-1:0] wr_a_buf_data_i,
	input  [0:0] 					rd_a_buf_valid_i,
	input  [0:0] 					rd_a_buf_id_i,
	input  [`TMMA_CNT_WIDTH-1:0]	rd_a_buf_addr_i,
	output [0:0] 					rd_a_buf_ret_valid_o,
	output [`SARRAY_LOAD_WIDTH-1:0] rd_a_buf_ret_data_o
);

	reg [`SARRAY_LOAD_WIDTH-1:0] a_buf[`A_BUF_NUM][64];

genvar i;
genvar j;
generate
for(i=0; i<2; i=i+1) begin
for(j=0; j<64; j=j+1) begin
	always @(posedge clk or negedge rst_n) begin
		if(wr_a_buf_valid_i && j==wr_a_buf_id_i) begin
			a_buf[i][j] <= wr_a_buf_data_i;
		end
	end
end
end
endgenerate

	assign rd_a_buf_ret_data_o  = a_buf[rd_a_buf_id_i][rd_a_buf_addr_i];
	assign rd_a_buf_ret_valid_o = 1'b1;

endmodule