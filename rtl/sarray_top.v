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
	wire [0:0]							push_tmma_valid;
	wire [0:0]							push_preloada_valid;
	wire [0:0] 							clear_tinst_valid;
	reg  [0:0]							tmma_precision_r;
	reg  [0:0]							tmma_acc_r;
	reg  [63:0]							preloada_src_addr0_r;
	reg  [63:0]							tmma_src_addr1_r;
	reg  [`TMMA_CNT_WIDTH-1:0] 			tmma_cnt_r;
	wire [0:0]							tmma_cnt_incr;
	reg  [5:0]							ar_cnt_r;
	reg  [5:0]							r_cnt_r;
	wire [0:0]							ar_cnt_incr;
	wire [0:0]							r_cnt_incr;
	reg  [0:0]							ar_done_r;
	wire [0:0]							set_ar_done;
	wire [0:0]							clear_ar_done;
	wire [0:0]							tinst_tmma_valid;
	wire [0:0]							tinst_preloada_valid;
	wire [0:0]							sarray_ar_hsk;
	wire [0:0]							sarray_r_hsk;
	wire [0:0]							rd_b_ret_valid;

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

	reg  [0:0]							wr_a_buf_id_r;
	wire [0:0] 					  		wr_a_buf_valid;
	wire [0:0] 					  		wr_a_buf_id;
	wire [`TMMA_CNT_WIDTH-1:0]			wr_a_buf_addr;
	wire [0:0] 					  		wr_a_buf_data;
	wire [0:0] 					  		rd_a_buf_valid;
	wire [0:0] 					  		rd_a_buf_id;
	wire [`TMMA_CNT_WIDTH-1:0]			rd_a_buf_addr;
	wire [0:0] 					  		rd_a_buf_ret_valid;
	wire [`SARRAY_LOAD_WIDTH-1:0] 		rd_a_buf_ret_data;

	wire [0:0] 					 		left_shin_valid;
	wire [`SARRAY_LOAD_WIDTH-1:0]  		left_shin_data;
	wire [`SARRAY_H-1:0] 				left_sho_valid;
	wire [`SARRAY_LOAD_WIDTH-1:0] 		left_sho_data;
	wire [0:0] 					 		top_shin_valid;
	wire [`SARRAY_LOAD_WIDTH-1:0]  		top_shin_data;
	wire [`SARRAY_H-1:0] 				top_sho_valid;
	wire [`SARRAY_LOAD_WIDTH-1:0] 		top_sho_data;

	wire [0:0] 							tmma_finished;
	wire [0:0]							preloada_finished;

	assign issue_tinst_ready_o = ~tinst_valid_r;

	assign push_tmma_valid 	   = issue_tinst_valid_i && issue_tinst_ready_o && issue_tinst_type_i==`TINST_TYPE_TMMA;
	assign push_preloada_valid = issue_tinst_valid_i && issue_tinst_ready_o && issue_tinst_type_i==`TINST_TYPE_PRELOADA;
	assign clear_tinst_valid   = tmma_finished | preloada_finished;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			tinst_valid_r <= 'b0;
		end
		else if(push_tmma_valid) begin
			tinst_valid_r 	  <= 1'b1;
			tinst_type_r  	  <= issue_tinst_type_i;
			tmma_precision_r  <= issue_tinst_precision_i;
			tmma_acc_r 		  <= issue_tinst_acc_i;
			tmma_src_addr1_r  <= issue_tinst_addr1_i;
		end
		else if(push_preloada_valid) begin
			tinst_valid_r 	  	  <= 1'b1;
			tinst_type_r  	  	  <= issue_tinst_type_i;
			preloada_src_addr0_r  <= issue_tinst_addr0_i;
			wr_a_buf_id_r 		  <= ~wr_a_buf_id_r;
		end
		else if(clear_tinst_valid) begin
			tinst_valid_r <= 1'b0;
		end
	end

	assign tinst_tmma_valid 	= tinst_valid_r && tinst_type_r==`TINST_TYPE_TMMA;
	assign tinst_preloada_valid = tinst_valid_r && tinst_type_r==`TINST_TYPE_PRELOADA;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			tmma_cnt_r <= 'b0;
		end
		else if(tmma_cnt_incr) begin
			tmma_cnt_r <= tmma_cnt_r + 1;
		end
	end

	assign tmma_cnt_incr = left_shin_valid & top_shin_valid;

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

	assign sarray_r_ready_o = 1'b1;

	assign sarray_ar_hsk = sarray_ar_valid_o & sarray_ar_ready_i;
	assign sarray_r_hsk  = sarray_r_valid_i & sarray_r_ready_o;

	assign set_ar_done 	 = sarray_ar_hsk & (&ar_cnt_r);
	assign clear_ar_done = clear_tinst_valid | push_tmma_valid;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			ar_cnt_r <= 'b0;
		end
		else if(ar_cnt_incr) begin
			ar_cnt_r <= ar_cnt_r + 1;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			r_cnt_r <= 'b0;
		end
		else if(r_cnt_incr) begin
			r_cnt_r <= r_cnt_r + 1;
		end
	end

	assign sarray_ar_valid_o = (tinst_tmma_valid | tinst_preloada_valid) & ~ar_done_r;
	assign sarray_ar_addr_o  = (tmma_src_addr1_r & {`ADDR_WIDTH{tinst_tmma_valid}} |
							   preloada_src_addr0_r & {`ADDR_WIDTH{push_preloada_valid}}) + (ar_cnt_r<<8);

	assign ar_cnt_incr = sarray_ar_hsk;
	assign r_cnt_incr  = sarray_r_hsk;

	assign wr_a_buf_valid = tinst_preloada_valid & sarray_r_hsk;
	assign wr_a_buf_id 	  = wr_a_buf_id_r;
	assign wr_a_buf_data  = sarray_r_data_i;
	assign wr_a_buf_addr  = r_cnt_r;

	assign rd_a_buf_valid = tinst_tmma_valid;
	assign rd_a_buf_id 	  = wr_a_buf_id_r;
	assign rd_a_buf_addr  = tmma_cnt_r;

	a_buf u_a_buf (
		.clk					(clk),
		.rst_n					(rst_n),
		.wr_a_buf_valid_i		(wr_a_buf_valid),
		.wr_a_buf_id_i			(wr_a_buf_id),
		.wr_a_buf_addr_i		(wr_a_buf_addr),
		.wr_a_buf_data_i		(wr_a_buf_data),
		.rd_a_buf_valid_i		(rd_a_buf_valid),
		.rd_a_buf_id_i			(rd_a_buf_id),
		.rd_a_buf_addr_i		(rd_a_buf_addr),
		.rd_a_buf_ret_valid_o	(rd_a_buf_ret_valid),
		.rd_a_buf_ret_data_o	(rd_a_buf_ret_data)
	);

	rd_b_ret_valid = tinst_tmma_valid & sarray_r_hsk;
	assign left_shin_valid = rd_b_ret_valid;
	assign left_shin_data  = rd_a_buf_ret_data;

	shift_regs u_left_shift_reg(
		.clk				(clk),
		.rst_n				(rst_n),
		.shin_valid_i		(left_shin_valid),
		.shin_data_i		(left_shin_data),
		.sho_valid_o		(left_sho_valid),
		.sho_data_o			(left_sho_data)
	);

	assign top_shin_valid = rd_b_ret_valid;
	assign top_shin_data  = sarray_r_data_i;

	shift_regs u_top_shift_reg(
		.clk				(clk),
		.rst_n				(rst_n),
		.shin_valid_i		(top_shin_valid),
		.shin_data_i		(top_shin_data),
		.sho_valid_o		(top_sho_valid),
		.sho_data_o			(top_sho_data)
	);

	sarray u_sarray (
		.clk				 (clk)
		.rst_n				 (rst_n)
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

	assign tmma_finished = &tmma_cnt_r;
	assign preloada_finished = &r_cnt_r;

endmodule