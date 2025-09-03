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

	reg  [0:0] 							tinst_valid_r;
	reg  [`TINST_TYPE_WIDTH-1:0]		tinst_type_r;
	wire [0:0]							push_tinst_valid;
	wire [0:0] 							clear_tinst_valid;
	reg  [0:0]							tmma_precision_r;
	reg  [0:0]							tmma_acc_r;
	reg  [63:0]							tmma_src_addr1_r;
	reg  [`TMMA_CNT_WIDTH-1:0] 			tmma_cnt_r;
	wire [0:0]							tmma_cnt_incr;
	reg  [5:0]							ar_cnt_r;
	wire [0:0]							ar_cnt_incr;
	reg  [0:0]							ar_done_r;
	wire [0:0]							set_ar_done;
	wire [0:0]							clear_ar_done;

	wire [0:0] 							post_storec_valid;
	wire [0:0] 							left_in_valid;
	wire [0:0] 							left_in_a_tag;
	wire [0:0] 							left_in_c_tag;
	wire [`TMMA_CNT_WIDTH-1:0] 			left_in_cnt;
	wire [`SARRAY_LOAD_WIDTH-1:0] 		left_in_data;
	wire [0:0] 							top_in_valid;
	wire [0:0] 							top_in_acc;
	wire [`TMMA_PRECISION_WIDTH-1:0] 	top_in_precision;
	wire [`TMMA_CNT_WIDTH-1:0] 			top_in_cnt;
	wire [`SARRAY_LOAD_WIDTH-1:0] 		top_in_data;
	wire [0:0] 							bot_o_valid;
	wire [`TMMA_CNT_WIDTH-1:0] 			bot_o_cnt;
	wire [`SARRAY_STORE_WIDTH-1:0] 		bot_o_data;


	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			tinst_valid_r <= 'b0;
		end
		else if(push_tinst_valid) begin
			tinst_valid_r 	  <= 1'b1;
			tinst_type_r  	  <= issue_tinst_type_i;
			tmma_precision_r  <= issue_tinst_precision_i;
			tmma_acc_r 		  <= issue_tinst_acc_i;
			tmma_src_addr1_r  <= issue_tinst_addr1_i;
		end
		else if(clear_tinst_valid) begin
			tinst_valid_r <= 1'b0;
		end
	end

	assign push_tinst_valid = issue_tinst_valid_i && issue_tinst_ready_o && issue_tinst_type_i==`TINST_TYPE_TMMA;
	assign clear_tinst_valid = ; // @todo

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			tmma_cnt_r <= 'b0;
		end
		else if(tmma_cnt_incr) begin
			tmma_cnt_r <= tmma_cnt_r + 1;
		end
	end

	assign tmma_cnt_incr = ; // @todo

	assign left_in_cnt = tmma_cnt_r;
	assign top_in_cnt  = tmma_cnt_r;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			ar_done_r <= 'b0;
		end
		else if(set_ar_done) begin
			ar_done_r <= 'b1;
		end
		else if(clear_ar_done) begin
			ar_done_r <= 'b0;
		end
	end

	assign set_ar_done 	 = sarray_ar_valid_o & sarray_ar_ready_i & |ar_cnt_r;
	assign clear_ar_done = clear_tinst_valid | push_tinst_valid;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			ar_cnt_r <= 'b0;
		end
		else if(ar_cnt_incr) begin
			ar_cnt_r <= ar_cnt_r + 1;
		end
	end

	assign sarray_ar_valid_o = tinst_valid_r && tinst_type_r==`TINST_TYPE_TMMA && !ar_done_r;
	assign sarray_ar_addr_o  = tmma_src_addr1_r + (ar_cnt_r<<8);

	assign ar_cnt_incr = sarray_ar_valid_o & sarray_ar_ready_i;

	sarray u_sarray(
		.post_storec_valid_i (post_storec_valid),
		.left_in_valid_i	 (left_in_valid),
		.left_in_a_tag_i	 (left_in_a_tag),
		.left_in_c_tag_i	 (left_in_c_tag),
		.left_in_cnt_i		 (left_in_cnt),
		.left_in_data_i		 (left_in_data),
		.top_in_valid_i		 (top_in_valid),
		.top_in_acc_i		 (top_in_acc),
		.top_in_precision_i	 (top_in_precision),
		.top_in_cnt_i		 (top_in_cnt),
		.top_in_data_i		 (top_in_data),
		.bot_o_valid_o		 (bot_o_valid),
		.bot_o_cnt_o		 (bot_o_cnt),
		.bot_o_data_o		 (bot_o_data)
	);


endmodule