module gnpu_tb_top;

logic clk;
logic rst_n;

logic [0:0]  						issue_tinst_valid_i;
logic [0:0]						    issue_tinst_ready_o;
logic [`TINST_TYPE_WIDTH-1:0]  	    issue_tinst_type_i;
logic [`ADDR_WIDTH-1:0] 			issue_tinst_addr0_i;
logic [`ADDR_WIDTH-1:0] 			issue_tinst_addr1_i;
logic [`TMMA_PRECISION_WIDTH-1:0]   issue_tinst_precision_i;
logic [0:0]  						issue_tinst_acc_i;
logic [0:0]  						sarray_ar_valid_o;
logic [0:0]  						sarray_ar_ready_i;
logic [`ADDR_WIDTH-1:0]  			sarray_ar_addr_o;
logic [0:0]  						sarray_r_valid_i;
logic [0:0]  						sarray_r_ready_o;
logic [`SARRAY_LOAD_WIDTH-1:0] 	    sarray_r_data_i;
logic [0:0] 						sarray_aw_valid_o;
logic [0:0] 						sarray_aw_ready_i;
logic [`ADDR_WIDTH-1:0] 			sarray_aw_addr_o;
logic [`SARRAY_STORE_WIDTH-1:0] 	sarray_aw_data_o;

sarray_top dut(
    .clk(clk),
    .rst_n(rst_n),
    .issue_tinst_valid_i(issue_tinst_valid_i),
    .issue_tinst_ready_o(issue_tinst_ready_o),
    .issue_tinst_type_i(issue_tinst_type_i),
    .issue_tinst_addr0_i(issue_tinst_addr0_i),
    .issue_tinst_addr1_i(issue_tinst_addr1_i),
    .issue_tinst_precision_i(issue_tinst_precision_i),
    .issue_tinst_acc_i(issue_tinst_acc_i),
    .sarray_ar_valid_o(sarray_ar_valid_o),
    .sarray_ar_ready_i(sarray_ar_ready_i),
    .sarray_ar_addr_o(sarray_ar_addr_o),
    .sarray_r_valid_i(sarray_r_valid_i),
    .sarray_r_ready_o(sarray_r_ready_o),
    .sarray_r_data_i(sarray_r_data_i),
    .sarray_aw_valid_o(sarray_aw_valid_o),
    .sarray_aw_ready_i(sarray_aw_ready_i),
    .sarray_aw_addr_o(sarray_aw_addr_o),
    .sarray_aw_data_o(sarray_aw_data_o)
);

// clk
forever begin
    #10;
    clk = ~clk;
end
// reset
initial begin
    clk = 0;
    rst_n = 0;
    #500;
    rst_n = 1;
end

// finish
initial begin
    #1000000;
    $finish;
end

// tinst
initial begin
    #5000;
    @(posedge clk);
    issue_tinst_valid_i <= 1;
    issue_tinst_type_i  <= `TINST_TYPE_PRELOADA;
    issue_tinst_addr0_i <= 'b0;
    @(posedge clk);
    issue_tinst_valid_i <= 0;
    #10000;
    issue_tinst_valid_i     <= 1;
    issue_tinst_type_i      <= `TINST_TYPE_TMMA;
    issue_tinst_addr0_i     <= 'h0;
    issue_tinst_addr1_i     <= 'h1000;
    issue_tinst_precision_i <= 'b0;
    issue_tinst_acc_i       <= 'b0;
    @(posedge clk);
    issue_tinst_valid_i     <= 0;
end

// rd channel

initial begin
    sarray_ar_ready_i = 1'b1;
end

forever begin
    @(posedge clk);
    sarray_r_valid_i <= 1'b0;
    if(ar_q.size()) begin
        sarray_r_valid_i <= 1'b1;
        sarray_r_data_i <= $random();
    end
    if(sarray_ar_valid_o & sarray_ar_ready_i)
        ar_q.push_back(1);
end

// w channel

initial begin
    sarray_aw_ready_i = 1'b1;
end

endmodule