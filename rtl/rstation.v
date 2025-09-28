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
	output  [0:0]  						issue_tmma_acc_o
);

    wire [2:0] cop_func3;
    wire [0:0] cop_tload;
    wire [0:0] cop_preloadc;
    wire [0:0] cop_tmma;
    wire [0:0] cop_poststorec;
    wire [0:0] cop_preloada;
    wire [0:0] cop_tstore;

    wire [0:0] push_tmma_inst;
    wire [`TINST_TYPE_WIDTH-1:0]     cop_tmma_type;
    wire [`TLOAD_DATAW_WIDTH-1:0]    cop_tmma_data_width;
    wire [`ADDR_WIDTH-1:0]           cop_tmma_addr0;
    wire [`ADDR_WIDTH-1:0]           cop_tmma_addr1;
    wire [`TMMA_PRECISION_WIDTH-1:0] cop_tmma_precision;
    wire [0:0]                       cop_tmma_acc;

    reg [0:0]                       tmma_valid_r[`TMMAQ_DEPTH];
    reg [`TINST_TYPE_WIDTH-1:0]     tmma_type_r[`TMMAQ_DEPTH];
    reg [`TLOAD_DATAW_WIDTH-1:0]    tmma_data_width_r[`TMMAQ_DEPTH];
    reg [`ADDR_WIDTH-1:0]           tmma_addr0_r[`TMMAQ_DEPTH];
    reg [`ADDR_WIDTH-1:0]           tmma_addr1_r[`TMMAQ_DEPTH];
    reg [`TMMA_PRECISION_WIDTH-1:0] tmma_precision_r[`TMMAQ_DEPTH];
    reg [0:0]                       tmma_acc_r[`TMMAQ_DEPTH];

    reg [`TMMAQ_PTR_WIDTH-1:0] tmmaq_rptr;
    reg [`TMMAQ_PTR_WIDTH-1:0] tmmaq_wptr;
    reg [0:0]                  tmmaq_rptr_hi;
    reg [0:0]                  tmmaq_wptr_hi;
    wire [0:0]                 tmmaq_full;

    wire [0:0] issue_tmma_hsk;

    // cop resp

    assign cpu_tpu_resp_vld_o = 1'b0;

    // decode

    assign cop_func3 = cpu_tpu_req_insn_i[14:12];
    assign cop_tload        = cop_func3 == `COP_FUNC3_TLOAD;
    assign cop_preloadc     = cop_func3 == `COP_FUNC3_PRELOADC;
    assign cop_tmma         = cop_func3 == `COP_FUNC3_TMMA;
    assign cop_poststorec   = cop_func3 == `COP_FUNC3_POSTSTOREC;
    assign cop_preloada     = cop_func3 == `COP_FUNC3_PRELOADA;
    assign cop_tstore       = cop_func3 == `COP_FUNC3_TSTORE;

    assign push_tmma_inst = cpu_tpu_req_vld_i && cpu_tpu_req_rdy_o && 
        (cop_preloadc || cop_tmma || cop_poststorec || cop_preloada);

    assign cop_tmma_type =  {`TINST_TYPE_WIDTH{cop_tmma}}`TINST_TYPE_TMMA |
                            {`TINST_TYPE_WIDTH{cop_preloadc}}`TINST_TYPE_PRELOADC |
                            {`TINST_TYPE_WIDTH{cop_poststorec}}`TINST_TYPE_POSTSTOREC |
                            {`TINST_TYPE_WIDTH{cop_preloada}}`TINST_TYPE_PRELOADA;
    assign cop_tmma_data_width = `TLOAD_DATAW_WIDTH'b1 << cpu_tpu_req_rs3_data_i[1:0];
    assign cop_tmma_addr0 = cpu_tpu_req_rs1_data_i;
    assign cop_tmma_addr1 = cpu_tpu_req_rs2_data_i;
    assign cop_tmma_precision = cpu_tpu_req_rs3_data_i[2:1];
    assign cop_tmma_acc = cpu_tpu_req_rs3_data_i[0];

    // tmmaq w/r ptr

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            tmmaq_wptr <= 'b0;
        end
        else if(push_tmma_inst) begin
            tmmaq_wptr <= tmmaq_wptr + 1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            tmmaq_rptr <= 'b0;
        end
        else if(issue_tmma_hsk) begin
            tmmaq_rptr <= tmmaq_rptr + 1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            tmmaq_rptr_hi <= 'b0;
        end
        else if(issue_tmma_hsk && &tmmaq_rptr) begin
            tmmaq_rptr_hi <= ~tmmaq_rptr_hi;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            tmmaq_wptr_hi <= 'b0;
        end
        else if(push_tmma_inst && &tmmaq_wptr) begin
            tmmaq_wptr_hi <= ~tmmaq_wptr_hi;
        end
    end

    assign tmmaq_full = tmmaq_wptr==tmmaq_rptr && tmmaq_rptr_hi!=tmmaq_wptr_hi;

    assign cpu_tpu_req_rdy_o = ~tmmaq_full;

    // push/pop tmmaq

genvar i;
generate
for(i=0; i<`TMMAQ_DEPTH; i=i+1) begin
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            tmma_valid_r[i] <= 1'b0;
        end
        else if(push_tmma_inst && i==tmmaq_wptr) begin
            tmma_valid_r[i]         = 1'b1;
            tmma_type_r[i]          = cop_tmma_type;
            tmma_data_width_r[i]    = cop_tmma_data_width;
            tmma_addr0_r[i]         = cop_tmma_addr0;
            tmma_addr1_r[i]         = cop_tmma_addr1;
            tmma_precision_r[i]     = cop_tmma_precision;
            tmma_acc_r[i]           = cop_tmma_acc;
        end
        else if(issue_tmma_hsk && i==tmmaq_rptr) begin
            tmma_valid_r[i] = 1'b0;
        end
    end
end
endgenerate

    assign issue_tmma_hsk = issue_tmma_valid_o & issue_tmma_ready_i;

    assign issue_tmma_valid_o       = tmma_valid_r[tmmaq_rptr]; // @todo: issue constrains
    assign issue_tmma_type_o        = tmma_type_r[tmmaq_rptr];
    assign issue_tmma_data_width_o  = tmma_data_width_r[tmmaq_rptr];
    assign issue_tmma_addr0_o       = tmma_addr0_r[tmmaq_rptr];
    assign issue_tmma_addr1_o       = tmma_addr1_r[tmmaq_rptr];
    assign issue_tmma_precision_o   = tmma_precision_r[tmmaq_rptr];
    assign issue_tmma_acc_o         = tmma_acc_r[tmmaq_rptr];

endmodule