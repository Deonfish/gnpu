module a_buf_shift_reg(
	input 								clk,
	input 								rst_n,
	input  [`TLOAD_DATAW_WIDTH-1:0]		shift_mode_i,
	input  [0:0]						right_input_data_valid_i,
	input  [31:0]  						right_input_data_i,
	output [0:0]  						left_output_data_valid_o,
	output [31:0] 						left_output_data_o,
	input  [0:0]   						down_input_data_valid_i,
	input  [31:0]  						down_input_data_i,
	output [0:0]  						up_output_data_valid_o,
	output [31:0] 						up_output_data_o
);

	reg [31:0] buf_data;
	wire shift_byte_mode;
	wire shift_2byte_mode;
	wire shift_4byte_mode;
	wire shift_out_mode;

	assign shift_byte_mode  = shift_mode_i[`TLOAD_DW_BYTE_IDX]  & right_input_data_valid_i;
	assign shift_2byte_mode = shift_mode_i[`TLOAD_DW_2BYTE_IDX] & right_input_data_valid_i;
	assign shift_4byte_mode = shift_mode_i[`TLOAD_DW_4BYTE_IDX] & right_input_data_valid_i;

	assign shift_out_mode = down_input_data_valid_i;

	always @(posedge clk) begin
		if(shift_byte_mode) begin
			buf_data[7:0]   <= right_input_data[7:0];
			buf_data[15:8]  <= buf_data[7:0];
			buf_data[23:16] <= buf_data[15:8];
			buf_data[31:24] <= buf_data[23:16];
		end
		else if(shift_2byte_mode) begin
			buf_data[15:0]  <= right_input_data[15:0];
			buf_data[31:16] <= buf_data[15:0];
		end
		else if(shift_4byte_mode) begin
			buf_data[31:0] <= right_input_data[31:0];
		end
		else if(shift_out_mode) begin
			buf_data[31:0] <= down_input_data_i;
		end
	end

	assign left_output_data_valid_o = right_input_data_valid_i;
	assign left_output_data_o = {32{shift_byte_mode}} & {24'b0, buf_data[31:24]} |
								{32{shift_2byte_mode}} & {16'b0, buf_data[31:15]} |
								{32{shift_4byte_mode}} & buf_data[31:0];

	assign up_output_data_valid_o = shift_out_mode;
	assign up_output_data_o = buf_data[31:0];

endmodule

module a_buf(
	input  							clk,
	input  							rst_n,

	input  [0:0] 					wr_a_buf_valid_i,
	input  [0:0] 					wr_a_buf_id_i,
	input  [`TLOAD_DATAW_WIDTH-1:0] wr_a_buf_data_width_i,
	input  [`SARRAY_LOAD_WIDTH-1:0] wr_a_buf_data_i,

	input  [0:0] 					rd_a_buf_valid_i,
	input  [0:0] 					rd_a_buf_id_i,
	output [0:0] 					rd_a_buf_ret_valid_o,
	output [`SARRAY_LOAD_WIDTH-1:0] rd_a_buf_ret_data_o
);

	wire wr_1b;
	wire wr_2b;
	wire wr_4b;
	wire [31:0] wr_a_buf_data_rearrenged[`SARRAY_H];
	reg [0:0] rd_a_buf_id_r;

	wire [2:0]		reg_shift_mode[`A_BUF_NUM][`SARRAY_H][`SARRAY_H];
	wire [0:0]		reg_right_input_data_valid[`A_BUF_NUM][`SARRAY_H][`SARRAY_H];
	wire [31:0]  	reg_right_input_data[`A_BUF_NUM][`SARRAY_H][`SARRAY_H];
	wire [0:0]  	reg_left_output_data_valid[`A_BUF_NUM][`SARRAY_H][`SARRAY_H];
	wire [31:0] 	reg_left_output_data[`A_BUF_NUM][`SARRAY_H][`SARRAY_H];
	wire [0:0]   	reg_down_input_data_valid[`A_BUF_NUM][`SARRAY_H][`SARRAY_H];
	wire [31:0]  	reg_down_input_data[`A_BUF_NUM][`SARRAY_H][`SARRAY_H];
	wire [0:0]  	reg_up_output_data_valid[`A_BUF_NUM][`SARRAY_H][`SARRAY_H];
	wire [31:0] 	reg_up_output_data[`A_BUF_NUM][`SARRAY_H][`SARRAY_H];

	assign wr_1b = wr_a_buf_data_width_i[`TLOAD_DW_BYTE_IDX];
	assign wr_2b = wr_a_buf_data_width_i[`TLOAD_DW_2BYTE_IDX];
	assign wr_4b = wr_a_buf_data_width_i[`TLOAD_DW_4BYTE_IDX];

genvar id;
genvar i;
genvar j;
generate
for(i=0; i<`SARRAY_H; i=i+1) begin
	assign wr_a_buf_data_rearrenged[i] = wr_1b ? wr_a_buf_data_i[i*8+:8]   : 
										 wr_2b ? wr_a_buf_data_i[i*16+:16] :
												 wr_a_buf_data_i[i*32+:32];
end
endgenerate

generate
for(id=0; id<`A_BUF_NUM; i=i+1) begin
for(i=0; i<`SARRAY_H; i=i+1) begin
for(j=0; j<`SARRAY_H; j=j+1) begin

	a_buf_shift_reg u_a_buf_shift_reg(
		.clk						(clk),
		.rst_n						(rst_n),
		.shift_mode_i				(reg_i_shift_mode[id][i][j]),
		.right_input_data_valid_i	(reg_i_right_input_data_valid[id][i][j]),
		.right_input_data_i			(reg_i_right_input_data[id][i][j]),
		.left_output_data_valid_o	(reg_o_left_output_data_valid[id][i][j]),
		.left_output_data_o			(reg_o_left_output_data[id][i][j]),
		.down_input_data_valid_i	(reg_i_down_input_data_valid[id][i][j]),
		.down_input_data_i			(reg_i_down_input_data[id][i][j]),
		.up_output_data_valid_o		(reg_o_up_output_data_valid[id][i][j]),
		.up_output_data_o			(reg_o_up_output_data[id][i][j])
	)

	assign reg_i_shift_mode[id][i][j] = wr_a_buf_data_width_i;
	
if(j==`SARRAY_H-1) begin
	assign reg_i_right_input_data_valid[id][i][j] = wr_a_buf_valid_i && id==wr_a_buf_id_i;
	assign reg_i_right_input_data[id][i][j] = wr_a_buf_data_rearrenged[i];
end
else begin
	assign reg_i_right_input_data_valid[id][i][j] = reg_o_left_output_data_valid[id][i][j+1];
	assign reg_i_right_input_data[id][i][j] = reg_o_left_output_data[id][i][j+1];
end

if(i==`SARRAY_H-1) begin
	assign reg_i_down_input_data_valid[id][i][j] = rd_a_buf_valid_i && id==rd_a_buf_id_i;
	assign reg_i_down_input_data[id][i][j] = 'b0;
end
else begin
	assign reg_i_down_input_data_valid[id][i][j] = reg_o_up_output_data_valid[id][i+1][j];
	assign reg_i_down_input_data[id][i][j] = reg_o_up_output_data[id][i+1][j];
end

end
end
end
endgenerate

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rd_a_buf_id_r <= 'b0;
	end
	else begin
		rd_a_buf_id_r <= rd_a_buf_id_i;
	end
end

generate
for(j=0; j<`SARRAY_H; j=j+1) begin
	assign rd_a_buf_ret_data_o[i*32+:32] = reg_o_up_output_data[rd_a_buf_id_r][0][j];
end
endgenerate

	assign rd_a_buf_ret_valid_o = reg_o_up_output_data_valid[rd_a_buf_id_r][0][0];

endmodule