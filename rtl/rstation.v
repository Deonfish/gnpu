module rstation(
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
    // tload issue channel @todo
    // tstore issue channel @todo
    // tmma issue channel 
	output  [0:0]  						issue_tmma_valid_o,
	input   [0:0]						issue_tmma_ready_i,
	output  [`TINST_TYPE_WIDTH-1:0]  	issue_tmma_type_o,
	output  [`TLOAD_DATAW_WIDTH-1:0]    issue_tmma_data_width_o,
	output  [`ADDR_WIDTH-1:0] 			issue_tmma_addr0_o,
	output  [`ADDR_WIDTH-1:0] 			issue_tmma_addr1_o,
	output  [`TMMA_PRECISION_WIDTH-1:0] issue_tmma_precision_o,
	output  [0:0]  						issue_tmma_acc_o,
);


endmodule