module spad(
    input clk,
    input rst_n,
    // sarray read channel
	input  [0:0]  						sarray_ar_valid_i,
	output [0:0]  						sarray_ar_ready_o,
	input  [`ADDR_WIDTH-1:0]  			sarray_ar_addr_i,
	output [0:0]  						sarray_r_valid_o,
	input  [0:0]  						sarray_r_ready_i,
	output [`SARRAY_LOAD_WIDTH-1:0] 	sarray_r_data_o,
    // sarray write channel
	input  [0:0] 						sarray_aw_valid_i,
	output [0:0] 						sarray_aw_ready_o,
	input  [`ADDR_WIDTH-1:0] 			sarray_aw_addr_i,
	input  [`SARRAY_STORE_WIDTH-1:0] 	sarray_aw_data_i
);

wire [`SPAD_BANK_NUM-1:0]        bank_cen;
wire [`SPAD_BANK_NUM-1:0]        bank_wen;
wire [`SPAD_BANK_ADDR_WIDTH-1:0] bank_addr[`SPAD_BANK_NUM];
wire [`SPAD_BANK_DATA_WIDTH-1:0] bank_wdata[`SPAD_BANK_NUM];
wire [`SPAD_BANK_DATA_WIDTH-1:0] bank_rdata[`SPAD_BANK_NUM];

reg [0:0]                       sarray_ar_req_r;
reg [`ADDR_WIDTH-1:0]           sarray_ar_addr_r;
reg [0:0]                       sarray_aw_req_r;
reg [0:0]                       sarray_r_req_r;
reg [`SPAD_BANK_NUM-1:0]        sarray_r_bank_r;
reg [`ADDR_WIDTH-1:0]           sarray_aw_addr_r;
reg [`SARRAY_STORE_WIDTH-1:0]   sarray_aw_data_r;

wire [0:0] sarray_ar_hsk;
wire [0:0] sarray_aw_hsk;
wire [0:0] clear_ar_req;
wire [0:0] clear_aw_req;

wire [`SPAD_BANK_NUM-1:0] bank_sel;
wire [0:0] issue_sarray_ar_req;
wire [0:0] issue_sarray_aw_req;

assign sarray_ar_ready_o = ~sarray_ar_req_r | clear_ar_req;
assign sarray_aw_ready_o = ~sarray_aw_req_r | clear_aw_req;

assign sarray_ar_hsk = sarray_ar_valid_i & sarray_ar_ready_o;
assign sarray_aw_hsk = sarray_aw_valid_i & sarray_aw_ready_o;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sarray_ar_req_r <= 1'b0;
    end
    else if(sarray_ar_hsk) begin
        sarray_ar_req_r <= 1'b1;
    end
    else if(clear_ar_req) begin
        sarray_ar_req_r <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sarray_aw_req_r <= 1'b0;
    end
    else if(sarray_aw_hsk) begin
        sarray_aw_req_r <= 1'b1;
    end
    else if(clear_aw_req) begin
        sarray_aw_req_r <= 1'b0;
    end
end

assign clear_ar_req = issue_sarray_ar_req;
assign clear_aw_req = issue_sarray_aw_req;

assign issue_sarray_ar_req = sarray_ar_req_r & ~sarray_aw_req_r;
assign issue_sarray_aw_req = sarray_aw_req_r;

genvar i;
generate
for(i=0; i<`SPAD_BANK_NUM; i=i+1) begin

    // 512B, 256B width
    spad_bank u_spad #(
        .DATAWIDTH(`SPAD_BANK_DATA_WIDTH),
        .ADDRWIDTH(`SPAD_BANK_ADDR_WIDTH)
    ) (
        .CLK(clk),
        .CEN(bank_cen[i]),
        .WEN(bank_wen[i]),
        .D(bank_wdata[i]),
        .A(bank_addr[i]),
        .Q(bank_rdata[i])
    );

    assign bank_sel[i] = {`SPAD_BANK_NUM_WIDTH{issue_sarray_ar_req}} & (sarray_ar_addr_i[`SPAD_BANK_NUM_WIDTH-1:0] == i) |
                         {`SPAD_BANK_NUM_WIDTH{issue_sarray_aw_req}} & (sarray_aw_addr_i[`SPAD_BANK_NUM_WIDTH-1:0] == i);

    assign bank_cen[i] = (issue_sarray_ar_req | issue_sarray_aw_req) & bank_sel[i];
    assign bank_wen[i] = (issue_sarray_aw_req) & bank_sel[i];
    assign bank_addr[i] = {`ADDR_WIDTH{issue_sarray_ar_req}} & sarray_ar_addr_i |
                          {`ADDR_WIDTH{issue_sarray_aw_req}} & sarray_aw_addr_i;
    assign bank_wdata[i] = {`ADDR_WIDTH{issue_sarray_aw_req}} & sarray_aw_data_i;

end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sarray_r_req_r <= 1'b0;
    end
    else if(sarray_ar_req_r) begin
        sarray_r_req_r <= 1'b1;
        sarray_r_bank_r <= bank_sel;
    end
    else begin
        sarray_r_req_r <= 1'b0;
    end
end

assign sarray_r_valid_o = sarray_r_req_r;
assign sarray_r_data_o = {`SARRAY_LOAD_WIDTH{sarray_r_bank_r[0]}} & bank_rdata[0] |
                         {`SARRAY_LOAD_WIDTH{sarray_r_bank_r[1]}} & bank_rdata[1] |
                         {`SARRAY_LOAD_WIDTH{sarray_r_bank_r[2]}} & bank_rdata[2] |
                         {`SARRAY_LOAD_WIDTH{sarray_r_bank_r[3]}} & bank_rdata[3];

endmodule