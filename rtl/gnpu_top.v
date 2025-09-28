module gnpu(
	input clk,
	input rst_n,
    // cop req channel
    input  [0:0]                    cpu_tpu_req_vld_i,
    output [0:0]                    cpu_tpu_req_rdy_o,
    input  [`COP_INST_WIDTH-1:0]    cpu_tpu_req_insn_i,
    input  [`COP_REG_WIDTH-1:0]     cpu_tpu_req_rs1_data_i,
    input  [`COP_REG_WIDTH-1:0]     cpu_tpu_req_rs2_data_i,
    input  [`COP_REG_WIDTH-1:0]     cpu_tpu_req_rs3_data_i,
    // cop resp channel
    output [0:0]                    cpu_tpu_resp_vld_o,
    input  [0:0]                    cpu_tpu_resp_rdy_i,
    output [`COP_REG_WIDTH-1:0]     cpu_tpu_resp_data_o,
);

	wire  [0:0]  						issue_tmma_valid;
	wire  [0:0]							issue_tmma_ready;
	wire  [`TINST_TYPE_WIDTH-1:0]  		issue_tmma_type;
	wire  [`TLOAD_DATAW_WIDTH-1:0]    	issue_tmma_data_width;
	wire  [`ADDR_WIDTH-1:0] 			issue_tmma_addr0;
	wire  [`ADDR_WIDTH-1:0] 			issue_tmma_addr1;
	wire  [`TMMA_PRECISION_WIDTH-1:0] 	issue_tmma_precision;
	wire  [0:0]  						issue_tmma_acc;

	wire [0:0]  						sarray_ar_valid;
	wire [0:0]  						sarray_ar_ready;
	wire [`ADDR_WIDTH-1:0]  			sarray_ar_addr;
	wire [0:0]  						sarray_r_valid;
	wire [0:0]  						sarray_r_ready;
	wire [`SARRAY_LOAD_WIDTH-1:0] 		sarray_r_data;
	wire [0:0] 							sarray_aw_valid;
	wire [0:0] 							sarray_aw_ready;
	wire [`ADDR_WIDTH-1:0] 				sarray_aw_addr;
	wire [`SARRAY_STORE_WIDTH-1:0] 		sarray_aw_data;

	rstation u_rstation(
		.clk(clk),
		.rst_n(rst_n),
		.cpu_tpu_req_vld_i(cpu_tpu_req_vld_i),
		.cpu_tpu_req_rdy_o(cpu_tpu_req_rdy_o),
		.cpu_tpu_req_insn_i(cpu_tpu_req_insn_i),
		.cpu_tpu_req_rs1_data_i(cpu_tpu_req_rs1_data_i),
		.cpu_tpu_req_rs2_data_i(cpu_tpu_req_rs2_data_i),
		.cpu_tpu_req_rs3_data_i(cpu_tpu_req_rs3_data_i),
		.cpu_tpu_resp_vld_o(cpu_tpu_resp_vld_o),
		.cpu_tpu_resp_rdy_i(cpu_tpu_resp_rdy_i),
		.cpu_tpu_resp_data_o(cpu_tpu_resp_data_o),
		.issue_tmma_valid_o(issue_tmma_valid),
		.issue_tmma_ready_i(issue_tmma_ready),
		.issue_tmma_type_o(issue_tmma_type),
		.issue_tmma_data_width_o(issue_tmma_data_width),
		.issue_tmma_addr0_o(issue_tmma_addr0),
		.issue_tmma_addr1_o(issue_tmma_addr1),
		.issue_tmma_precision_o(issue_tmma_precision),
		.issue_tmma_acc_o(issue_tmma_acc)
	);

sarray_top u_sarray_top(
	.clk(clk),
	.rst_n(rst_n),
	.issue_tinst_valid_i(issue_tmma_valid),
	.issue_tinst_ready_o(issue_tmma_ready),
	.issue_tinst_type_i(issue_tmma_type),
	.issue_tinst_data_width_i(issue_tmma_data_width),
	.issue_tinst_addr0_i(issue_tmma_addr0),
	.issue_tinst_addr1_i(issue_tmma_addr1),
	.issue_tinst_precision_i(issue_tmma_precision),
	.issue_tinst_acc_i(issue_tmma_acc),
	.sarray_ar_valid_o(sarray_ar_valid),
	.sarray_ar_ready_i(sarray_ar_ready),
	.sarray_ar_addr_o(sarray_ar_addr),
	.sarray_r_valid_i(sarray_r_valid),
	.sarray_r_ready_o(sarray_r_ready),
	.sarray_r_data_i(sarray_r_data),
	.sarray_aw_valid_o(sarray_aw_valid),
	.sarray_aw_ready_i(sarray_aw_ready),
	.sarray_aw_addr_o(sarray_aw_addr),
	.sarray_aw_data_o(sarray_aw_data)
);

spad u_spad(
    .clk(clk),
    .rst_n(rst_n),
	.sarray_ar_valid_i(sarray_ar_valid),
	.sarray_ar_ready_o(sarray_ar_ready),
	.sarray_ar_addr_i(sarray_ar_addr),
	.sarray_r_valid_o(sarray_r_valid),
	.sarray_r_ready_i(sarray_r_ready),
	.sarray_r_data_o(sarray_r_data),
	.sarray_aw_valid_i(sarray_aw_valid),
	.sarray_aw_ready_o(sarray_aw_ready),
	.sarray_aw_addr_i(sarray_aw_addr),
	.sarray_aw_data_i(sarray_aw_data),
);

endmodule