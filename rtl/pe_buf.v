module pe_buf(
	input  								clk,
	input  								rst_n,
	input  [0:0] 						data_vlid_i,
	input  [`TMMA_CNT_WIDTH-1:0] 		data_cnt_i,
	input  [0:0] 						data_type_i,
	input  [`TMMA_PRECISION_WIDTH-1:0] 	precision_i,
	input  [`PE_INPUT_DATA_WIDTH-1:0] 	data_i,
	output [0:0] 						data_valid_o,
	output [`TMMA_CNT_WIDTH-1:0] 		data_cnt_o,
	output [0:0] 						data_type_o,
	output[`TMMA_PRECISION_WIDTH-1:0] 	precision_o,
	output [`PE_INPUT_DATA_WIDTH-1:0] 	data_o
);

	reg  [0:0] 							data_vlid_r;
	reg  [`TMMA_CNT_WIDTH-1:0] 			data_cnt_r;
	reg  [0:0] 							data_type_r;
	reg  [`TMMA_PRECISION_WIDTH-1:0] 	precision_r;
	reg  [`PE_INPUT_DATA_WIDTH-1:0] 	data_r;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			data_vlid_r <= 'b0;
		end
		else if(data_vlid_i) begin
			data_vlid_r <= 1'b1;
			data_cnt_r <= data_cnt_i;
			data_type_r <= data_type_i;
			precision_r <= precision_i;
			data_r <= data_i;
		end
		else if(data_valid_o) begin
			data_vlid_r <= 1'b0;
		end
	end

	assign data_valid_o = data_vlid_r;
	assign data_cnt_o 	= data_cnt_r;
	assign data_type_o 	= data_type_r;
	assign precision_o 	= precision_r;
	assign data_o 		= data_r;

endmodule