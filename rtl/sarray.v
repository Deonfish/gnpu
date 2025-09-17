module sarray(
	input											clk,
	input											rst_n,

	input  [0:0] 									post_storec_valid_i,

	input  [`SARRAY_H-1:0]							left_in_valid_i,
	input  [`TMMA_CNT_WIDTH*`SARRAY_H-1:0]			left_in_cnt_i,
	input  [`SARRAY_H-1:0]							left_in_type_i,
	input  [`TMMA_PRECISION_WIDTH*`SARRAY_H-1:0] 	left_in_precision_i,
	input  [`SARRAY_H:0]							left_in_acc_i,
	input  [`SARRAY_LOAD_WIDTH-1:0] 				left_in_data_i,

	input  [`SARRAY_H-1:0]							top_in_valid_i,
	input  [`SARRAY_LOAD_WIDTH-1:0] 				top_in_data_i,

	output [`SARRAY_H:0]							bot_o_valid_o,
	output [`TMMA_CNT_WIDTH*`SARRAY_H-1:0]			bot_o_cnt_o,
	output [`SARRAY_STORE_WIDTH-1:0] 				bot_o_data_o
);

	wire [0:0] 							pe_top_data_valid[64][64];
	wire [`PE_INPUT_DATA_WIDTH-1:0] 	pe_top_data[64][64];
	wire [0:0]							pe_top_storec_valid[64][64];
	wire [0:0] 							pe_left_data_valid[64][64];
	wire [`TMMA_CNT_WIDTH-1:0] 			pe_left_data_cnt[64][64];
	wire [0:0]							pe_left_data_type[64][64];
	wire [`TMMA_PRECISION_WIDTH-1:0] 	pe_left_precision[64][64];
	wire [`PE_INPUT_DATA_WIDTH-1:0] 	pe_left_data[64][64];
	wire [0:0] 							pe_bot_data_valid[64][64];
	wire [`PE_INPUT_DATA_WIDTH-1:0] 	pe_bot_data_cnt[64][64];
	wire [`PE_INPUT_DATA_WIDTH-1:0] 	pe_bot_data[64][64];
	wire [0:0] 							pe_right_data_valid[64][64];
	wire [`TMMA_CNT_WIDTH-1:0] 			pe_right_data_cnt[64][64];
	wire [0:0]							pe_right_data_type[64][64];
	wire [`TMMA_PRECISION_WIDTH-1:0]	pe_right_precision[64][64];
	wire [`PE_INPUT_DATA_WIDTH-1:0] 	pe_right_data[64][64];

genvar x;
genvar y;
generate
for(x=0; x<64; x=x+1) begin

assign pe_top_data_valid[x][0] 	 = top_in_valid_i[x];
assign pe_top_data[x][0] 		 = top_in_data_i[x*`PE_INPUT_DATA_WIDTH+:`PE_INPUT_DATA_WIDTH];
assign pe_top_storec_valid[x][0] = post_storec_valid_i;

assign pe_left_data_valid[0][x] = left_in_valid_i[x];
assign pe_left_data_cnt[0][x] 	= left_in_cnt_i[x*`TMMA_CNT_WIDTH+:`TMMA_CNT_WIDTH];
assign pe_left_data_type[0][x] 	= left_in_type_i[x];
assign pe_left_precision[0][x] 	= left_in_precision_i[x*`TMMA_PRECISION_WIDTH+:`TMMA_PRECISION_WIDTH];
assign pe_left_data[0][x] 		= left_in_data_i[x*`PE_INPUT_DATA_WIDTH+:`PE_INPUT_DATA_WIDTH];


for(y=0; y<64; y=y+1) begin

	pe u_pe (x, y)(
		.clk				(clk),
		.rst_n				(rst_n),

		.top_data_valid_i	(pe_top_data_valid[x][y]),
		.top_data_i			(pe_top_data[x][y]),
		.top_storec_valid_i	(pe_top_storec_valid[x][y]),

		.left_data_valid_i	(pe_left_data_valid[x][y]),
		.left_data_cnt_i	(pe_left_data_cnt[x][y]),
		.left_data_type_i	(pe_left_data_type[x][y]),
		.left_precision_i	(pe_left_precision[x][y]),
		.left_data_i		(pe_left_data[x][y]),

		.bot_data_valid_o	(pe_bot_data_valid[x][y]),
		.bot_data_cnt_o		(pe_bot_data_cnt[x][y]),
		.bot_data_o			(pe_bot_data[x][y]),

		.right_data_valid_o	(pe_right_data_valid[x][y]),
		.right_data_cnt_o	(pe_right_data_cnt[x][y]),
		.right_data_type_o	(pe_right_data_type[x][y]),
		.right_precision_o	(pe_right_precision[x][y]),
		.right_data_o		(pe_right_data[x][y])
	);

	if(y!=0) begin
		assign pe_top_data_valid[x][y] 	 = pe_bot_data_valid[x][y-1];
		assign pe_top_data[x][y] 		 = pe_bot_data[x][y-1];
		assign pe_top_storec_valid[x][y] = post_storec_valid_i;
	end

	if(x!=0) begin
		assign pe_left_data_valid[x][y] = pe_right_data_valid[x-1][y];
		assign pe_left_data_cnt[x][y] 	= pe_right_data_cnt[x-1][y];
		assign pe_left_data_type[x][y] 	= pe_right_data_type[x-1][y];
		assign pe_left_precision[x][y] 	= pe_right_precision[x-1][y];
		assign pe_left_data[x][y] 		= pe_right_data[x-1][y];
	end

end
end
endgenerate


endmodule