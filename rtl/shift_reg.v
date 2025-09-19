
module top_shift_reg #(
parameter delay_cycle = 1,
parameter data_width = 32
) (
	input 						clk,
	input 						rst_n,
	input [0:0] 				shin_valid_i,
	input [`TMMA_CNT_WIDTH-1]	shin_cnt_i,
	input [data_width-1:0] 		shin_data_i,
	output [0:0] 				sho_valid_o,
	output [`TMMA_CNT_WIDTH-1]	sho_cnt_o,
	output [data_width-1:0] 	sho_data_o
);
	reg[0:0]			buf_valid_r[delay_cycle];
    reg [`TMMA_CNT_WIDTH-1]         buf_cnt_r[delay_cycle];
	reg[data_width-1:0] buf[delay_cycle];

genvar i;
generate
for(i=0; i<delay_cycle-1; i=i+1) begin
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			buf_valid_r[i] <= 1'b1;
		end
		else if(shin_valid_i) begin
			buf_valid_r[0] <= 1'b1;
			buf_cnt_r[i+1]       <= buf_cnt_r[i];
			buf[0] <= shin_data_i;
		end
		buf_valid_r[i+1] <= buf_valid_r[i];
		buf_cnt_r[i+1]       <= buf_cnt_r[i];
		buf[i+1] <= buf[i];
	end
end
endgenerate

	assign sho_valid_o = buf_valid_r[delay_cycle-1];
	assign sho_cnt_o        = buf_cnt_r[delay_cycle-1];
	assign sho_data_o  = buf[delay_cycle-1];
endmodule


module left_shift_reg #(
    parameter delay_cycle = 1,
    parameter data_width = 32
)(
	input 					            clk,
	input 					            rst_n,

	input [0:0] 			            shin_valid_i,
    input [`TMMA_CNT_WIDTH-1]           shin_cnt_i,
    input [0:0]                         shin_type_i,
    input [`TMMA_PRECISION_WIDTH-1:0]   shin_precision_i,
    input [0:0]                         shin_acc_i,
	input [data_width-1:0] 	            shin_data_i,

	output [0:0] 			            sho_valid_o,
    output [`TMMA_CNT_WIDTH-1]          sho_cnt_o,
    output [0:0]                        sho_type_o,
    output [`TMMA_PRECISION_WIDTH-1:0]  sho_precision_o,
    output [0:0]                        sho_acc_o,
	output [data_width-1:0]             sho_data_o
);

	reg[0:0]			            buf_valid_r[delay_cycle];
    reg [`TMMA_CNT_WIDTH-1]         buf_cnt_r[delay_cycle];
    reg [0:0]                       buf_type_r[delay_cycle];
    reg [`TMMA_PRECISION_WIDTH-1:0] buf_precision_r[delay_cycle];
    reg [0:0]                       buf_acc_r[delay_cycle];
	reg[data_width-1:0]             buf[delay_cycle];

genvar i;
generate
for(i=0; i<delay_cycle-1; i=i+1) begin
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			buf_valid_r[i] <= 1'b1;
		end
		else if(shin_valid_i) begin
			buf_valid_r[0]      <= 1'b1;
			buf_cnt_r[0]        <= shin_cnt_i;
			buf_type_r[0]       <= shin_type_i;
			buf_precision_r[0]  <= shin_precision_i;
			buf_acc_r[0]        <= shin_acc_i;
			buf[0]              <= shin_data_i;
		end
		buf_valid_r[i+1]     <= buf_valid_r[i];
		buf_cnt_r[i+1]       <= buf_cnt_r[i];
		buf_type_r[i+1]      <= buf_type_r[i];
		buf_precision_r[i+1] <= buf_precision_r[i];
		buf_acc_r[i+1]       <= buf_acc_r[i];
		buf[i+1]             <= buf[i];
	end
end

endgenerate

	assign sho_valid_o      = buf_valid_r[delay_cycle-1];
	assign sho_cnt_o        = buf_cnt_r[delay_cycle-1];
	assign sho_type_o       = buf_type_r[delay_cycle-1];
	assign sho_precision_o  = buf_precision_r[delay_cycle-1];
	assign sho_acc_o        = buf_acc_r[delay_cycle-1];
	assign sho_data_o       = buf[delay_cycle-1];

endmodule


module top_shift_regs(
	input 							 		clk,
	input 							 		rst_n,
	input  [0:0] 					 		shin_valid_i,
	input  [`TMMA_CNT_WIDTH-1]		 		shin_cnt_i,
	input  [`SARRAY_LOAD_WIDTH-1:0]  		shin_data_i,
	output [`SARRAY_H-1:0] 			 		sho_valid_o,
	output [`TMMA_CNT_WIDTH*`SARRAY_H-1]	sho_cnt_o,
	output [`SARRAY_LOAD_WIDTH-1:0]  		sho_data_o
);

    wire [0:0]                                   i_reg_shin_valid[`SARRAY_H];
	wire [`TMMA_CNT_WIDTH-1]                     i_reg_shin_cnt[`SARRAY_H];
    wire [`SARRAY_LOAD_WIDTH/`SARRAY_H-1:0]      i_reg_shin_data[`SARRAY_H];
    wire [0:0]                                   o_reg_sho_valid[`SARRAY_H];
	wire [`TMMA_CNT_WIDTH-1]                     o_reg_sho_cnt[`SARRAY_H];
    wire [`SARRAY_LOAD_WIDTH/`SARRAY_H-1:0]      o_reg_sho_data[`SARRAY_H];

genvar i;
generate
for(i=0; i<`SARRAY_H; i=i+1) begin

    top_shift_reg #(i+1, 32) u_top_shift_reg (
	    .clk            (clk),
	    .rst_n          (rst_n),
	    .shin_valid_i   (i_reg_shin_valid[i]),
		.shin_cnt_i     (i_reg_shin_cnt[i]),
	    .shin_data_i    (i_reg_shin_data[i]),
	    .sho_valid_o    (o_reg_sho_valid[i]),
		.sho_cnt_o      (o_reg_sho_cnt[i]),
	    .sho_data_o     (o_reg_sho_data[i])
    );

    assign i_reg_shin_valid[i] = shin_valid_i;
	assign i_reg_shin_cnt[i]   = shin_cnt_i;
    assign i_reg_shin_data[i]  = shin_data_i[i*`PE_INPUT_DATA_WIDTH+:`PE_INPUT_DATA_WIDTH];
    assign sho_valid_o[i] 											= o_reg_sho_valid[i];
	assign sho_cnt_o[i*`TMMA_CNT_WIDTH+:`TMMA_CNT_WIDTH] 			= o_reg_sho_cnt[i];
    assign sho_data_o[i*`PE_INPUT_DATA_WIDTH+:`PE_INPUT_DATA_WIDTH] = o_reg_sho_data[i];

