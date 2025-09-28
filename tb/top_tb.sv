`timescale 1ns/100ps

module gnpu_tb_top;

logic clk = 0;
logic rst_n;

logic [0:0]                    cpu_tpu_req_vld_i;
logic [0:0]                    cpu_tpu_req_rdy_o;
logic [`COP_INST_WIDTH-1:0]    cpu_tpu_req_insn_i;
logic [`COP_REG_WIDTH-1:0]     cpu_tpu_req_rs1_data_i;
logic [`COP_REG_WIDTH-1:0]     cpu_tpu_req_rs2_data_i;
logic [`COP_REG_WIDTH-1:0]     cpu_tpu_req_rs3_data_i;
logic [0:0]                    cpu_tpu_resp_vld_o;
logic [0:0]                    cpu_tpu_resp_rdy_i;
logic [`COP_REG_WIDTH-1:0]     cpu_tpu_resp_data_o;

gnpu u_dut(
	.clk(clk),
	.rst_n(rst_n),
    // cop req channel
    .cpu_tpu_req_vld_i(cpu_tpu_req_vld_i),
    .cpu_tpu_req_rdy_o(cpu_tpu_req_rdy_o),
    .cpu_tpu_req_insn_i(cpu_tpu_req_insn_i),
    .cpu_tpu_req_rs1_data_i(cpu_tpu_req_rs1_data_i),
    .cpu_tpu_req_rs2_data_i(cpu_tpu_req_rs2_data_i),
    .cpu_tpu_req_rs3_data_i(cpu_tpu_req_rs3_data_i),
    // cop resp channel
    .cpu_tpu_resp_vld_o(cpu_tpu_resp_vld_o),
    .cpu_tpu_resp_rdy_i(cpu_tpu_resp_rdy_i),
    .cpu_tpu_resp_data_o(cpu_tpu_resp_data_o)
);

// clk
initial begin
    forever #(10/2)  clk=~clk;
end

// reset
initial begin
    drv_reset();
    rst_n = 0;
    #500;
    rst_n = 1;
end

// finish
initial begin
    #1000000;
    $finish;
end

// fsdb
initial begin
	$fsdbDumpfile("wave.fsdb"); 
	$fsdbDumpMDA();
	$fsdbDumpvars(); 
end

function drv_reset();
    cpu_tpu_req_vld_i       = 1'b0;
    cpu_tpu_req_insn_i      = 'bz;
    cpu_tpu_req_rs1_data_i  = 'bz;
    cpu_tpu_req_rs2_data_i  = 'bz;
    cpu_tpu_req_rs3_data_i  = 'bz;
    cpu_tpu_resp_rdy_i      = 1'b1;
endfunction

task wait_cop_req_hsk();
    do {
        @(posedge clk);
    } while(!(cpu_tpu_req_vld_i && cpu_tpu_req_rdy_o))
endtask

task send_preloadc();
    @(posedge clk);
    cpu_tpu_req_vld_i <= 1'b1;
    cpu_tpu_req_insn_i <= {12'b0, 5'b00000, 3'b001, 5'b00000, 7'b0101011};
    cpu_tpu_req_rs1_data_i <= $random();
    cpu_tpu_req_rs2_data_i <= $random();
    cpu_tpu_req_rs3_data_i <= $random();
    wait_cop_req_hsk();
endtask

task send_preloada();
    @(posedge clk);
    cpu_tpu_req_vld_i <= 1'b1;
    cpu_tpu_req_insn_i <= {12'b0, 5'b00000, 3'b100, 5'b00000, 7'b0101011};
    cpu_tpu_req_rs1_data_i <= $random();
    cpu_tpu_req_rs2_data_i <= $random();
    cpu_tpu_req_rs3_data_i <= 'b0;
    wait_cop_req_hsk();
endtask

task send_tmma();
    @(posedge clk);
    cpu_tpu_req_vld_i <= 1'b1;
    cpu_tpu_req_insn_i <= {12'b0, 5'b00000, 3'b010, 5'b00000, 7'b0101011};
    cpu_tpu_req_rs1_data_i <= $random();
    cpu_tpu_req_rs2_data_i <= $random();
    cpu_tpu_req_rs3_data_i <= 'b0;
    wait_cop_req_hsk();
endtask

task send_poststorec();
    @(posedge clk);
    cpu_tpu_req_vld_i <= 1'b1;
    cpu_tpu_req_insn_i <= {12'b0, 5'b00000, 3'b011, 5'b00000, 7'b0101011};
    cpu_tpu_req_rs1_data_i <= $random();
    cpu_tpu_req_rs2_data_i <= $random();
    cpu_tpu_req_rs3_data_i <= $random();
    wait_cop_req_hsk();
endtask

// tinst
initial begin
    #5000;
    issue_preloadc();
    repeat(10) @(posedge clk);
    issue_preloada();
    repeat(10) @(posedge clk);
    issue_tmma();
    repeat(10) @(posedge clk);
    issue_poststorec();
    repeat(10) @(posedge clk);
end


endmodule