module mac(
	input 								clk,
	input 								rst_n,
	input  [0:0] 						c_valid_i,
	input  [`PE_INPUT_DATA_WIDTH-1:0] 	c_data_i,
	input  [0:0] 						cal_valid_i,
	input  [`TMMA_PRECISION_WIDTH-1:0] 	cal_precision_i,
	input  [`PE_INPUT_DATA_WIDTH-1:0] 	a_data_i,
	input  [`PE_INPUT_DATA_WIDTH-1:0] 	b_data_i,
	output [`PE_INPUT_DATA_WIDTH-1:0] 	d_data_o
);

	wire [0:0]						push_c_data;
	wire [`PE_INPUT_DATA_WIDTH-1:0] next_c_data;
	reg  [`PE_INPUT_DATA_WIDTH-1:0] c_data_r;

`ifdef FAKE_PE

	reg [0:0] 						d_valid_r;
	reg [`PE_INPUT_DATA_WIDTH-1:0]  d_data_r;
	wire [`PE_INPUT_DATA_WIDTH-1:0] d_data;

	assign d_data = a_data_i + b_data_i;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			d_valid_r <= 1'b0;
		end
		else if(cal_valid_i) begin
			d_valid_r <= 1'b1;
			d_data_r  <= d_data;
		end
	end

`endif

	assign push_c_data = c_valid_i | cal_valid_i;
	assign next_c_data = {`PE_INPUT_DATA_WIDTH{c_valid_i}} & c_data_i | {`PE_INPUT_DATA_WIDTH{cal_valid_i}} & d_data;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
		end
		else if(push_c_data) begin
			c_data_r <= next_c_data;
		end
	end

	assign d_data_o = c_data_r;

endmodule