end
endgenerate

endmodule

module left_shift_regs(
	input 							             clk,
	input 							             rst_n,

	input  [0:0] 					             shin_valid_i,
    input [`TMMA_CNT_WIDTH-1]                    shin_cnt_i,
    input [0:0]                                  shin_type_i,
    input [`TMMA_PRECISION_WIDTH-1:0]            shin_precision_i,
    input [0:0]                                  shin_acc_i,
	input  [`SARRAY_LOAD_WIDTH-1:0]              shin_data_i,
    
	output [`SARRAY_H-1:0] 			             sho_valid_o,
    output [`TMMA_CNT_WIDTH*`SARRAY_H-1]         sho_cnt_o,
    output [`SARRAY_H-1:0]                       sho_type_o,
    output [`TMMA_PRECISION_WIDTH*`SARRAY_H-1:0] sho_precision_o,
    output [`SARRAY_H-1:0]                       sho_acc_o,
	output [`SARRAY_LOAD_WIDTH*`SARRAY_H-1:0]    sho_data_o
);

    wire [0:0]                                   i_reg_shin_valid[`SARRAY_H];
    wire [`TMMA_CNT_WIDTH-1]                     i_reg_shin_cnt[`SARRAY_H];
    wire [0:0]                                   i_reg_shin_type[`SARRAY_H];
    wire [`TMMA_PRECISION_WIDTH-1:0]             i_reg_shin_precision[`SARRAY_H];
    wire [0:0]                                   i_reg_shin_acc[`SARRAY_H];
    wire [`SARRAY_LOAD_WIDTH/`SARRAY_H-1:0]      i_reg_shin_data[`SARRAY_H];
    wire [0:0]                                   o_reg_sho_valid[`SARRAY_H];
    wire [`TMMA_CNT_WIDTH-1]                     o_reg_sho_cnt[`SARRAY_H];
    wire [0:0]                                   o_reg_sho_type[`SARRAY_H];
    wire [`TMMA_PRECISION_WIDTH-1:0]             o_reg_sho_precision[`SARRAY_H];
    wire [0:0]                                   o_reg_sho_acc[`SARRAY_H];
    wire [`SARRAY_LOAD_WIDTH/`SARRAY_H-1:0]      o_reg_sho_data[`SARRAY_H];

genvar i;
generate
for(i=0; i<`SARRAY_H; i=i+1) begin

    left_shift_reg #(i+1, 32) u_left_shift_reg (
	    .clk                (clk),
	    .rst_n              (rst_n),
	    .shin_valid_i       (i_reg_shin_valid[i]),
        .shin_cnt_i         (i_reg_shin_cnt[i]),
        .shin_type_i        (i_reg_shin_type[i]),
        .shin_precision_i   (i_reg_shin_precision[i]),
        .shin_acc_i         (i_reg_shin_acc[i]),
	    .shin_data_i        (i_reg_shin_data[i]),
	    .sho_valid_o        (o_reg_sho_valid[i]),
        .sho_cnt_o          (o_reg_sho_cnt[i]),
        .sho_type_o         (o_reg_sho_type[i]),
        .sho_precision_o    (o_reg_sho_precision[i]),
        .sho_acc_o          (o_reg_sho_acc[i]),
	    .sho_data_o         (o_reg_sho_data[i])
    );

    assign i_reg_shin_valid[i] 		= shin_valid_i;
    assign i_reg_shin_cnt[i]   		= shin_cnt_i;
    assign i_reg_shin_type[i]  		= shin_type_i;
    assign i_reg_shin_precision[i] 	= shin_precision_i;
    assign i_reg_shin_acc[i] 		= shin_acc_i;
    assign i_reg_shin_data[i] 		= shin_data_i[i*`PE_INPUT_DATA_WIDTH+:`PE_INPUT_DATA_WIDTH];

    assign sho_valid_o[i] 													= o_reg_sho_valid[i];
    assign sho_cnt_o[i*`TMMA_CNT_WIDTH+:`TMMA_CNT_WIDTH] 					= o_reg_sho_cnt[i];
    assign sho_type_o[i] 													= o_reg_sho_type[i];
    assign sho_precision_o[i*`TMMA_PRECISION_WIDTH+:`TMMA_PRECISION_WIDTH] 	= o_reg_sho_precision[i];
    assign sho_acc_o[i] 													= o_reg_sho_acc[i];
    assign sho_data_o[i*`PE_INPUT_DATA_WIDTH+:`PE_INPUT_DATA_WIDTH] 		= o_reg_sho_data[i];

end
endgenerate

endmodule

